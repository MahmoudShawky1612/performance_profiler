import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Helper class to track widget rebuilds
class WidgetBuildTracker {
  final String widgetName;
  int rebuildCount = 0;

  WidgetBuildTracker(this.widgetName);
}

// Class to store screen performance data
class ScreenData {
  double loadTimeMs = 0.0;
  final Map<String, WidgetBuildTracker> buildTrackers = {};
  bool isCurrent = false;

  ScreenData();
}

// Main performance analyzer class
class PerformanceAnalyzer extends ChangeNotifier with WidgetsBindingObserver {
  double _fps = 0.0;
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  final Map<String, ScreenData> _screenData = {};
  String _currentScreen = 'Unknown';
  bool _isVisible = true;
  final Stopwatch _loadStopwatch = Stopwatch();
  bool _screenRendered = false;

  PerformanceAnalyzer() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_trackFrame);
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  double get fps => _fps;

  double get currentScreenLoadTime =>
      _screenData[_currentScreen]?.loadTimeMs ?? 0.0;

  Map<String, WidgetBuildTracker> get currentScreenBuildTrackers =>
      _screenData[_currentScreen]?.buildTrackers ?? {};

  String get currentScreen => _currentScreen;

  bool get isVisible => _isVisible;

  void setCurrentScreen(String name) {
    _screenData.forEach((key, value) => value.isCurrent = false);
    if (!_screenData.containsKey(name)) {
      _screenData[name] = ScreenData();
    }
    _screenData[name]!.isCurrent = true;
    _currentScreen = name;
    developer.log('Current screen set to: $name');
    startScreenLoad();
    notifyListeners();
  }

  void startScreenLoad() {
    if (!_screenData.containsKey(_currentScreen)) {
      _screenData[_currentScreen] = ScreenData();
    }
    _screenData[_currentScreen]!.loadTimeMs = 0.0;
    _screenData[_currentScreen]!.buildTrackers.clear();
    _screenRendered = false;
    _loadStopwatch.reset();
    _loadStopwatch.start();
    developer.log('Screen load stopwatch started for $_currentScreen');
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    if (_screenRendered || !_screenData.containsKey(_currentScreen)) return;
    _loadStopwatch.stop();
    _screenRendered = true;
    _screenData[_currentScreen]!.loadTimeMs =
        _loadStopwatch.elapsedMilliseconds.toDouble();
    developer.log(
        'Screen load completed for $_currentScreen in ${_screenData[_currentScreen]!.loadTimeMs} ms');
    notifyListeners();
  }

  void trackWidgetBuild(String widgetName) {
    if (!_screenData.containsKey(_currentScreen)) {
      _screenData[_currentScreen] = ScreenData();
    }
    final trackers = _screenData[_currentScreen]!.buildTrackers;
    trackers.putIfAbsent(widgetName, () => WidgetBuildTracker(widgetName));
    trackers[widgetName]!.rebuildCount++;
    developer.log(
        'Widget $widgetName rebuilt in $_currentScreen: ${trackers[widgetName]!.rebuildCount} times');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void toggleVisibility() {
    _isVisible = !_isVisible;
    developer.log('Profiler visibility: $_isVisible');
    notifyListeners();
  }

  void _trackFrame(Duration timeStamp) {
    if (_lastFrameTime == null) {
      _lastFrameTime = DateTime.now();
    } else {
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameTime!).inMilliseconds;
      if (elapsed >= 1000) {
        _fps = (_frameCount * 1000 / elapsed).toDouble();
        _frameCount = 0;
        _lastFrameTime = now;
        developer.log('FPS updated: $_fps');
        notifyListeners();
      }
    }
    _frameCount++;
    WidgetsBinding.instance.addPostFrameCallback(_trackFrame);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loadStopwatch.stop();
    _screenData.clear();
    developer.log('PerformanceAnalyzer disposed');
    super.dispose();
  }
}

// Widget to track rebuilds
class TrackedWidget extends StatelessWidget {
  final String name;
  final Widget child;

  const TrackedWidget({super.key, required this.name, required this.child});

  @override
  Widget build(BuildContext context) {
    Provider.of<PerformanceAnalyzer>(context, listen: false)
        .trackWidgetBuild(name);
    return child;
  }
}

// Profiler overlay widget
class ProfilerOverlay extends StatelessWidget {
  const ProfilerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PerformanceAnalyzer>(
      builder: (context, analyzer, child) {
        final currentData = analyzer.currentScreenBuildTrackers;
        final sortedEntries = currentData.entries.toList()
          ..sort(
              (a, b) => b.value.rebuildCount.compareTo(a.value.rebuildCount));

        return Positioned(
          top: 50,
          right: 10,
          child: AnimatedOpacity(
            opacity: analyzer.isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              width: 280,
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Screen: ${analyzer.currentScreen}',
                            style: _whiteTextBold),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                          onPressed: () => analyzer.toggleVisibility(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMetric('Load Time',
                            '${analyzer.currentScreenLoadTime.toStringAsFixed(1)} ms'),
                        const SizedBox(width: 16),
                        _buildMetric('FPS', analyzer.fps.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Top Widget Rebuilds:', style: _whiteTextBold),
                    const SizedBox(height: 4),
                    if (sortedEntries.isEmpty)
                      Text('No rebuilds tracked', style: _whiteText)
                    else
                      ...sortedEntries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: _whiteText,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${entry.value.rebuildCount}',
                                style: entry.value.rebuildCount > 10
                                    ? _redText
                                    : _whiteText,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _whiteTextSmall),
        Text(value, style: _whiteTextBold),
      ],
    );
  }

  static const _whiteText = TextStyle(color: Colors.white, fontSize: 13);
  static const _whiteTextSmall = TextStyle(color: Colors.white70, fontSize: 11);
  static const _whiteTextBold =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);
  static const _redText = TextStyle(color: Colors.red, fontSize: 13);
}

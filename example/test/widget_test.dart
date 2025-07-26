import 'package:flutter_test/flutter_test.dart';
import 'package:performance_profiler/performance_profiler.dart';

void main() {
  test('PerformanceAnalyzer initializes correctly', () {
    final analyzer = PerformanceAnalyzer();
    expect(analyzer.fps, 0.0);
    expect(analyzer.currentScreenLoadTime, 0.0);
    expect(analyzer.currentScreenBuildTrackers, isEmpty);
    expect(analyzer.currentScreen, 'Unknown');
  });

  test('PerformanceAnalyzer tracks widget rebuilds per screen', () {
    final analyzer = PerformanceAnalyzer();
    analyzer.setCurrentScreen('TestScreen');
    analyzer.trackWidgetBuild('TestWidget');
    expect(analyzer.currentScreenBuildTrackers['TestWidget']!.rebuildCount, 1);
    analyzer.setCurrentScreen('OtherScreen');
    expect(analyzer.currentScreenBuildTrackers, isEmpty);
    analyzer.setCurrentScreen('TestScreen');
    expect(analyzer.currentScreenBuildTrackers['TestWidget']!.rebuildCount, 1);
  });

  test('PerformanceAnalyzer sets current screen', () {
    final analyzer = PerformanceAnalyzer();
    analyzer.setCurrentScreen('TestScreen');
    expect(analyzer.currentScreen, 'TestScreen');
  });
}

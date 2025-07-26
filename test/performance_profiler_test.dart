import 'package:flutter_test/flutter_test.dart';
import 'package:performance_profiler/performance_profiler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PerformanceAnalyzer initializes correctly', () {
    final analyzer = PerformanceAnalyzer();
    expect(analyzer.fps, 0.0);
    expect(analyzer.currentScreenLoadTime, 0.0);
    expect(analyzer.currentScreenBuildTrackers, isEmpty);
    expect(analyzer.currentScreen, 'Unknown');
    analyzer.dispose();
  });

  test('PerformanceAnalyzer tracks widget rebuilds per screen', () {
    final analyzer = PerformanceAnalyzer();
    
    // Set current screen and track a widget
    analyzer.setCurrentScreen('TestScreen');
    analyzer.trackWidgetBuild('TestWidget');
    expect(analyzer.currentScreenBuildTrackers['TestWidget']?.rebuildCount, 1);
    
    // Switch to another screen - build trackers should be empty
    analyzer.setCurrentScreen('OtherScreen');
    expect(analyzer.currentScreenBuildTrackers, isEmpty);
    
    // Switch back to TestScreen and track the widget again
    // Since switching screens clears build trackers, we start fresh
    analyzer.setCurrentScreen('TestScreen');
    analyzer.trackWidgetBuild('TestWidget');
    expect(analyzer.currentScreenBuildTrackers['TestWidget']?.rebuildCount, 1);
    
    analyzer.dispose();
  });

  test('PerformanceAnalyzer sets current screen', () {
    final analyzer = PerformanceAnalyzer();
    analyzer.setCurrentScreen('TestScreen');
    expect(analyzer.currentScreen, 'TestScreen');
    analyzer.dispose();
  });
}

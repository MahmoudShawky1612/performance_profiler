# Performance Profiler

A Flutter package for profiling app performance, including screen load time, FPS, and widget rebuild tracking. It provides a customizable overlay to display performance metrics in real-time.

## Features
- Track screen load times.
- Monitor FPS (Frames Per Second).
- Track widget rebuilds per screen.
 - Customizable overlay with hide/show functionality.

## Installation
Add this to your `pubspec.yaml`:
yaml
dependencies:
  performance_profiler: ^1.0.0

Run:
flutter pub get

## Usage
1. Wrap your app with PerformanceAnalyzer:
import 'package:flutter/material.dart';
import 'package:performance_profiler/performance_profiler.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PerformanceAnalyzer(),
      child: const MyApp(),
    ),
  );
}

2.Set the current screen name in each screen's State class:
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  @override
  MyScreenState createState() => MyScreenState();
}

class MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PerformanceAnalyzer>(context, listen: false).setCurrentScreen('MyScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          TrackedWidget(
            name: 'MyScreenBody',
            child: const Center(child: Text('Hello, World!')),
          ),
          const ProfilerOverlay(),
        ],
      ),
    );
  }
}

3. Use TrackedWidget to monitor specific widgets:
TrackedWidget(
  name: 'MyWidget',
  child: Text('Some content'),
)

4.Add ProfilerOverlay to display performance metrics:
    .The overlay shows the current screen name, load time, FPS, and widget rebuild counts.
    .It can be hidden/shown using the close button.



## Example
Check the example/ folder for a complete example with multiple screens.

## Notes
Ensure provider is added to your pubspec.yaml.
 Use unique screen names for accurate tracking.

## License
MIT License
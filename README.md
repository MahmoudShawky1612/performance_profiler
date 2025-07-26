# Performance Profiler

A comprehensive Flutter package for real-time performance monitoring and analysis. Track screen load times, frame rates, and widget rebuild metrics with an intuitive overlay interface.

## Features

- **Screen Load Time Tracking** - Monitor navigation and initialization performance
- **FPS Monitoring** - Real-time frames per second measurement
- **Widget Rebuild Analysis** - Track rebuild frequency per screen and component
- **Customizable Overlay** - Toggle visibility and customize display options
- **Developer-Friendly** - Simple integration with minimal code changes

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  performance_profiler: ^1.0.0
  provider: ^6.0.0  # Required for state management
```

Install the package:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the Performance Analyzer

Wrap your application with the `PerformanceAnalyzer` provider:

```dart
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
```

### 2. Configure Screen Tracking

Set the current screen name in each screen's `initState` method:

```dart
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
      Provider.of<PerformanceAnalyzer>(context, listen: false)
          .setCurrentScreen('MyScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          TrackedWidget(
            name: 'MyScreenBody',
            child: const Center(
              child: Text('Hello, World!'),
            ),
          ),
          const ProfilerOverlay(),
        ],
      ),
    );
  }
}
```

### 3. Track Specific Widgets

Wrap widgets you want to monitor with `TrackedWidget`:

```dart
TrackedWidget(
  name: 'CustomButton',
  child: ElevatedButton(
    onPressed: () {},
    child: const Text('Click Me'),
  ),
)
```

### 4. Display Performance Metrics

Add the `ProfilerOverlay` to your screen stack to view real-time metrics:

- Current screen name
- Screen load time
- FPS (Frames Per Second)
- Widget rebuild counts
- Toggle visibility with the close/show button

## API Reference

### PerformanceAnalyzer

Main class for managing performance tracking.

**Methods:**
- `setCurrentScreen(String screenName)` - Set the active screen for tracking
- `trackWidget(String widgetName)` - Register a widget for rebuild monitoring

### TrackedWidget

Widget wrapper for monitoring rebuild performance.

**Properties:**
- `name` (String) - Unique identifier for the widget
- `child` (Widget) - The widget to be tracked

### ProfilerOverlay

Customizable overlay for displaying performance metrics.

**Features:**
- Real-time metric updates
- Hide/show toggle functionality
- Minimal UI footprint

## Best Practices

- Use descriptive and unique screen names for accurate tracking
- Place `ProfilerOverlay` at the top level of your widget stack
- Limit `TrackedWidget` usage to critical components to avoid performance overhead
- Remove or disable profiling in production builds

## ScreenShots

<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-07-26 at 22 54 58" src="https://github.com/user-attachments/assets/642454b5-3aef-4ac8-97b2-97b5e507f423" />

<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-07-26 at 22 55 11" src="https://github.com/user-attachments/assets/b5694b98-3ff0-4825-9e21-d32038a31fef" />

<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-07-26 at 22 55 23" src="https://github.com/user-attachments/assets/3a099827-95f1-469c-844a-e9f24dfd99cb" />


## Example

For a complete implementation example with multiple screens and tracked widgets, see the `example/` directory in the package repository.

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note:** This package is designed for development and debugging purposes. Consider removing or disabling performance tracking in production builds to optimize app performance.

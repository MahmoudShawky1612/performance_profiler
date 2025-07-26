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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Profiler Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainScreen(),
        '/second': (context) => const SecondScreen(),
        '/third': (context) => const ThirdScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PerformanceAnalyzer>(context, listen: false)
          .setCurrentScreen('MainScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Screen')),
      body: Stack(
        children: [
          TrackedWidget(
            name: 'MainScreenBody',
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return TrackedWidget(
                  name: 'MainItem_$index',
                  child: ListTile(
                    title: Text('Item $index'),
                    onTap: () {
                      Navigator.pushNamed(
                          context, index % 2 == 0 ? '/second' : '/third');
                    },
                  ),
                );
              },
            ),
          ),
          const ProfilerOverlay(),
        ],
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  SecondScreenState createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PerformanceAnalyzer>(context, listen: false)
          .setCurrentScreen('SecondScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Stack(
        children: [
          TrackedWidget(
            name: 'SecondScreenBody',
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TrackedWidget(
                    name: 'CounterText',
                    child: Text('Counter: $_counter',
                        style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 20),
                  TrackedWidget(
                    name: 'FPSIndicator',
                    child: Consumer<PerformanceAnalyzer>(
                      builder: (context, analyzer, child) {
                        return Text(
                            'Current FPS: ${analyzer.fps.toStringAsFixed(1)}');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              child: const Icon(Icons.add_circle),
            ),
          ),
          const ProfilerOverlay(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  ThirdScreenState createState() => ThirdScreenState();
}

class ThirdScreenState extends State<ThirdScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PerformanceAnalyzer>(context, listen: false)
          .setCurrentScreen('ThirdScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Third Screen')),
      body: Stack(
        children: [
          TrackedWidget(
            name: 'ThirdScreenBody',
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(30, (index) {
                return TrackedWidget(
                  name: 'GridItem_$index',
                  child: Card(child: Center(child: Text('Item $index'))),
                );
              }),
            ),
          ),
          const ProfilerOverlay(),
        ],
      ),
    );
  }
}

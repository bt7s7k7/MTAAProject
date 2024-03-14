import 'package:flutter/material.dart';
import 'package:mtaa_project/layout/LayoutConfig.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    LayoutConfig.of(context).setTitle("Home").setFocusedButton(0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          TextButton(
              onPressed: _incrementCounter, child: const Text("Increment"))
        ],
      ),
    );
  }
}

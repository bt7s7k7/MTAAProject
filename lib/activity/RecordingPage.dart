import 'package:flutter/material.dart';
import 'package:mtaa_project/layout/LayoutConfig.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    LayoutConfig.instance.setTitle("Recording").setFocusedButton(1);

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

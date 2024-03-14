import 'package:flutter/material.dart';
import 'package:mtaa_project/layout/LayoutConfig.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    LayoutConfig.of(context).setTitle("Friends").setFocusedButton(2);

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

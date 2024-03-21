import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/layout/ApplicationAppBar.dart';
import 'package:mtaa_project/layout/LayoutConfig.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final layoutConfig = LayoutConfig.instance.bind(context);

    return Scaffold(
      appBar: applicationAppBar(context, layoutConfig.title),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: layoutConfig.focusedButton,
        onTap: (value) {
          router.goNamed(
            switch (value) {
              0 => "Home",
              1 => "Recording",
              2 => "Friends",
              _ => throw Exception("Invalid button number"),
            },
          );
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_checked),
            label: 'Recording',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
        ],
      ),
    );
  }
}

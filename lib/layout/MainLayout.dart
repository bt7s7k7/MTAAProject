import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/layout/ApplicationAppBar.dart';
import 'package:mtaa_project/layout/LayoutConfig.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String _title = "Null Page";
  int _focusedButton = 0;

  void _setTitle(String title) {
    if (title == _title) return;
    Future.microtask(() => setState(() => _title = title));
  }

  void _setFocusedButton(int focusedButton) {
    if (focusedButton == _focusedButton) return;
    Future.microtask(() => setState(() => _focusedButton = focusedButton));
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return Scaffold(
      appBar: applicationAppBar(context, _title),
      body: LayoutConfig(
        onFocusedButtonChanged: _setFocusedButton,
        onTitleChanged: _setTitle,
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _focusedButton,
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

import 'package:flutter/material.dart';
import 'package:mtaa_project/layout/application_app_bar.dart';
import 'package:mtaa_project/support/support.dart';

/// Single layer of the screen stack for [LayoutConfig]
class LayoutConfigEntry {
  LayoutConfigEntry({required this.title, required this.focusedButton});

  final String title;
  final int? focusedButton;
}

/// Stores the title and focused button for open screens. The layers are stored in a stack mirroring the router navigation stack
class LayoutConfig with ChangeNotifier, ChangeNotifierAsync {
  LayoutConfig._();
  static final instance = LayoutConfig._();

  /// All entries of the screen stack
  final List<LayoutConfigEntry> _stack = [];

  /// Adds an entry to the stack
  void addEntry(LayoutConfigEntry entry) {
    _stack.add(entry);
    _updateState();
  }

  /// Replaces the data of the specified entry
  void replaceEntry(LayoutConfigEntry from, LayoutConfigEntry to) {
    var index = _stack.indexOf(from);
    _stack[index] = to;
    _updateState();
  }

  /// Removes the entry from the stack
  void removeEntry(LayoutConfigEntry entry) {
    _stack.remove(entry);
    _updateState();
  }

  /// Getting the most recent values for title and focused button and handles notifying all listeners
  void _updateState() {
    if (_stack.isEmpty) {
      _focusedButton = 0;
      _title = "?";
      notifyListenersAsync();
      return;
    }

    _title = _stack.last.title;
    _focusedButton = _stack.reversed
            .map((e) => e.focusedButton)
            .firstWhere((e) => e != null, orElse: () => null) ??
        0;
    notifyListenersAsync();
  }

  /// Currently focused button in the bottom navigation bar
  int get focusedButton => _focusedButton;
  var _focusedButton = 0;

  /// Currently shown title in the [ApplicationAppBar]
  String get title => _title;
  var _title = "?";
}

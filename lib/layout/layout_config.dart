import 'package:flutter/material.dart';
import 'package:mtaa_project/support/support.dart';

class LayoutConfigEntry {
  LayoutConfigEntry({required this.title, required this.focusedButton});

  final String title;
  final int? focusedButton;
}

class LayoutConfig with ChangeNotifier, ChangeNotifierAsync {
  LayoutConfig._();
  static final instance = LayoutConfig._();

  final List<LayoutConfigEntry> _stack = [];

  void addEntry(LayoutConfigEntry entry) {
    _stack.add(entry);
    _updateState();
  }

  void replaceEntry(LayoutConfigEntry from, LayoutConfigEntry to) {
    var index = _stack.indexOf(from);
    _stack[index] = to;
    _updateState();
  }

  void removeEntry(LayoutConfigEntry entry) {
    _stack.remove(entry);
    _updateState();
  }

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

  int get focusedButton => _focusedButton;
  var _focusedButton = 0;

  String get title => _title;
  var _title = "?";
}

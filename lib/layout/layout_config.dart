import 'package:flutter/material.dart';
import 'package:mtaa_project/support/support.dart';

class LayoutConfig with ChangeNotifier, ChangeNotifierAsync {
  LayoutConfig._();
  static final instance = LayoutConfig._();

  int get focusedButton => _focusedButton;
  var _focusedButton = 0;
  LayoutConfig setFocusedButton(int value) {
    if (_focusedButton == value) return this;
    _focusedButton = value;
    notifyListenersAsync();
    return this;
  }

  String get title => _title;
  var _title = "?";
  LayoutConfig setTitle(String value) {
    if (_title == value) return this;
    _title = value;
    notifyListenersAsync();
    return this;
  }
}

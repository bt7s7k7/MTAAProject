import 'package:flutter/material.dart';

class LayoutConfig extends InheritedWidget {
  const LayoutConfig({
    super.key,
    required this.onFocusedButtonChanged,
    required this.onTitleChanged,
    required super.child,
  });

  final void Function(int) onFocusedButtonChanged;
  final void Function(String) onTitleChanged;

  LayoutConfig setFocusedButton(int button) {
    onFocusedButtonChanged(button);
    return this;
  }

  LayoutConfig setTitle(String title) {
    onTitleChanged(title);
    return this;
  }

  static LayoutConfig? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LayoutConfig>();
  }

  static LayoutConfig of(BuildContext context) {
    final LayoutConfig? result = maybeOf(context);
    assert(result != null, 'No LayoutConfig found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LayoutConfig oldWidget) => false;
}

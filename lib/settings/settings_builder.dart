import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtaa_project/settings/settings.dart';

/// Rebuilds the callback after the specified [SettingProperty] changes
class SettingsBuilder<T> extends StatefulWidget {
  const SettingsBuilder({
    super.key,
    required this.builder,
    required this.property,
  });

  /// Builder for content
  final Widget Function(T value) builder;

  /// Property to be listened to
  final SettingProperty<T> property;

  @override
  State<SettingsBuilder<T>> createState() => _SettingsBuilderState<T>();
}

class _SettingsBuilderState<T> extends State<SettingsBuilder<T>> {
  /// Current value of the specified property
  late T value = widget.property.getValue();
  late StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = widget.property.addListener((newValue) {
      setState(() {
        value = newValue;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(value);
  }
}

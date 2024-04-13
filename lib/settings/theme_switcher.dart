import 'package:flutter/material.dart';
import 'package:mtaa_project/settings/settings.dart';

class SettingsBuilder<T> extends StatefulWidget {
  const SettingsBuilder({
    super.key,
    required this.builder,
    required this.property,
  });

  final Widget Function(T value) builder;
  final SettingProperty<T> property;

  @override
  State<SettingsBuilder<T>> createState() => _SettingsBuilderState<T>();
}

class _SettingsBuilderState<T> extends State<SettingsBuilder<T>> {
  late T value = widget.property.getValue();

  @override
  void initState() {
    super.initState();

    widget.property.addListener((newValue) {
      setState(() {
        value = newValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(value);
  }
}

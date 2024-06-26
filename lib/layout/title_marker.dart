import 'package:flutter/material.dart';
import 'package:mtaa_project/layout/application_app_bar.dart';
import 'package:mtaa_project/layout/layout_config.dart';

/// Registers the current screen with the [LayoutConfig] so the correct title is shown in the [ApplicationAppBar] and/or button is focused in the bottom navigation bar
class TitleMarker extends StatefulWidget {
  const TitleMarker({super.key, required this.title, this.focusedButton});

  final String title;
  final int? focusedButton;

  @override
  State<TitleMarker> createState() => _TitleMarkerState();
}

class _TitleMarkerState extends State<TitleMarker> {
  LayoutConfigEntry? lastEntry;

  @override
  void initState() {
    super.initState();
    lastEntry = LayoutConfigEntry(
      title: widget.title,
      focusedButton: widget.focusedButton,
    );
    LayoutConfig.instance.addEntry(lastEntry!);
  }

  @override
  void didUpdateWidget(TitleMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    var newEntry = LayoutConfigEntry(
      title: widget.title,
      focusedButton: widget.focusedButton,
    );

    LayoutConfig.instance.replaceEntry(lastEntry!, newEntry);
    lastEntry = newEntry;
  }

  @override
  void dispose() {
    super.dispose();
    LayoutConfig.instance.removeEntry(lastEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 0, height: 0);
  }
}

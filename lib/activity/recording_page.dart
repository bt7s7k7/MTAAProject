import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/support.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  void _createActivity() async {
    var random = Random();
    await ActivityAdapter.instance.uploadActivity(
      Activity.fromRecording(
        name: "New Activity",
        steps: random.nextInt(1000) + 1000,
        distance: random.nextInt(1000) + 10,
        duration: random.nextInt(5000),
        path: "",
      ),
    );

    if (!mounted) return;

    popupResult(context, "Activity created");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListenableBuilder(
          listenable: LanguageManager.instance,
          builder: (_, __) => TitleMarker(
            title: LanguageManager.instance.language.recording(),
            focusedButton: 1,
          ),
        ),
        FilledButton.tonal(
          onPressed: _createActivity,
          child: const Text("Create activity"),
        )
      ],
    );
  }
}

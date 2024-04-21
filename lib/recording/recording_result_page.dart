import 'package:flutter/material.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/recording/activity_tracker.dart';
import 'package:mtaa_project/recording/map_view.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class RecordingResultPage extends StatefulWidget {
  const RecordingResultPage({super.key, required this.tracker});

  final ActivityTracker tracker;

  @override
  State<RecordingResultPage> createState() => _RecordingResultPageState();
}

class _RecordingResultPageState extends State<RecordingResultPage> {
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
        Expanded(
          child: MapView(
            path: widget.tracker.path,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListenableBuilder(
                listenable: widget.tracker,
                builder: (_, __) => Text(
                  LanguageManager.instance.language.recordingInfo(
                    steps: widget.tracker.steps.toString(),
                    meters: widget.tracker.distance.floor().toString(),
                    duration:
                        "${(widget.tracker.duration / 60).floor().toString().padLeft(2, "0")}:${(widget.tracker.duration.floor() % 60).toString().padLeft(2, "0")}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

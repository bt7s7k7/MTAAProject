import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/recording/activity_tracker.dart';
import 'package:mtaa_project/recording/map_view.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final tracker = ActivityTracker();

  @override
  void dispose() {
    tracker.dispose();
    super.dispose();
  }

  void _updateLocation(GeoPoint location) {
    tracker.appendLocation(location);
  }

  Future<void> _pause() async {
    tracker.paused = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LanguageManager.instance.language.recordingPaused()),
          content:
              Text(LanguageManager.instance.language.recordingPausedDesc()),
          actions: <Widget>[
            TextButton(
              child: Text(LanguageManager.instance.language.unpauseRecording()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    tracker.paused = false;
  }

  void _finish() {
    ActivityAdapter.instance.uploadActivity(
      Activity.fromRecording(
        name: LanguageManager.instance.language.recording(),
        steps: tracker.steps,
        distance: tracker.distance.floor(),
        duration: tracker.duration.floor(),
        path: tracker.path,
      ),
    );

    GoRouter.of(context).goNamed("RecordingResult", extra: tracker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              key: mapGlobalKey,
              onLocationUpdate: _updateLocation,
              tracker: tracker,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListenableBuilder(
              listenable: LanguageManager.instance,
              builder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListenableBuilder(
                    listenable: tracker,
                    builder: (_, __) => Text(
                      LanguageManager.instance.language.recordingInfo(
                        steps: tracker.steps.toString(),
                        meters: tracker.distance.floor().toString(),
                        duration:
                            "${(tracker.duration / 60).floor().toString().padLeft(2, "0")}:${(tracker.duration.floor() % 60).toString().padLeft(2, "0")}",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _finish,
                          child: Text(
                            LanguageManager.instance.language.endRecording(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _pause,
                          child: Text(
                            LanguageManager.instance.language.pauseRecording(),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

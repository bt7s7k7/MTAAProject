import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
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
                            "${(tracker.duration / 60).floor().toString().padLeft(2, "0")}:${(tracker.duration % 60).toString().padLeft(2, "0")}",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
                          child: Text(
                            LanguageManager.instance.language.endRecording(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {},
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

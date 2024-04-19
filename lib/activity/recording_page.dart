import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/support.dart';


class RecordingPage extends StatefulWidget {
  const RecordingPage({Key? key}) : super(key: key);

  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final GlobalKey mapGlobalKey = GlobalKey();

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
        Expanded(
          child: OSMFlutter(
            key: mapGlobalKey,
            trackMyPosition: false,
            initZoom: 12,
            minZoomLevel: 8,
            maxZoomLevel: 14,
            stepZoom: 1.0,
            staticPoints: [
              StaticPositionGeoPoint(
                'id_0',
                MarkerIcon(
                  icon: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                GeoPoint(latitude: 48.8584, longitude: 2.2945), // Example location (Eiffel Tower)
              ),
            ],
            roadConfiguration: RoadConfiguration(
              startIcon: MarkerIcon(
                icon: Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.green,
                ),
              ),
              roadColor: Colors.yellowAccent,
            ),
          ),
        ),
        ListenableBuilder(
          listenable: LanguageManager.instance,
          builder: (_, __) => TitleMarker(
            title: LanguageManager.instance.language.recording(),
            focusedButton: 1,
          ),
        ),
        ElevatedButton(
          onPressed: _createActivity,
          child: const Text("Create activity"),
        ),
      ],
    );
  }
}

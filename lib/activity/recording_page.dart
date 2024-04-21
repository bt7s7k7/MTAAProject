import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool ready = false;

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

  MapController mapController = MapController(
    initPosition:
        GeoPoint(latitude: 48.11977120843681, longitude: 17.118147610953137),
  );

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    mapController.setZoom(zoomLevel: 40);
  }

  void _setReady() {
    setState(() {
      ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var map = OSMFlutter(
      controller: mapController,
      onMapIsReady: (ready) {
        if (ready) _setReady();
      },
      osmOption: const OSMOption(
        showContributorBadgeForOSM: true,
        zoomOption: ZoomOption(
          initZoom: 15,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        enableRotationByGesture: false,
        roadConfiguration: RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
    );

    var theme = Theme.of(context);

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
            child: Stack(
          children: switch (ready) {
            true => [map],
            false => [
                map,
                Container(
                  decoration:
                      BoxDecoration(color: theme.colorScheme.background),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        value: null,
                      ),
                      const SizedBox(height: 10),
                      ListenableBuilder(
                        listenable: LanguageManager.instance,
                        builder: (_, __) => Text(
                            LanguageManager.instance.language.loadingMap()),
                      ),
                    ],
                  ),
                )
              ],
          },
        )),
        ListenableBuilder(
            listenable: PermissionService.instance,
            builder: (_, __) => switch (PermissionService
                    .instance.activityRecognition.status.isGranted) {
                  true => const SizedBox(height: 0),
                  false => Card(
                      child: ListenableBuilder(
                        listenable: LanguageManager.instance,
                        builder: (_, __) => ListTile(
                          title: Text(
                            LanguageManager.instance.language
                                .stepCountingPermission(),
                          ),
                          subtitle: Text(
                            LanguageManager.instance.language
                                .stepCountingPermissionRequired(),
                          ),
                          leading: const Icon(Icons.directions_walk),
                          trailing: FilledButton(
                            onPressed: PermissionService
                                .instance.activityRecognition.request,
                            child: Text(LanguageManager.instance.language
                                .grantPermission()),
                          ),
                        ),
                      ),
                    ),
                }),
        ElevatedButton(
          onPressed: _createActivity,
          child: const Text("Create activity"),
        ),
      ],
    );
  }
}

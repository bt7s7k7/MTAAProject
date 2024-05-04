import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/recording/map_view.dart';
import 'package:mtaa_project/recording/recording_page.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

/// Sets up permissions and allows the user to start recording an activity
class RecordingSetupPage extends StatefulWidget {
  const RecordingSetupPage({super.key});

  @override
  State<RecordingSetupPage> createState() => _RecordingSetupPageState();
}

class _RecordingSetupPageState extends State<RecordingSetupPage> {
  /// Current location found by the map
  GeoPoint? location;

  /// Stop building map widget after router navigation to prevent it being two places at once
  var unmountMap = false;

  /// Start activity recording by redirecting to the [RecordingPage]
  void _beginActivity() {
    setState(() {
      unmountMap = true;
    });
    GoRouter.of(context).goNamed("RecordingActive");
  }

  /// Handles a new location found by the map
  void _updateLocation(GeoPoint newLocation) async {
    setState(() {
      location = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget permissionRequest(
        {required PermissionHandle handle,
        required String Function() name,
        required String Function() subtitle,
        required IconData icon,
        Widget success = const SizedBox(height: 0)}) {
      return ListenableBuilder(
        listenable: PermissionService.instance,
        builder: (_, __) => switch (handle.isGranted) {
          true => success,
          false => Card(
              child: ListenableBuilder(
                listenable: LanguageManager.instance,
                builder: (_, __) => ListTile(
                  title: Text(name()),
                  subtitle: Text(subtitle()),
                  leading: Icon(icon),
                  trailing: FilledButton(
                    onPressed: handle.request,
                    child: Text(
                        LanguageManager.instance.language.grantPermission()),
                  ),
                ),
              ),
            ),
        },
      );
    }

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
          child: unmountMap
              ? const SizedBox()
              : MapView(
                  key: mapGlobalKey,
                  onLocationUpdate: _updateLocation,
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              permissionRequest(
                handle: PermissionService.instance.activityRecognition,
                name: () =>
                    LanguageManager.instance.language.stepCountingPermission(),
                subtitle: () => LanguageManager.instance.language
                    .stepCountingPermissionRequired(),
                icon: Icons.directions_walk,
              ),
              permissionRequest(
                  handle: PermissionService.instance.location,
                  name: () =>
                      LanguageManager.instance.language.locationPermission(),
                  subtitle: () => LanguageManager.instance.language
                      .locationPermissionRequired(),
                  icon: Icons.location_on,
                  success: Text(
                      "${LanguageManager.instance.language.currentLocation()}: ${location == null ? LanguageManager.instance.language.locationSearching() : "(${location!.latitude.toStringAsFixed(4)}, ${location!.longitude.toStringAsFixed(4)})"}")),
              ListenableBuilder(
                listenable: LanguageManager.instance,
                builder: (_, __) => ListenableBuilder(
                  listenable: PermissionService.instance,
                  builder: (_, __) => FilledButton(
                    onPressed: switch (PermissionService
                            .instance.activityRecognition.isGranted &&
                        PermissionService.instance.location.isGranted &&
                        location != null) {
                      true => _beginActivity,
                      false => null
                    },
                    child: Text(
                        LanguageManager.instance.language.beginRecording()),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

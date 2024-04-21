import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/recording/map_view.dart';
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
    Widget permissionRequest(
        {required PermissionHandle handle,
        required String Function() name,
        required String Function() subtitle,
        required IconData icon}) {
      return ListenableBuilder(
        listenable: PermissionService.instance,
        builder: (_, __) => switch (handle.status.isGranted) {
          true => const SizedBox(height: 0),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListenableBuilder(
          listenable: LanguageManager.instance,
          builder: (_, __) => TitleMarker(
            title: LanguageManager.instance.language.recording(),
            focusedButton: 1,
          ),
        ),
        const Expanded(child: MapView()),
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
              ListenableBuilder(
                listenable: LanguageManager.instance,
                builder: (_, __) => FilledButton(
                  onPressed: _createActivity,
                  child:
                      Text(LanguageManager.instance.language.beginRecording()),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

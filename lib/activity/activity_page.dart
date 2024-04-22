import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/friends/user_view.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/recording/map_view.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/support.dart';


class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.activityId});

  final int activityId;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late Activity activity;
  var ready = false;

  late StreamSubscription<UpdateEvent> updateSubscription;

  void _loadActivity() async {
    var loadedActivity = await ActivityAdapter.instance
        .getActivity(widget.activityId.toString());
    setState(() {
      activity = loadedActivity;
      ready = true;
    });
  }

  void _deleteActivity() async {
    if (OfflineService.instance.isOffline) {
      popupResult(
        context,
        LanguageManager.instance.language.actionRequiredOnline(),
      );
      return;
    }

    var delete = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(LanguageManager.instance.language.confirmActivityDeletion()),
          content: Text(
              LanguageManager.instance.language.confirmActivityDeletionDesc()),
          actions: <Widget>[
            TextButton(
              child: Text(LanguageManager.instance.language.delete()),
              onPressed: () {
                delete = true;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(LanguageManager.instance.language.cancel()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (!delete) return;
    router.goNamed("Home");

    await ActivityAdapter.instance.deleteActivity(activity);
  }

  @override
  void initState() {
    super.initState();

    _loadActivity();
    updateSubscription = UpdateService.instance.addListener((event) {
      if (!ready) return;
      if (event.type != "activity") return;
      if (event.id != widget.activityId) return;
      if (event.value == null) return;

      activity.patchUpdate(event.value!);
      setState(() {
        activity = Activity.fromJson(event.value!);
      });
    });
  }

  @override
  void dispose() {
    updateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        ListenableBuilder(
          listenable: LanguageManager.instance,
          builder: (_, __) => TitleMarker(
            title: LanguageManager.instance.language.activity(),
          ),
        ),
        Expanded(
            child: switch (activity.path != null) {
          true => MapView(
              path: activity.path!,
            ),
          false => ListenableBuilder(
              listenable: LanguageManager.instance,
              builder: (_, __) => Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Card(
                    child: ListTile(
                      title:
                          Text(LanguageManager.instance.language.mapOffline()),
                      subtitle:
                          Text(LanguageManager.instance.language.offlineDesc()),
                      leading: const Icon(Icons.public_off_outlined),
                    ),
                  ),
                ),
              ),
            ),
        }),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                LanguageManager.instance.language.recordingInfo(
                  steps: activity.steps.toString(),
                  meters: activity.distance.toString(),
                  duration:
                      "${(activity.duration / 60).floor().toString().padLeft(2, "0")}:${(activity.duration % 60).toString().padLeft(2, "0")}",
                ),
              ),
              UserView(
                title: activity.user.fullName,
                icon: activity.user.icon,
                subtitle: LanguageManager.instance.language.dateFormat
                    .format(activity.createdAt),
                onClick: () {
                  if (activity.user.id == AuthAdapter.instance.user!.id) {
                    router.pushNamed("Profile");
                  } else {
                    router.pushNamed("Friend", extra: activity.user);
                  }
                },
                action: switch (
                    activity.user.id == AuthAdapter.instance.user!.id) {
                  true => IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteActivity,
                    ),
                  false => null
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}

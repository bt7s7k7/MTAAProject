import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_view.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/support/support.dart';

class ActivityList extends StatefulWidget {
  const ActivityList(
      {super.key, required this.getter, this.useListView = true});

  final Future<List<Activity>> Function() getter;
  final bool useListView;

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  List<Activity> _activities = [];
  StreamSubscription<UpdateEvent>? _subscription;

  Future<void> _loadActivities() async {
    var activitiesResult = await widget.getter();
    setState(() {
      _activities = activitiesResult;
    });
  }

  @override
  void initState() {
    super.initState();

    OfflineService.instance.addListener(_loadActivities);

    _subscription = UpdateService.instance.addListener((event) {
      if (event.type != "activity") return;
      updateList(
        event: event,
        list: _activities,
        idGetter: (activity) => activity.id,
        factory: (json) => Activity.fromJson(json),
        callback: setState,
      );
    });

    _loadActivities();
  }

  @override
  void dispose() {
    OfflineService.instance.removeListener(_loadActivities);

    _subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var children = _activities
        .map((activity) => ActivityView(activity: activity))
        .toList();

    if (widget.useListView) {
      return ListView(children: children);
    } else {
      return Column(children: children);
    }
  }
}

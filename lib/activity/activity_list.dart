import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_view.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/support/support.dart';

/// Displays a list of activities based on a getter
class ActivityList extends StatefulWidget {
  const ActivityList(
      {super.key, required this.getter, this.useListView = true});

  /// Getter for activities
  final Future<List<Activity>> Function() getter;

  /// Should the displayed activities be wrapped in a list view (`true` by default)
  final bool useListView;

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  /// Loaded activities
  List<Activity> _activities = [];

  /// Subscription to [UpdateService] to get updates on activities, disposed on dispose
  StreamSubscription<UpdateEvent>? _subscription;

  /// Loads the activities using the getter
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

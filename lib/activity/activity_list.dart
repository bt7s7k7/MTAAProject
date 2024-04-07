import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_view.dart';

class ActivityList extends StatefulWidget {
  const ActivityList({
    super.key,
    required this.getter,
  });

  final Future<List<Activity>> Function() getter;

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  List<Activity> _activities = [];

  Future<void> _searchUsers() async {
    var activitiesResult = await widget.getter();
    setState(() {
      _activities = activitiesResult;
    });
  }

  @override
  void initState() {
    super.initState();

    _searchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: _activities
            .map((activity) => ActivityView(activity: activity))
            .toList());
  }
}

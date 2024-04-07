import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({
    super.key,
    required this.getter,
  });

  final Future<List<Activity>> Function() getter;

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
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
            .map((activity) => _ActivityView(activity: activity))
            .toList());
  }
}

class _ActivityView extends StatelessWidget {
  const _ActivityView({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(activity.activityName)],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("${activity.points} steps")],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/activity/activity_list.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/user/user.dart';

class UserActivity extends StatelessWidget {
  const UserActivity({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    var auth = AuthAdapter.instance;
    return ActivityList(
      getter: () => ActivityAdapter.instance.getUserActivities(auth.user!.id),
      useListView: false,
    );
  }
}

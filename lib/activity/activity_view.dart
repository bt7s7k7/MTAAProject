import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/user/user_icon.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormat.yMd();
    var date = dateFormatter.format(activity.createdAt.toLocal());
    var distance = activity.distance < 1000
        ? "${activity.distance} m"
        : activity.distance < 10000
            ? "${(activity.distance / 1000).toStringAsFixed(2)} km"
            : "${activity.distance} km";

    return Card(
      child: ListTile(
        leading: UserIcon(icon: activity.user.icon),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(activity.activityName)],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${activity.user.fullName} $distance / ${activity.points} steps",
            ),
            const Spacer(),
            Text(date)
          ],
        ),
      ),
    );
  }
}

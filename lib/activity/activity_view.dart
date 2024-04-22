import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user_icon.dart';

/// Displays an activity in a list
class ActivityView extends StatelessWidget {
  const ActivityView({super.key, required this.activity});

  /// Adds or removes a like from the activity based on current [Activity.hasLiked]
  void _toggleLike(context) {
    var user = AuthAdapter.instance.user;
    var language = LanguageManager.instance.language;
    if (user?.id == activity.user.id) {
      popupResult(context, language.cannotLikeOwnActivity());
      return;
    }

    if (OfflineService.instance.isOffline) {
      popupResult(context, language.actionRequiredOnline());
      return;
    }

    if (activity.hasLiked) {
      ActivityAdapter.instance.unlikeActivity(activity);
      activity.hasLiked = false;
    } else {
      ActivityAdapter.instance.likeActivity(activity);
      activity.hasLiked = true;
    }
  }

  /// The activity to show
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    var distance = activity.distance < 1000
        ? "${activity.distance} m"
        : activity.distance < 10000
            ? "${(activity.distance / 1000).toStringAsFixed(2)} km"
            : "${activity.distance} km";

    var router = GoRouter.of(context);

    return Card(
      child: InkWell(
        onTap: () {
          router.pushNamed("Activity", extra: activity.id);
        },
        child: ListTile(
          leading: UserIcon(icon: activity.user.icon),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(activity.activityName),
              const Spacer(),
              IconButton(
                onPressed: () => _toggleLike(context),
                icon: Icon(switch (activity.hasLiked) {
                  true => Icons.thumb_up,
                  false => Icons.thumb_up_outlined,
                }),
              ),
              Text(activity.likesCount.toString()),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListenableBuilder(
                listenable: LanguageManager.instance,
                builder: (_, __) => Text(LanguageManager.instance.language
                    .activitySubtitle(
                        userName: activity.user.fullName,
                        distance: distance,
                        steps: activity.steps)),
              ),
              const Spacer(),
              ListenableBuilder(
                listenable: LanguageManager.instance,
                builder: (_, __) => Text(LanguageManager
                    .instance.language.dateFormat
                    .format(activity.createdAt)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

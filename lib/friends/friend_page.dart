import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/user_activity.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/friends/friends_adapter.dart';
import 'package:mtaa_project/friends/friends_page.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/user/user.dart';
import 'package:mtaa_project/user/user_header.dart';

/// Page displaying the profile of a friended user
class FriendPage extends StatelessWidget {
  const FriendPage({super.key, required this.user});

  /// Removes the user from current user friends and redirects back to [FriendsPage]
  void _removeFriend() async {
    await FriendsAdapter.instance.removeFriend(user);
    router.goNamed("Friends");
  }

  /// The user being displayed
  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          UserHeader(user: user),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => ListTile(
              title:
                  Text(LanguageManager.instance.language.removeFriendAction()),
              onTap: _removeFriend,
            ),
          ),
          const SizedBox(height: 10),
          UserActivity(user: user)
        ],
      ),
    );
  }
}

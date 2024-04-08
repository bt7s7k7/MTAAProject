import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/user_activity.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/friends/friends_adapter.dart';
import 'package:mtaa_project/user/user.dart';
import 'package:mtaa_project/user/user_header.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({super.key, required this.user});

  void _removeFriend() async {
    await FriendsAdapter.instance.removeFriend(user);
    router.goNamed("Friends");
  }

  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          UserHeader(user: user),
          const SizedBox(height: 10),
          ListTile(
            title: const Text("Remove friend"),
            onTap: _removeFriend,
          ),
          const SizedBox(height: 10),
          UserActivity(user: user)
        ],
      ),
    );
  }
}

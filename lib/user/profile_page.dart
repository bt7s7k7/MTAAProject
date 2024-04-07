import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/user_activity.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/layout/layout_config.dart';
import 'package:mtaa_project/user/user_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _logOut() {
    AuthAdapter.instance.logOut();
  }

  @override
  Widget build(BuildContext context) {
    LayoutConfig.instance.setTitle("Profile");

    var auth = AuthAdapter.instance;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          UserHeader(user: auth.user!),
          const SizedBox(height: 10),
          ListTile(
            title: const Text("Log out"),
            onTap: _logOut,
          ),
          const SizedBox(height: 10),
          UserActivity(user: auth.user!)
        ],
      ),
    );
  }
}

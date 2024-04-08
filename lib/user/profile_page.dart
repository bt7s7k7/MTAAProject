import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/user_activity.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
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
    var auth = AuthAdapter.instance;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => TitleMarker(
              title: LanguageManager.instance.language.profile(),
            ),
          ),
          UserHeader(user: auth.user!),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => ListTile(
              title: Text(LanguageManager.instance.language.logOutAction()),
              onTap: _logOut,
            ),
          ),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => ListTile(
              title: Text(LanguageManager.instance.language.language()),
              trailing: DropdownButton(
                items: LanguageManager.instance
                    .getAvailableLanguages()
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                value: LanguageManager.instance.language.code,
                onChanged: (value) =>
                    LanguageManager.instance.setLanguage(value!),
              ),
            ),
          ),
          const SizedBox(height: 10),
          UserActivity(user: auth.user!)
        ],
      ),
    );
  }
}

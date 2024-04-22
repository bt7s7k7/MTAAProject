import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/user_activity.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/services/notification_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/settings/settings_builder.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user_header.dart';
import 'package:mtaa_project/user/user_settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _logOut() {
    AuthAdapter.instance.logOut();
  }

  void _accountSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UserSettings()),
    );
  }

  Future<void> _setNotificationEnabled(bool enabled) async {
    if (Settings.instance.notificationsEnabled.getValue()) {
      await NotificationService.instance.disableNotifications();
      return;
    }

    try {
      await NotificationService.instance.enableNotifications();
    } on UserException catch (err) {
      if (!mounted) return;
      popupResult(context, err.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    var auth = AuthAdapter.instance;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => TitleMarker(
              title: LanguageManager.instance.language.profile(),
            ),
          ),
          ListenableBuilder(
            listenable: auth,
            builder: (_, __) => UserHeader(user: auth.user!),
          ),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: OfflineService.instance,
            builder: (_, __) => switch (OfflineService.instance.isOnline) {
              true => ListenableBuilder(
                  listenable: LanguageManager.instance,
                  builder: (_, __) => ListTile(
                    title: Text(
                        LanguageManager.instance.language.accountSettings()),
                    onTap: _accountSettings,
                  ),
                ),
              false => const SizedBox()
            },
          ),
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
                    .map((language) => DropdownMenuItem(
                          value: language.code,
                          child: Text(language.label),
                        ))
                    .toList(),
                value: LanguageManager.instance.language.code,
                onChanged: (value) =>
                    LanguageManager.instance.setLanguage(value!),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => SettingsBuilder(
              property: Settings.instance.darkTheme,
              builder: (darkTheme) => ListTile(
                title: Text(LanguageManager.instance.language.darkTheme()),
                trailing: Checkbox(
                  value: darkTheme,
                  onChanged: (value) =>
                      Settings.instance.darkTheme.setValue(value ?? false),
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => SettingsBuilder(
              property: Settings.instance.notificationsEnabled,
              builder: (notificationsEnabled) => ListTile(
                title: Text(LanguageManager.instance.language.notifications()),
                trailing: Checkbox(
                  value: notificationsEnabled,
                  onChanged: (value) => _setNotificationEnabled(value ?? false),
                ),
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

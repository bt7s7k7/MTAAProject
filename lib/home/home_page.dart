import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/activity/activity_list.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/home/home_level_display.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              title: LanguageManager.instance.language.home(),
              focusedButton: 0,
            ),
          ),
          ListenableBuilder(
            listenable: auth,
            builder: (_, __) => Text("User: ${jsonEncode(auth.user)}"),
          ),
          const HomeLevelDisplay(),
          ActivityList(
            getter: ActivityAdapter.instance.getHomeActivities,
            useListView: false,
          ),
        ],
      ),
    );
  }
}

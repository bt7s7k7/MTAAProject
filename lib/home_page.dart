import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/activity/activity_list.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var auth = AuthAdapter.instance;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
          Expanded(
            child: ActivityList(
              getter: ActivityAdapter.instance.getHomeActivities,
            ),
          ),
        ],
      ),
    );
  }
}

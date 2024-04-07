import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/activity/activity_list.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/layout/layout_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    LayoutConfig.instance.setTitle("Home").setFocusedButton(0);

    var auth = AuthAdapter.instance;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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

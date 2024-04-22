import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/activity/activity_list.dart';
import 'package:mtaa_project/home/home_level_display.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/offline_mode/offline_warning.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
          const HomeLevelDisplay(),
          OfflineWarning(
            label: () =>
                LanguageManager.instance.language.homeActivityOffline(),
          ),
          ActivityList(
            getter: ActivityAdapter.instance.getHomeActivities,
            useListView: false,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/user/level_adapter.dart';
import 'package:mtaa_project/user/level_image.dart';
import 'package:mtaa_project/user/user.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    var level = LevelAdapter.instance.getUserLevel(user);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Image.network(
            user.icon == null
                ? defaultUserIcon
                : backendURL.resolve(user.icon!).toString(),
            fit: BoxFit.cover,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              ListTile(
                title: Text(user.fullName),
                subtitle: ListenableBuilder(
                  listenable: LanguageManager.instance,
                  builder: (_, __) => Text(
                    LanguageManager.instance.language
                        .userPoints(points: user.points),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: LevelImage(level: level),
        ),
      ],
    );
  }
}

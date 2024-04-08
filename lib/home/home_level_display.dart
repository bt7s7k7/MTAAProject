import 'package:flutter/material.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/user/level_adapter.dart';
import 'package:mtaa_project/user/level_image.dart';

class HomeLevelDisplay extends StatelessWidget {
  const HomeLevelDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var user = AuthAdapter.instance.user!;
    var level = LevelAdapter.instance.getUserLevel(user);
    var nextLevel = LevelAdapter.instance.getNextLevel(level);

    var theme = Theme.of(context);
    var maskColor =
        Color.lerp(theme.cardColor, theme.colorScheme.surfaceTint, 0.05);

    return Card(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 5.5,
                child: CircularProgressIndicator(
                  value: (user.points as double) / nextLevel.pointsRequired,
                ),
              ),
              const SizedBox(width: 250, height: 250),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: maskColor,
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: LevelImage(level: level),
              ),
            ],
          ),
          Text("${user.points} / ${nextLevel.pointsRequired}"),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => Text(
              LanguageManager.instance.language.ofSteps(),
            ),
          ),
          const SizedBox(width: 10, height: 10)
        ],
      ),
    );
  }
}

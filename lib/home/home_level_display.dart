import 'package:flutter/material.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/user/level_adapter.dart';
import 'package:mtaa_project/user/level_image.dart';

class HomeLevelDisplay extends StatelessWidget {
  const HomeLevelDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var maskColor =
        Color.lerp(theme.cardColor, theme.colorScheme.surfaceTint, 0.05);
    var bgColor =
        Color.lerp(theme.cardColor, theme.colorScheme.surfaceTint, 0.2);

    return Card(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                ),
              ),
              Transform.scale(
                scale: 5.5,
                child: ListenableBuilder(
                  listenable: AuthAdapter.instance,
                  builder: (_, __) => CircularProgressIndicator(
                    value: (AuthAdapter.instance.user!.points.toDouble()) /
                        LevelAdapter.instance
                            .getNextLevel(LevelAdapter.instance
                                .getUserLevel(AuthAdapter.instance.user!))
                            .pointsRequired,
                  ),
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
              ListenableBuilder(
                listenable: AuthAdapter.instance,
                builder: (_, __) => SizedBox(
                  width: 100,
                  height: 100,
                  child: LevelImage(
                      level: LevelAdapter.instance
                          .getUserLevel(AuthAdapter.instance.user!)),
                ),
              ),
            ],
          ),
          ListenableBuilder(
            listenable: AuthAdapter.instance,
            builder: (_, __) => Text(
                "${AuthAdapter.instance.user!.points} / ${LevelAdapter.instance.getNextLevel(LevelAdapter.instance.getUserLevel(AuthAdapter.instance.user!)).pointsRequired}"),
          ),
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

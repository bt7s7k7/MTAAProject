import 'package:flutter/material.dart';
import 'package:mtaa_project/user/level.dart';

class LevelImage extends StatelessWidget {
  const LevelImage({super.key, required this.level});

  final Level level;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage("assets/levels/${level.name}.png"),
    );
  }
}

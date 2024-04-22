import 'dart:convert';

import 'package:http/http.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/user/level.dart';
import 'package:mtaa_project/user/user.dart';

class LevelAdapter {
  LevelAdapter._();
  static final instance = LevelAdapter._();

  List<Level> _levels = [];
  final Map<int, Level> _levelsLookup = {};

  Future<void> load() async {
    var data = await OfflineService.instance.networkRequestWithFallback(
      request: () => get(backendURL.resolve("/levels")),
      fallback: () {
        var cachedLevels = Settings.instance.cachedLevels.getValue();
        if (cachedLevels == null) throw OnlineInitRequired();
        return jsonDecode(cachedLevels);
      },
    );

    var levels = switch (data) {
      {"items": List<dynamic> levelsData} =>
        levelsData.map((e) => Level.fromJson(e)).toList(),
      _ => throw APIError("Invalid fields for levels $data")
    };

    if (OfflineService.instance.isOnline) {
      await Settings.instance.cachedLevels.setValue(jsonEncode(data));
    }

    _levels = levels;

    for (final level in _levels) {
      _levelsLookup[level.id] = level;
    }
  }

  Level? getUserLevel(User user) {
    if (user.levelId == null) return null;
    return _levelsLookup[user.levelId]!;
  }

  Level getNextLevel(Level? level) {
    if (level == null) {
      return _levels[0];
    }

    var index = _levels.indexOf(level);
    var nextLevel =
        index >= _levels.length - 1 ? _levels.last : _levels[index + 1];
    return nextLevel;
  }
}

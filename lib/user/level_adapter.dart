import 'package:http/http.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/level.dart';
import 'package:mtaa_project/user/user.dart';

class LevelAdapter {
  LevelAdapter._();
  static final instance = LevelAdapter._();

  List<Level> _levels = [];
  final Map<int, Level> _levelsLookup = {};

  Future<void> load() async {
    var result = await get(backendURL.resolve("/levels"));

    var data = processHTTPResponse(result);
    var levels = switch (data) {
      {"items": List<dynamic> levelsData} =>
        levelsData.map((e) => Level.fromJson(e)).toList(),
      _ => throw APIError("Invalid fields for levels $data")
    };

    _levels = levels;
    for (final level in _levels) {
      _levelsLookup[level.id] = level;
    }
  }

  Level getUserLevel(User user) {
    return _levelsLookup[user.levelId]!;
  }

  Level getNextLevel(Level level) {
    var index = _levels.indexOf(level);
    var nextLevel =
        index >= _levels.length - 1 ? _levels.last : _levels[index + 1];
    return nextLevel;
  }
}

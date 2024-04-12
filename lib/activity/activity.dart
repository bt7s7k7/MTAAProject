import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/user/user.dart';

class Activity {
  Activity({
    required this.id,
    required this.user,
    required this.activityName,
    required this.points,
    required this.steps,
    required this.distance,
    required this.duration,
    required this.path,
    required this.createdAt,
  });

  final int id;
  final User user;
  final String activityName;
  final int points;
  final int steps;
  final int distance;
  final int duration;
  final String path;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        "userId": user.id,
        "activityName": activityName,
        "points": points,
        "steps": steps,
        "distance": distance,
        "duration": duration,
        "path": path,
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("path")) json["path"] = null;
    return switch (json) {
      {
        "id": int id,
        "user": Map<String, dynamic> user,
        "activityName": String activityName,
        "points": int points,
        "steps": int steps,
        "distance": int distance,
        "duration": int duration,
        "path": String? path,
        "createdAt": String createdAt,
      } =>
        Activity(
          id: id,
          user: User.fromJson(user),
          activityName: activityName,
          points: points,
          steps: steps,
          distance: distance,
          duration: duration,
          path: path ?? "",
          createdAt: DateTime.parse(createdAt),
        ),
      _ => throw APIError("Invalid fields to load an Activity: $json")
    };
  }

  factory Activity.fromRecording({
    required String name,
    required int steps,
    required int distance,
    required int duration,
    required String path,
  }) {
    return Activity(
      id: 0,
      user: AuthAdapter.instance.user!,
      activityName: name,
      points: steps,
      steps: steps,
      distance: distance,
      duration: duration,
      path: path,
      createdAt: DateTime.now(),
    );
  }
}

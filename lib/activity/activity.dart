import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/services/update_aware.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/user/user.dart';

class Activity with UpdateAware {
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
    required this.likesCount,
    required this.hasLiked,
  });

  final int id;
  final User user;
  final String activityName;
  final int points;
  final int steps;
  final int distance;
  final int duration;
  final List<GeoPoint>? path;
  final DateTime createdAt;
  final int likesCount;
  bool hasLiked;

  Map<String, dynamic> toJson() => {
        "userId": user.id,
        "activityName": activityName,
        "points": points,
        "steps": steps,
        "distance": distance,
        "duration": duration,
        "path": path == null ? "" : encodePath(path!),
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
        "likesCount": int likesCount,
        "hasLiked": bool hasLiked,
      } =>
        Activity(
          id: id,
          user: User.fromJson(user),
          activityName: activityName,
          points: points,
          steps: steps,
          distance: distance,
          duration: duration,
          path: path == null || path.isEmpty ? null : decodePath(path),
          createdAt: DateTime.parse(createdAt),
          likesCount: likesCount,
          hasLiked: hasLiked,
        ),
      _ => throw APIError("Invalid fields to load an Activity: $json")
    };
  }

  factory Activity.fromRecording({
    required String name,
    required int steps,
    required int distance,
    required int duration,
    required List<GeoPoint> path,
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
      likesCount: 0,
      hasLiked: false,
    );
  }

  @override
  void patchUpdate(Map<String, dynamic> json) {
    json["hasLiked"] = hasLiked;
    if (path != null) json["path"] = encodePath(path!);
  }

  static String encodePath(List<GeoPoint> path) {
    var pathNumbers = Float64List(path.length * 2);
    for (var i = 0; i < path.length; i++) {
      var point = path[i];
      pathNumbers[i * 2 + 0] = point.latitude;
      pathNumbers[i * 2 + 1] = point.longitude;
    }
    var data = pathNumbers.buffer.asUint8List();
    return base64.encode(data);
  }

  static List<GeoPoint> decodePath(String rawData) {
    try {
      var data = base64.decode(rawData);
      var pathNumbers = data.buffer.asFloat64List();
      var path = List<GeoPoint>.filled((pathNumbers.length / 2).floor(),
          GeoPoint(latitude: 0, longitude: 0));
      for (var i = 0; i < path.length; i++) {
        path[i] = GeoPoint(
          latitude: pathNumbers[i * 2 + 0],
          longitude: pathNumbers[i * 2 + 1],
        );
      }
      return path;
    } catch (_) {
      return [];
    }
  }
}

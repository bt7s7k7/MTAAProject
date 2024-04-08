import 'package:mtaa_project/support/exceptions.dart';

class Level {
  Level({required this.id, required this.name, required this.pointsRequired});

  final int id;
  final String name;
  final int pointsRequired;

  factory Level.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int id,
        "name": String name,
        "pointsRequired": int pointsRequired,
      } =>
        Level(
          id: id,
          name: name,
          pointsRequired: pointsRequired,
        ),
      _ => throw APIError("Invalid field for level $json")
    };
  }
}

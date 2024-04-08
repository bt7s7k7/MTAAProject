import 'package:flutter/material.dart';
import 'package:mtaa_project/support/exceptions.dart';

@immutable
class User {
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.icon,
    required this.points,
    required this.levelId,
  });

  final int id;
  final String email;
  final String fullName;
  final String? icon;
  final int points;
  final int levelId;

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "fullName": fullName,
        "icon": icon,
        "points": points
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int id,
        "fullName": String fullName,
        "email": String email,
        "icon": String? icon,
        "points": int points,
        "levelId": int levelId,
      } =>
        User(
          id: id,
          fullName: fullName,
          email: email,
          icon: icon,
          points: points,
          levelId: levelId,
        ),
      _ => throw const APIError("Invalid fields to load a user"),
    };
  }
}

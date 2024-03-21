import 'package:flutter/material.dart';
import 'package:mtaa_project/support/exceptions.dart';

@immutable
class User {
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.token,
  });

  final int id;
  final String email;
  final String fullName;
  final String token;

  Map<String, dynamic> toJson() =>
      {"id": id, "email": email, "fullName": fullName, "token": token};

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "token": String token,
        "user": {
          "id": int id,
          "fullName": String fullName,
          "email": String email,
        }
      } =>
        User(token: token, id: id, fullName: fullName, email: email),
      _ => throw const APIError("Invalid fields to load a user"),
    };
  }
}

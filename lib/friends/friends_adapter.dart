import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/auth/user.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

class FriendsAdapter with ChangeNotifier, ChangeNotifierAsync {
  FriendsAdapter._();
  static final instance = FriendsAdapter._();

  Future<List<User>> searchUsers(String query) async {
    var auth = AuthAdapter.instance;
    var url = backendURL.resolveUri(Uri(
      path: "/friend/search",
      queryParameters: {"query": query},
    ));
    var response = await get(url, headers: auth.getAuthorizationHeaders());

    var data = processHTTPResponse(response);
    var users = switch (data) {
      {
        "users": List<dynamic> usersData,
      } =>
        usersData.map((v) => User.fromJson(v)).toList(),
      _ => throw const APIError("Invalid response for friends search")
    };

    return users;
  }
}

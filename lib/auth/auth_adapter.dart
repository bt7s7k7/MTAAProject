import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/auth/user.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/local_storate.dart';
import 'package:mtaa_project/support/support.dart';

class AuthAdapter with ChangeNotifier, ChangeNotifierAsync {
  AuthAdapter._();
  static final instance = AuthAdapter._();

  User? get user => _user;
  User? _user;

  Future<User> load() async {
    await localStorage.ready;
    var token = localStorage.getItem("auth-token");
    if (token == null) throw NotAuthenticatedException();

    if (token is! String) {
      throw Error();
    }

    var response = await get(
      backendURL.resolve("/user"),
      headers: {"Authorization": "Bearer $token"},
    );

    var data = processHTTPResponse(response);
    var user = User.fromIndex(token, data);

    _user = user;
    notifyListenersAsync();

    return user;
  }

  Future<User> register(String fullName, String email, String password) async {
    var response = await post(
      backendURL.resolve("/auth/register"),
      body: <String, dynamic>{
        "fullName": fullName,
        "email": email,
        "password": password,
      },
    );

    var data = processHTTPResponse(response);
    var user = User.fromLogin(data);

    _user = user;
    await localStorage.setItem("auth-token", user.token);
    notifyListenersAsync();

    return user;
  }

  Future<User> login(String email, String password) async {
    var response = await post(
      backendURL.resolve("/auth/login"),
      body: <String, dynamic>{
        "email": email,
        "password": password,
      },
    );

    var data = processHTTPResponse(response);
    var user = User.fromLogin(data);

    _user = user;
    await localStorage.setItem("auth-token", user.token);
    notifyListenersAsync();

    return user;
  }
}

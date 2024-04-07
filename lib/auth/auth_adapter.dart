import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/local_storage.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user.dart';

class AuthAdapter with ChangeNotifier, ChangeNotifierAsync {
  AuthAdapter._();
  static final instance = AuthAdapter._();

  User? get user => _user;
  User? _user;
  String? _token;

  (String, User) _parseAuthJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "token": String token,
        "user": Map<String, dynamic> userJson,
      } =>
        (token, User.fromJson(userJson)),
      _ => throw const APIError("Invalid fields in auth response"),
    };
  }

  Map<String, String> getAuthorizationHeaders() {
    if (_token == null) throw NotAuthenticatedException();
    return {"Authorization": "Bearer $_token"};
  }

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
    var user = User.fromJson(data);

    _user = user;
    _token = token;
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
    var (token, user) = _parseAuthJson(data);

    _user = user;
    _token = token;
    await localStorage.setItem("auth-token", token);
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
    var (token, user) = _parseAuthJson(data);

    _user = user;
    _token = token;
    await localStorage.setItem("auth-token", token);
    notifyListenersAsync();

    return user;
  }

  Future<void> logOut() async {
    _user = null;
    _token = null;
    await localStorage.setItem("auth-token", null);
    notifyListenersAsync();
  }
}

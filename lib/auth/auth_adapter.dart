import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user.dart';

class AuthAdapter with ChangeNotifier, ChangeNotifierAsync {
  AuthAdapter._();
  static final instance = AuthAdapter._();

  User? get user => _user;
  User? _user;
  String? get token => _token;
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
    UpdateService.instance.addListener((event) {
      if (_user == null) return;
      if (event.type != "user" || event.id != _user!.id) return;
      if (event.value == null) return;

      debugMessage("[Auth] User update ${event.value}");

      _user = User.fromJson(event.value!);
      notifyListenersAsync();
    });

    var token = Settings.instance.authToken.getValue();
    if (token == null) {
      debugMessage("[Auth] Missing token");
      throw NotAuthenticatedException();
    }

    var response = await get(
      backendURL.resolve("/user"),
      headers: {"Authorization": "Bearer $token"},
    );

    var data = processHTTPResponse(response);
    var user = User.fromJson(data);

    FirebaseAnalytics.instance.setUserId(id: user.id.toString());
    FirebaseAnalytics.instance
        .setUserProperty(name: "email", value: user.email);

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

    FirebaseAnalytics.instance.setUserId(id: user.id.toString());
    FirebaseAnalytics.instance
        .setUserProperty(name: "email", value: user.email);
    FirebaseAnalytics.instance.logSignUp(signUpMethod: "normal");

    _user = user;
    _token = token;
    await Settings.instance.authToken.setValue(token);
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

    FirebaseAnalytics.instance.setUserId(id: user.id.toString());
    FirebaseAnalytics.instance
        .setUserProperty(name: "email", value: user.email);
    FirebaseAnalytics.instance.logLogin(loginMethod: "normal");

    _user = user;
    _token = token;
    await Settings.instance.authToken.setValue(token);
    notifyListenersAsync();

    return user;
  }

  Future<void> logOut() async {
    FirebaseAnalytics.instance.setUserId(id: null);

    _user = null;
    _token = null;
    await Settings.instance.authToken.setValue(null);
    notifyListenersAsync();
  }
}

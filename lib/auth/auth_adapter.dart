import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user.dart';

/// Allows for communicating with the auth and user controller on the backend
class AuthAdapter with ChangeNotifier, ChangeNotifierAsync {
  AuthAdapter._();
  static final instance = AuthAdapter._();

  User? get user => _user;
  User? _user;
  String? get token => _token;
  String? _token;

  /// Parses data returned by authentication endpoints
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

  /// Creates headers for authorizing requests
  Map<String, String> getAuthorizationHeaders() {
    if (_token == null) throw NotAuthenticatedException();
    return {"Authorization": "Bearer $_token"};
  }

  /// Loads user information
  Future<User> load() async {
    UpdateService.instance.addListener((event) {
      if (_user == null) return;
      if (event.type != "user" || event.id != _user!.id) return;
      if (event.value == null) return;

      debugMessage("[Auth] User update ${event.value}");

      _user = User.fromJson(event.value!);
      Settings.instance.cachedUser.setValue(jsonEncode(_user!.toJson()));
      notifyListenersAsync();
    });

    var token = Settings.instance.authToken.getValue();
    if (token == null) {
      debugMessage("[Auth] Missing token");
      throw NotAuthenticatedException();
    }

    var data = await OfflineService.instance.networkRequestWithFallback(
      request: () => get(
        backendURL.resolve("/user"),
        headers: {"Authorization": "Bearer $token"},
      ),
      fallback: () {
        var cachedUser = Settings.instance.cachedUser.getValue();
        if (cachedUser == null) throw OnlineInitRequired();
        return jsonDecode(cachedUser);
      },
    );

    var user = User.fromJson(data);

    FirebaseAnalytics.instance.setUserId(id: user.id.toString());
    FirebaseAnalytics.instance.setUserProperty(
      name: "email",
      value: user.email,
    );

    if (OfflineService.instance.isOnline) {
      await Settings.instance.cachedUser.setValue(jsonEncode(data));
    }

    _user = user;
    _token = token;
    notifyListenersAsync();

    return user;
  }

  /// Allow for changing user name or password
  Future<void> updateUser(Map<String, dynamic> values) async {
    var response = await put(
      backendURL.resolve("/user"),
      headers: getAuthorizationHeaders(),
      body: values,
    );

    processHTTPResponse(response);
  }

  Future<void> updateIcon(PlatformFile icon) async {
    var request = MultipartRequest("PUT", backendURL.resolve("/user/photo"));

    var iconContent = await icon.xFile.readAsBytes();

    request.files.add(MultipartFile.fromBytes(
      "photo",
      iconContent,
      filename: icon.name,
    ));
    request.headers.addAll(getAuthorizationHeaders());

    var response = await Response.fromStream(await request.send());
    processHTTPResponse(response);
  }

  /// Register a new user
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
    await Settings.instance.cachedUser.setValue(jsonEncode(_user!.toJson()));
    notifyListenersAsync();

    return user;
  }

  /// Logins into an existing account
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
    await Settings.instance.cachedUser.setValue(jsonEncode(_user!.toJson()));
    notifyListenersAsync();

    return user;
  }

  /// Deletes all login information
  Future<void> logOut() async {
    FirebaseAnalytics.instance.setUserId(id: null);

    _user = null;
    _token = null;
    await Settings.instance.authToken.setValue(null);
    await Settings.instance.cachedUser.setValue(null);
    notifyListenersAsync();
  }
}

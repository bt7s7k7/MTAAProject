import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

class OfflineService with ChangeNotifier, ChangeNotifierAsync {
  OfflineService._();
  static final instance = OfflineService._();

  var _isOnline = false;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  final List<void Function()> _onlineActions = [];

  void setOnlineState(bool online) {
    if (online == _isOnline) return;
    _isOnline = online;

    debugMessage("[Offline] State change, online: $online");

    if (isOnline) {
      for (final action in _onlineActions) {
        action();
      }
    }

    notifyListenersAsync();
  }

  void addOnlineAction(void Function() callback) {
    _onlineActions.add(callback);
    if (_isOnline) {
      callback();
    }
  }

  Future<Map<String, dynamic>> networkRequestWithFallback(
      {required Future<Response> Function() request,
      required Map<String, dynamic> Function() fallback,
      bool? executeCallbackAlways}) async {
    if (_isOnline) {
      var response = await request();
      var data = processHTTPResponse(response);

      if (executeCallbackAlways != null && executeCallbackAlways) {
        fallback();
      }

      return data;
    } else {
      return fallback();
    }
  }

  Future<void> load() async {
    try {
      var response = await get(backendURL.resolve("/ping"));
      var data = processHTTPResponse(response);
      if (data["online"] != true) throw const APIError("Offline");
    } catch (error) {
      _isOnline = false;
      debugMessage("[Offline] Is offline");
      return;
    }

    _isOnline = true;
    debugMessage("[Offline] Is online");
  }
}

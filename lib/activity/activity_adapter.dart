import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

class ActivityAdapter with ChangeNotifier, ChangeNotifierAsync {
  ActivityAdapter._();
  static final instance = ActivityAdapter._();

  Future<List<Activity>> getHomeActivities() async {
    var auth = AuthAdapter.instance;
    var response = await get(
      backendURL.resolve("/activity"),
      headers: auth.getAuthorizationHeaders(),
    );

    var data = processHTTPResponse(response);
    var activities = switch (data) {
      {
        "items": List<dynamic> activityData,
      } =>
        activityData.map((v) => Activity.fromJson(v)).toList(),
      _ => throw APIError("Invalid response for home activities: $data")
    };

    return activities;
  }

  Future<List<Activity>> getUserActivities(int id) async {
    var auth = AuthAdapter.instance;
    var response = await get(
      backendURL.resolve("/activity/user/$id"),
      headers: auth.getAuthorizationHeaders(),
    );

    var data = processHTTPResponse(response);
    var activities = switch (data) {
      {
        "items": List<dynamic> activityData,
      } =>
        activityData.map((v) => Activity.fromJson(v)).toList(),
      _ => throw APIError("Invalid response for user activities: $data")
    };

    return activities;
  }

  Future<Activity> getActivity(String id) async {
    var auth = AuthAdapter.instance;
    var response = await get(
      backendURL.resolve("/activity/$id"),
      headers: auth.getAuthorizationHeaders(),
    );

    var data = processHTTPResponse(response);
    var activity = Activity.fromJson(data);

    return activity;
  }

  Future<void> uploadActivity(Activity activity) async {
    var auth = AuthAdapter.instance;
    var response = await post(
      backendURL.resolve("/activity"),
      headers: {
        ...auth.getAuthorizationHeaders(),
        "content-type": "application/json",
      },
      body: jsonEncode(activity.toJson()),
    );

    processHTTPResponse(response);
  }

  Future<void> deleteActivity(Activity activity) async {
    var auth = AuthAdapter.instance;
    var response = await delete(
      backendURL.resolve("/activity/${activity.id}"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);
  }
}

import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

/// Allows for communicating with the activity controller on the backend
class ActivityAdapter with ChangeNotifier, ChangeNotifierAsync {
  ActivityAdapter._();
  static final instance = ActivityAdapter._();

  /// Gets cached activities for offline mode
  List<dynamic> _getCachedActivities() {
    var source = Settings.instance.cachedActivities.getValue();
    if (source == null) return [];
    var data = jsonDecode(source) as List<dynamic>;
    return data;
  }

  /// Sets cached activities for offline mode
  void _saveCachedActivities(List<dynamic> activities) {
    Settings.instance.cachedActivities.setValue(jsonEncode(activities));
  }

  /// Gets activity upload queue for offline mode
  List<dynamic>? _getUploadQueue() {
    var queueSource = Settings.instance.cachedUploadQueue.getValue();
    if (queueSource == null) return null;
    var queueData = jsonDecode(queueSource) as List<dynamic>;
    return queueData;
  }

  /// Sets activity upload queue for offline mode
  void _saveUploadQueue(List<dynamic>? queue) {
    if (queue == null) {
      Settings.instance.cachedUploadQueue.setValue(null);
    } else {
      Settings.instance.cachedUploadQueue.setValue(jsonEncode(queue));
    }
  }

  /// Adds an activity to the upload queue for offline mode
  void _appendUploadQueue(dynamic activity) {
    var queue = _getUploadQueue() ?? [];
    queue.add(activity);
    _saveUploadQueue(queue);
  }

  /// Adds a hook to the [OfflineService] for uploading activities created during offline mode
  Future<void> load() async {
    OfflineService.instance.addOnlineAction(() async {
      var auth = AuthAdapter.instance;
      if (AuthAdapter.instance.user == null) return;
      var queue = _getUploadQueue();
      if (queue == null) return;

      for (var activityData in List<dynamic>.from(queue)) {
        var activity = Activity.fromJson(activityData);
        var response = await post(
          backendURL.resolve("/activity"),
          headers: {
            ...auth.getAuthorizationHeaders(),
            "content-type": "application/json",
          },
          body: jsonEncode(activity.toJsonForUpload()),
        );
        processHTTPResponse(response);
        queue.remove(activityData);
        _saveUploadQueue(queue);
      }

      assert(queue.isEmpty);
      _saveUploadQueue(null);
    });
  }

  /// Gets activities to be displayed on the home page
  Future<List<Activity>> getHomeActivities() async {
    var auth = AuthAdapter.instance;
    var data = await OfflineService.instance.networkRequestWithFallback(
      request: () => get(
        backendURL.resolve("/activity"),
        headers: auth.getAuthorizationHeaders(),
      ),
      fallback: () => {"items": _getCachedActivities()},
    );

    var activities = switch (data) {
      {
        "items": List<dynamic> activityData,
      } =>
        activityData.map((v) => Activity.fromJson(v)).toList(),
      _ => throw APIError("Invalid response for home activities: $data")
    };

    if (OfflineService.instance.isOnline) {
      _saveCachedActivities(activities
          .where((element) => element.user.id == auth.user!.id)
          .toList());
    }

    return activities;
  }

  /// Gets the activities that should be displayed in a user profile page
  Future<List<Activity>> getUserActivities(int id) async {
    var auth = AuthAdapter.instance;

    var data = await OfflineService.instance.networkRequestWithFallback(
      request: () => get(
        backendURL.resolve("/activity/user/$id"),
        headers: auth.getAuthorizationHeaders(),
      ),
      fallback: () => id == auth.user!.id
          ? {"items": _getCachedActivities()}
          : {"items": []},
    );

    var activities = switch (data) {
      {
        "items": List<dynamic> activityData,
      } =>
        activityData.map((v) => Activity.fromJson(v)).toList(),
      _ => throw APIError("Invalid response for user activities: $data")
    };

    if (auth.user != null &&
        OfflineService.instance.isOnline &&
        id == auth.user!.id) {
      _saveCachedActivities(activities);
    }

    return activities;
  }

  /// Gets activity details
  Future<Activity> getActivity(String id) async {
    var auth = AuthAdapter.instance;

    var data = await OfflineService.instance.networkRequestWithFallback(
      request: () => get(
        backendURL.resolve("/activity/$id"),
        headers: auth.getAuthorizationHeaders(),
      ),
      fallback: () {
        var cached = _getCachedActivities();
        var activityData = cached.firstWhere(
          (element) => element["id"].toString() == id,
          orElse: () => null,
        );

        if (activityData == null) {
          throw const APIError("Offline activity not found");
        }

        return activityData;
      },
    );
    var activity = Activity.fromJson(data);

    return activity;
  }

  /// Uploads a new activity to the server
  Future<Activity> uploadActivity(Activity activity) async {
    var auth = AuthAdapter.instance;

    var data = await OfflineService.instance.networkRequestWithFallback(
      request: () => post(
        backendURL.resolve("/activity"),
        headers: {
          ...auth.getAuthorizationHeaders(),
          "content-type": "application/json",
        },
        body: jsonEncode(activity.toJsonForUpload()),
      ),
      fallback: () {
        var cachedActivities = _getCachedActivities();
        var serializedActivity = activity.toJson();
        cachedActivities.insert(0, serializedActivity);
        _saveCachedActivities(cachedActivities);
        _appendUploadQueue(serializedActivity);
        UpdateService.instance.submitUpdate(UpdateEvent(
          type: "activity",
          id: activity.id,
          value: serializedActivity,
        ));
        return serializedActivity;
      },
    );

    var savedActivity = Activity.fromJson(data);

    // Log the 'create_activity' event to Firebase Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'create_activity',
      parameters: {
        'activity_id': activity.id,
        'activity_name': activity.activityName,
        'user_id': activity.user.id,
        'points': activity.points,
        'steps': activity.steps,
        'distance': activity.distance,
        'duration': activity.duration,
        'created_at': activity.createdAt.millisecondsSinceEpoch,
        'likes_count': activity.likesCount,
      },
    );

    return savedActivity;
  }

  /// Requests activity deletion from the server
  Future<void> deleteActivity(Activity activity) async {
    var auth = AuthAdapter.instance;
    var response = await delete(
      backendURL.resolve("/activity/${activity.id}"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);
  }

  /// Adds a like on the specified activity
  Future<void> likeActivity(Activity activity) async {
    var auth = AuthAdapter.instance;
    var response = await post(
      backendURL.resolve("/activity/like/${activity.id}"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);

    FirebaseAnalytics.instance.logEvent(
      name: 'like_activity',
      parameters: {
        'activity_id': activity.id,
        'user_id': auth.user?.id,
      },
    );
  }

  /// Removes a like on the specified activity
  Future<void> unlikeActivity(Activity activity) async {
    var auth = AuthAdapter.instance;
    var response = await delete(
      backendURL.resolve("/activity/like/${activity.id}"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);

    FirebaseAnalytics.instance.logEvent(
      name: 'unlike_activity',
      parameters: {
        'activity_id': activity.id,
        'user_id': auth.user?.id,
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/services/pedometer_service.dart';
import 'package:mtaa_project/support/support.dart';

/// Tracks the activity the user is currently performing
class ActivityTracker with ChangeNotifier, ChangeNotifierAsync {
  /// The amount of steps returned by [PedometerService] on the start of the activity
  final int _stepsInit = PedometerService.instance.steps;

  /// Timer for incrementing the duration of the activity
  late final Timer _timer;

  /// Amount of steps made during the activity
  int steps = 0;

  /// Distance moved during the activity in meters
  double distance = 0;

  /// Duration of the activity in seconds
  double duration = 0;

  /// If the activity tracker is paused
  bool paused = false;

  /// The time our timer has last ticked, for calculating the change in activity duration even if the application is backgrounded
  int _lastTick = DateTime.now().millisecondsSinceEpoch;

  /// List of points walked through
  final path = <GeoPoint>[];

  /// Handles a new amount of states returned by the [PedometerService]
  void _handleStepUpdate() {
    steps = PedometerService.instance.steps - _stepsInit;
    notifyListenersAsync();
  }

  /// Appends a new point to the activity [path] and increments the [distance]
  Future<void> appendLocation(GeoPoint location) async {
    if (paused) return;

    if (path.isNotEmpty) {
      var localDistance = await distance2point(path.last, location);
      distance += localDistance;
      if (localDistance < 1) {
        notifyListenersAsync();
        return;
      }
    }

    path.add(location);
    notifyListenersAsync();
  }

  @override
  void dispose() {
    PedometerService.instance.removeListener(_handleStepUpdate);
    _timer.cancel();
    debugMessage("[Map] End tracking");
    super.dispose();
  }

  ActivityTracker() {
    PedometerService.instance.addListener(_handleStepUpdate);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      var now = DateTime.now().millisecondsSinceEpoch;
      var deltaTime = (now.toDouble() - _lastTick) / 1000;
      _lastTick = now;
      if (paused) return;
      duration += deltaTime;
      notifyListenersAsync();
    });

    debugMessage("[Map] Begin tracking");
  }
}

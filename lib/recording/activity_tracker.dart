import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/services/pedometer_service.dart';
import 'package:mtaa_project/support/support.dart';

class ActivityTracker with ChangeNotifier, ChangeNotifierAsync {
  final int _stepsInit = PedometerService.instance.steps;
  late final Timer _timer;

  int steps = 0;
  double distance = 0;
  int duration = 0;

  final path = <GeoPoint>[];

  void _handleStepUpdate() {
    steps = PedometerService.instance.steps - _stepsInit;
    notifyListenersAsync();
  }

  Future<void> appendLocation(GeoPoint location) async {
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
      duration += 1;
      notifyListenersAsync();
    });

    debugMessage("[Map] Begin tracking");
  }
}

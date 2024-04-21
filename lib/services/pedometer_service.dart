import 'package:flutter/material.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:pedometer/pedometer.dart';

class PedometerService with ChangeNotifier, ChangeNotifierAsync {
  PedometerService._();
  static final instance = PedometerService._();

  var _steps = 0;
  int get steps => _steps;

  String _status = "loading";
  String get status => _status;

  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late Stream<StepCount> _stepCountStream;

  Future<void> load() async {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream.listen((event) {
      _status = event.status;
      notifyListenersAsync();
    }).onError((error) {
      debugMessage("[Steps] Error getting pedestrian status: $error");
      _status = "error";
      notifyListenersAsync();
    });

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen((event) {
      _steps = event.steps;
      notifyListenersAsync();
    }).onError((error) {
      debugMessage("[Steps] Error getting step count: $error");
    });
  }
}

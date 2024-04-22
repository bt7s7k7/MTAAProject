import 'package:flutter/foundation.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:pedometer/pedometer.dart';

/// Gets step count from the device's pedometer
class PedometerService with ChangeNotifier, ChangeNotifierAsync {
  PedometerService._();
  static final instance = PedometerService._();

  var _steps = 0;

  /// Amount of steps counted
  int get steps => _steps;

  String _status = "loading";
  String get status => _status;

  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late Stream<StepCount> _stepCountStream;

  /// Gets the current steps from the devices's pedometer and listens for updates
  void _init() {
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

  void _handlePermissionChange() {
    if (!PermissionService.instance.activityRecognition.isGranted) return;
    PermissionService.instance.removeListener(_handlePermissionChange);
    debugMessage("[Steps] Pedometer initialized after permission granted");
    _init();
  }

  /// Calls [_init] if activity recognition permission were granted, otherwise waits until they are
  Future<void> load() async {
    if (kIsWeb) return;

    if (PermissionService.instance.activityRecognition.isGranted) {
      _init();
    } else {
      debugMessage(
          "[Steps] Pedometer not initialized because permission not granted");
      PermissionService.instance.addListener(_handlePermissionChange);
    }
  }
}

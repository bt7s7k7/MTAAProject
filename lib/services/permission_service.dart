import 'package:flutter/material.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandle {
  PermissionHandle._(this.name, this.permission);

  final String name;
  final Permission permission;
  late PermissionStatus status;

  bool get isGranted => status.isGranted;

  Future<void> load() async {
    status = await permission.status;
  }

  Future<void> request() async {
    status = await permission.request();
    PermissionService.instance.notifyListenersAsync();
  }
}

class PermissionService with ChangeNotifier, ChangeNotifierAsync {
  PermissionService._();
  static final instance = PermissionService._();

  final activityRecognition =
      PermissionHandle._("activityRecognition", Permission.activityRecognition);
  final location = PermissionHandle._("location", Permission.locationWhenInUse);
  late final List<PermissionHandle> permissions;

  Future<void> load() async {
    permissions = [activityRecognition, location];

    for (final handle in permissions) {
      await handle.load();
    }
  }

  String getStateString() {
    return permissions.map((v) => "${v.name}: ${v.status.name}").join((", "));
  }
}

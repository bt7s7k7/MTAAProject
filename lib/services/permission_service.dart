import 'package:flutter/foundation.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:permission_handler/permission_handler.dart';

/// Represents an app permission
class PermissionHandle {
  PermissionHandle._(this.name, this.permission);

  /// Name of the permission for debugging
  final String name;

  /// Reference to the permission
  final Permission permission;

  /// Status of the permission
  late PermissionStatus? status;

  /// Is this permission granted
  bool get isGranted => status?.isGranted ?? false;

  /// Loads the permission status
  Future<void> load() async {
    if (kIsWeb) {
      status = null;
      return;
    }

    status = await permission.status;
  }

  /// Displays a permission request to the user
  Future<void> request() async {
    status = await permission.request();
    PermissionService.instance.notifyListenersAsync();
  }
}

/// Handles the state of permission required by the app
class PermissionService with ChangeNotifier, ChangeNotifierAsync {
  PermissionService._();
  static final instance = PermissionService._();

  /// The permission to track steps
  final activityRecognition =
      PermissionHandle._("activityRecognition", Permission.activityRecognition);

  /// The permission to track location
  final location = PermissionHandle._("location", Permission.locationWhenInUse);

  /// List of permission for debugging
  late final List<PermissionHandle> permissions;

  /// Gets the current state of permissions
  Future<void> load() async {
    permissions = [activityRecognition, location];

    for (final handle in permissions) {
      await handle.load();
    }
  }

  /// Gets the string representing states of all permissions for debugging
  String getStateString() {
    return permissions.map((v) => "${v.name}: ${v.isGranted}").join((", "));
  }
}

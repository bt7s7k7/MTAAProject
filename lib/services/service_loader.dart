import 'package:flutter/material.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/services/notification_service.dart';
import 'package:mtaa_project/services/pedometer_service.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/user/level_adapter.dart';

class ServiceLoader extends StatefulWidget {
  const ServiceLoader({super.key, required this.child});

  final Widget child;

  @override
  State<ServiceLoader> createState() => _ServiceLoaderState();
}

class _ServiceLoaderState extends State<ServiceLoader> {
  var loaded = false;

  void _onAuthChanged() {
    UpdateService.instance.updateConnection();

    if (AuthAdapter.instance.user == null) {
      debugMessage("[Auth] Login required");
      router.goNamed("Login");
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    super.initState();

    AuthAdapter.instance.addListener(_onAuthChanged);

    debugMessage("[Loader] Settings");
    await Settings.instance.ready();
    debugMessage("[Loader] LanguageManager");
    await LanguageManager.instance.load();
    debugMessage("[Loader] LevelAdapter");
    await LevelAdapter.instance.load();
    debugMessage("[Loader] NotificationService");
    var initRoute = await NotificationService.instance.load();
    debugMessage("[Loader] PermissionService");
    await PermissionService.instance.load();
    debugMessage("[Loader] PedometerService");
    await PedometerService.instance.load();

    debugMessage("[Loader] AuthAdapter");
    try {
      await AuthAdapter.instance.load();
      debugMessage(
          "[Auth] Authenticated: ${AuthAdapter.instance.user?.toJson()}");
    } on NotAuthenticatedException {
      router.goNamed("Login");
      debugMessage("[Auth] Login required");
    }

    debugMessage("[Loader] UpdateService");
    await UpdateService.instance.updateConnection();

    if (initRoute != null) {
      debugMessage("[Loader] Has init route: $initRoute");
      router.goNamed(initRoute);
    }

    debugMessage("[Loader] Done.");

    setState(() {
      loaded = true;
    });
  }

  @override
  void dispose() {
    AuthAdapter.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    }

    return widget.child;
  }
}

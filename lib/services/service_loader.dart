import 'package:flutter/material.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/services/notification_service.dart';
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

    await Settings.instance.ready();
    await LanguageManager.instance.load();
    await LevelAdapter.instance.load();
    var initRoute = await NotificationService.instance.load();

    try {
      await AuthAdapter.instance.load();
    } on NotAuthenticatedException {
      router.goNamed("Login");
    }

    await UpdateService.instance.updateConnection();

    if (initRoute != null) {
      router.goNamed(initRoute);
    }

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

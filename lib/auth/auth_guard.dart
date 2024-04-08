import 'package:flutter/material.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/exceptions.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  var loaded = false;

  void _onAuthChanged() {
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

    try {
      await AuthAdapter.instance.load();
    } on NotAuthenticatedException {
      router.goNamed("Login");
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

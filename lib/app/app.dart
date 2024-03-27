import 'package:flutter/material.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/auth/auth_guard.dart';
import 'package:mtaa_project/support/observable.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ObservableRoot(
      child: AuthGuard(
        child: MaterialApp.router(
          title: "DigiSenior",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}

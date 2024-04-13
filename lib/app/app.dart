import 'package:flutter/material.dart';
import 'package:mtaa_project/app/router.dart';
import 'package:mtaa_project/services/service_loader.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/settings/theme_switcher.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ServiceLoader(
      child: SettingsBuilder(
        property: Settings.instance.darkTheme,
        builder: (darkTheme) => MaterialApp.router(
          title: "DigiSenior",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: darkTheme ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}

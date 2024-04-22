import 'package:flutter/material.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

/// Page for requesting the user connects to the internet, since the app needs an internet connection on first startup
class OnlineInitPage extends StatelessWidget {
  const OnlineInitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: ListTile(
            title: Text(LanguageManager.instance.language.offlineInit()),
            subtitle: Text(LanguageManager.instance.language.offlineInitDesc()),
            leading: const Icon(Icons.public_off_outlined),
          ),
        ),
      ),
    );
  }
}

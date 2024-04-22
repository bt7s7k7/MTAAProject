import 'package:flutter/material.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

/// Shows an offline warning if we are offline
class OfflineWarning extends StatelessWidget {
  const OfflineWarning({super.key, required this.label});

  /// What message to show in the title
  final String Function() label;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (_, __) => switch (OfflineService.instance.isOnline) {
        true => const SizedBox(),
        false => ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => Card(
              child: ListTile(
                title: Text(LanguageManager.instance.language.offlineInit()),
                subtitle: Text(label()),
                leading: const Icon(Icons.public_off_outlined),
              ),
            ),
          ),
      },
    );
  }
}

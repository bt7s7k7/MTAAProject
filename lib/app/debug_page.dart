import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/services/pedometer_service.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class _MessageList with ChangeNotifier {
  final value = <String>[];

  void addMessage(String message) {
    if (value.isNotEmpty) {
      var lastMessage = value.last;
      if (lastMessage.startsWith(message) &&
          lastMessage.length >= message.length) {
        if (lastMessage == message) {
          value.last = "$message (2)";
          notifyListeners();
          return;
        }

        var numberText = lastMessage.substring(message.length + 1);
        var match = RegExp(r"^\((\d+)\)").firstMatch(numberText);
        if (match != null) {
          var number = int.parse(match.group(1)!);
          value.last = "$message (${number + 1})";
          notifyListeners();
          return;
        }
      }
    }
    value.add(message);
    notifyListeners();
  }
}

final _messages = _MessageList();

void debugMessage(String message) {
  debugPrint(message);
  _messages.addMessage(message);
}

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          ListenableBuilder(
            listenable: AuthAdapter.instance,
            builder: (_, __) =>
                Text("User: ${jsonEncode(AuthAdapter.instance.user)}"),
          ),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => Text(
                "Language: ${jsonEncode(LanguageManager.instance.language.label)}"),
          ),
          Text("Backend: $backendURL"),
          ListenableBuilder(
            listenable: PermissionService.instance,
            builder: (_, __) => Text(
                "Permissions: {${PermissionService.instance.getStateString()}}"),
          ),
          ListenableBuilder(
            listenable: PedometerService.instance,
            builder: (_, __) => Text(
                "Steps: ${PedometerService.instance.steps} (${PedometerService.instance.status})"),
          ),
          const Divider(height: 1, thickness: 1),
          ListenableBuilder(
            listenable: _messages,
            builder: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _messages.value.map((msg) => Text(msg)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

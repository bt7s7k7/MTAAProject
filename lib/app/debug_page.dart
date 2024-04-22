import 'dart:convert';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:mtaa_project/activity/activity.dart';
import 'package:mtaa_project/activity/activity_adapter.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/services/pedometer_service.dart';
import 'package:mtaa_project/services/permission_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

/// List of debug messages created created by [debugMessage]
class _MessageList with ChangeNotifier, ChangeNotifierAsync {
  final value = <String>[];

  void addMessage(String message) {
    if (value.isNotEmpty) {
      var lastMessage = value.last;
      if (lastMessage.startsWith(message) &&
          lastMessage.length >= message.length) {
        if (lastMessage == message) {
          value.last = "$message (2)";
          notifyListenersAsync();
          return;
        }

        var numberText = lastMessage.substring(message.length + 1);
        var match = RegExp(r"^\((\d+)\)").firstMatch(numberText);
        if (match != null) {
          var number = int.parse(match.group(1)!);
          value.last = "$message (${number + 1})";
          notifyListenersAsync();
          return;
        }
      }
    }
    value.add(message);
    notifyListenersAsync();
  }
}

final _messages = _MessageList();

/// Creates a debug message and also prints it using [debugPrint]
void debugMessage(String message) {
  debugPrint(message);
  _messages.addMessage(message);
}

/// Shows debug information and messages and contains development utility actions
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  /// Sends a fake firebase analytics event
  void _dummyAnalyticsLog() {
    FirebaseAnalytics.instance.logEvent(
      name: "debug_event",
      parameters: {"user_id": AuthAdapter.instance.user!.id},
    );
  }

  /// Creates a randomly generated activity
  void _dummyActivity() async {
    var random = Random();
    await ActivityAdapter.instance.uploadActivity(
      Activity.fromRecording(
        name: "New Activity",
        steps: random.nextInt(1000) + 1000,
        distance: random.nextInt(1000) + 10,
        duration: random.nextInt(5000),
        path: [],
      ),
    );

    if (!mounted) return;

    popupResult(context, "Activity created");
  }

  /// Sends a fake crash report
  void _dummyCrashReport() async {
    FirebaseCrashlytics.instance.recordFlutterError(
      FlutterErrorDetails(
        exception: const APIError(
            "There are things that happened (debug screen error)"),
        stack: StackTrace.current,
      ),
    );
  }

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
          Wrap(
            children: [
              FilledButton(
                onPressed: _dummyAnalyticsLog,
                child: const Text("Analytics Log"),
              ),
              FilledButton(
                onPressed: _dummyActivity,
                child: const Text("Create Activity"),
              ),
              FilledButton(
                onPressed: _dummyCrashReport,
                child: const Text("Crash Report"),
              ),
            ],
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

// firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'; // Required for kReleaseMode
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/constants.dart';

/// Initializes firebase services
class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  Future<void> load() async {
    debugMessage("[Firebase] Initializing app...");
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
    debugMessage("[Firebase] Firebase app loaded");
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      if (kIsWeb) return;

      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      if (kReleaseMode) {
        Function originalOnError =
            FlutterError.onError ?? (FlutterErrorDetails details) {};
        FlutterError.onError = (FlutterErrorDetails details) async {
          originalOnError(details);
          await FirebaseCrashlytics.instance.recordFlutterError(details);
        };
      }
    }
  }
}

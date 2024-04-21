// firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/constants.dart';

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  Future<void> load() async {
    debugMessage("[Firebase] Initializing app...");
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
    debugMessage("[Firebase] Firebase app loaded");
  }
}

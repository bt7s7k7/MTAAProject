// firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  late FirebaseApp app;
  late FirebaseAnalytics analytics;
  bool _initialized = false; // Add this line to track if Firebase is initialized

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  Future<void> initializeFirebase() async {
    if (!_initialized) { // Check to prevent re-initialization
      _initialized = true; // Set this to true first to prevent multiple initializations
      app = await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDpn3jpN8tRW45OiI0FrF6yugUkBhrnSfU",
          authDomain: "school-host.firebaseapp.com",
          projectId: "school-host",
          storageBucket: "school-host.appspot.com",
          messagingSenderId: "389231838583",
          appId: "1:389231838583:web:052c1ca28f8cfab7280d72",
          measurementId: "G-RGT5Y2NQCM",
        ),
      );
      analytics = FirebaseAnalytics.instance;
    }
  }

  static FirebaseAnalytics getAnalytics() {
    return _instance.analytics;
  }
}

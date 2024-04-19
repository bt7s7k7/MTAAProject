import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  Future<void> enableNotifications() async {
    var permissions = await FirebaseMessaging.instance.requestPermission();
    if (permissions.authorizationStatus != AuthorizationStatus.authorized) {
      throw UserException(LanguageManager.instance.language
          .pleaseEnableNotificationPermissions());
    }

    var token = await FirebaseMessaging.instance.getToken(vapidKey: vapidToken);
    if (token == null) {
      throw UserException(LanguageManager.instance.language
          .pleaseEnableNotificationPermissions());
    }

    var auth = AuthAdapter.instance;
    var response = await post(
      backendURL.resolve("/notifications"),
      headers: auth.getAuthorizationHeaders(),
      body: {"pushToken": token},
    );

    processHTTPResponse(response);

    Settings.instance.notificationsEnabled.setValue(true);
  }

  Future<void> disableNotifications() async {
    var auth = AuthAdapter.instance;
    var response = await delete(
      backendURL.resolve("/notifications"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);

    await Settings.instance.notificationsEnabled.setValue(false);
  }

  Future<String?> load() async {
    await Firebase.initializeApp(options: firebaseOptions);

    FirebaseMessaging.onMessage.listen((event) {
      debugMessage(
          "[Push] Foreground notification, {title: ${event.notification?.title}, body: ${event.notification?.body}}");
    });

    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage == null) return null;

    var initialRoute = initialMessage.data["route"];
    if (initialRoute == "") initialRoute = null;
    return initialRoute;
  }
}

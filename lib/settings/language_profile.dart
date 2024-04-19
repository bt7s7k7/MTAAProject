import 'package:intl/intl.dart';

abstract class LanguageProfile {
  abstract final String code;
  abstract final String label;
  abstract final String locale;
  late final DateFormat dateFormat = DateFormat.yMd(locale);

  String home();
  String recording();
  String friends();
  String addFriends();
  String search();
  String profile();
  String userPoints({required int points});
  String activitySubtitle({
    required String userName,
    required String distance,
    required int steps,
  });
  String login();
  String loginAction();
  String ifYouDontHaveAnAccount();
  String registerHere();
  String removeFriendAction();
  String register();
  String registerAction();
  String ifYouAlreadyHaveAnAccount();
  String loginHere();
  String email();
  String password();
  String name();
  String confirmPassword();
  String addFriendAction();
  String logOutAction();
  String language();
  String ofSteps();
  String darkTheme();
  String cannotLikeOwnActivity();
  String notifications();
  String pleaseEnableNotificationPermissions();
}

import 'package:intl/intl.dart';

abstract class LanguageProfile {
  abstract final String code;
  abstract final String label;
  abstract final String locale;
  late final DateFormat dateFormat = DateFormat.yMd(locale);
  late final DateFormat timeFormat =
      DateFormat(DateFormat.HOUR24_MINUTE_SECOND, locale);

  String home();
  String recording();
  String activity();
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
  String maxLevel();
  String darkTheme();
  String cannotLikeOwnActivity();
  String notifications();
  String pleaseEnableNotificationPermissions();
  String loadingMap();
  String beginRecording();
  String stepCountingPermission();
  String stepCountingPermissionRequired();
  String locationPermission();
  String locationPermissionRequired();
  String currentLocation();
  String locationSearching();
  String recordingInfo(
      {required String steps,
      required String meters,
      required String duration});
  String endRecording();
  String pauseRecording();
  String recordingPaused();
  String recordingPausedDesc();
  String unpauseRecording();
  String grantPermission();
  String mapOffline();
  String offlineDesc();
  String confirmActivityDeletion();
  String confirmActivityDeletionDesc();
  String delete();
  String cancel();
}

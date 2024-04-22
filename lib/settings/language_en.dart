part of "locale_manager.dart";

/// English language data for localization
class _LanguageEN extends LanguageProfile {
  @override
  String get code => "en";

  @override
  String get label => "English";

  @override
  String get locale => "en_GB";

  @override
  String activitySubtitle({
    required String userName,
    required String distance,
    required int steps,
  }) =>
      "$userName - $distance / $steps steps";

  @override
  String addFriends() => "Add Friends";

  @override
  String confirmPassword() => "Confirm Password";

  @override
  String email() => "Email";

  @override
  String friends() => "Friends";

  @override
  String home() => "Home";

  @override
  String ifYouAlreadyHaveAnAccount() =>
      "If you already have an account you can";

  @override
  String ifYouDontHaveAnAccount() => "If you don't have an account you can";

  @override
  String login() => "Login";

  @override
  String loginAction() => "Login";

  @override
  String loginHere() => "Login here";

  @override
  String name() => "Name";

  @override
  String password() => "Password";

  @override
  String profile() => "Profile";

  @override
  String recording() => "Recording";

  @override
  String activity() => "Activity";

  @override
  String register() => "Register";

  @override
  String registerAction() => "Register";

  @override
  String registerHere() => "Register here";

  @override
  String search() => "Search";

  @override
  String changePassword() => "Change Password";

  @override
  String changeProfilePicture() => "Change Profile Picture";

  @override
  String saveChanges() => "Save Changes";

  @override
  String accountSettings() => "Account settings";

  @override
  String userPoints({required int points}) => "$points points";

  @override
  String addFriendAction() => "Add";

  @override
  String logOutAction() => "Log out";

  @override
  String removeFriendAction() => "Remove friend";

  @override
  String language() => "Language";

  @override
  String ofSteps() => "steps";

  @override
  String maxLevel() => "Max level reached";

  @override
  String darkTheme() => "Dark theme";

  @override
  String cannotLikeOwnActivity() => "Cannot like own activity";

  @override
  String notifications() => "Notifications";

  @override
  String pleaseEnableNotificationPermissions() =>
      "Please enable notification permission in app settings";

  @override
  String loadingMap() => "Loading map...";

  @override
  String stepCountingPermission() => "Step counting";

  @override
  String stepCountingPermissionRequired() =>
      "Please grant step counting permission to continue";

  @override
  String locationPermission() => "Location";

  @override
  String locationPermissionRequired() =>
      "Please grant location permission to continue";

  @override
  String grantPermission() => "Grant";

  @override
  String beginRecording() => "Begin";

  @override
  String currentLocation() => "Location";

  @override
  String locationSearching() => "Searching...";

  @override
  String recordingInfo({
    required String steps,
    required String meters,
    required String duration,
  }) =>
      "$steps steps • $meters meters • $duration";

  @override
  String endRecording() => "Finish";

  @override
  String pauseRecording() => "Pause";

  @override
  String recordingPaused() => "Recording paused";

  @override
  String recordingPausedDesc() => "Take a breath, there is always enough time";

  @override
  String unpauseRecording() => "Resume";

  @override
  String mapOffline() => "Map is not available offline";

  @override
  String homeActivityOffline() =>
      "You can only see activities of your friends online";

  @override
  String friendsOffline() => "You can only see your friends online";

  @override
  String actionRequiredOnline() => "This action can only be performed online";

  @override
  String offlineDesc() => "Connect to the internet to enable";

  @override
  String offlineInit() => "You are offline";

  @override
  String offlineInitDesc() =>
      "Internet required for application initialization";

  @override
  String confirmActivityDeletion() => "Delete activity";

  @override
  String confirmActivityDeletionDesc() =>
      "Are you sure you want to delete this activity?";

  @override
  String delete() => "Delete";

  @override
  String cancel() => "Cancel";
}

part of "locale_manager.dart";

class _LanguageEN extends LanguageProfile {
  @override
  String get code => "en";

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
  String register() => "Register";

  @override
  String registerAction() => "Register";

  @override
  String registerHere() => "Register here";

  @override
  String search() => "Search";

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
}
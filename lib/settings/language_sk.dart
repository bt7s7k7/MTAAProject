part of "locale_manager.dart";

class _LanguageSK extends LanguageProfile {
  @override
  String get code => "sk";

  @override
  String get locale => "sk_SK";

  @override
  String activitySubtitle({
    required String userName,
    required String distance,
    required int steps,
  }) =>
      "$userName - $distance / $steps krokov";

  @override
  String addFriends() => "Pridať priateľov";

  @override
  String confirmPassword() => "Potvrdiť heslo";

  @override
  String email() => "Email";

  @override
  String friends() => "Priateľia";

  @override
  String home() => "Domov";

  @override
  String ifYouAlreadyHaveAnAccount() => "Ak už máte vytvorený účet";

  @override
  String ifYouDontHaveAnAccount() => "Ak ešte nemáte vytvorený účet";

  @override
  String login() => "Prihlásenie";

  @override
  String loginAction() => "Prihlásiť";

  @override
  String loginHere() => "Prihláste sa";

  @override
  String name() => "Meno";

  @override
  String password() => "Heslo";

  @override
  String profile() => "Profil";

  @override
  String recording() => "Nahrávanie";

  @override
  String register() => "Registrácia";

  @override
  String registerAction() => "Registrovať";

  @override
  String registerHere() => "Registrujte sa";

  @override
  String search() => "Vyhľadávať";

  @override
  String userPoints({required int points}) => "$points bodov";

  @override
  String addFriendAction() => "Pridať";

  @override
  String logOutAction() => "Odhlásiť";

  @override
  String removeFriendAction() => "Odstrániť priateľstvo";

  @override
  String language() => "Jazyk";

  @override
  String ofSteps() => "krokov";
}

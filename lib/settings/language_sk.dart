part of "locale_manager.dart";

/// Slovak language data for localization
class _LanguageSK extends LanguageProfile {
  @override
  String get code => "sk";

  @override
  String get label => "Slovenský";

  @override
  String accountSettings() => "Nastavenia účtu";

  @override
  String get locale => "sk_SK";

  @override
  String changeProfilePicture() => "Zmeniť profilovú fotku";

  @override
  String changePassword() => "Zmena hesla";

  @override
  String saveChanges() => "Uložiť zmeny";

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
  String activity() => "Aktivita";

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

  @override
  String maxLevel() => "Dosiahli ste maximálneho levelu";

  @override
  String darkTheme() => "Tmavá téma";

  @override
  String cannotLikeOwnActivity() => "Nemôžte dať like na svoju aktivitu";

  @override
  String notifications() => "Notifikácie";

  @override
  String pleaseEnableNotificationPermissions() =>
      "Prosím udeľte povolenie aplikácie pre notifikácie";

  @override
  String loadingMap() => "Načítavam mapu...";

  @override
  String stepCountingPermission() => "Počítanie krokov";

  @override
  String stepCountingPermissionRequired() =>
      "Prosím udeľte povolenie na počítanie krokov";

  @override
  String locationPermission() => "Poloha";

  @override
  String locationPermissionRequired() =>
      "Prosím udeľte povolenie na stanovenie polohy";

  @override
  String currentLocation() => "Poloha";

  @override
  String locationSearching() => "Hľadám...";

  @override
  String recordingInfo({
    required String steps,
    required String meters,
    required String duration,
  }) =>
      "$steps krokov • $meters metrov • $duration";

  @override
  String grantPermission() => "Udeliť";

  @override
  String endRecording() => "Ukončiť";

  @override
  String pauseRecording() => "Pauza";

  @override
  String beginRecording() => "Začať";

  @override
  String recordingPaused() => "Nahrávanie zastavené";

  @override
  String recordingPausedDesc() => "Nadýchnite sa, času je dosť";

  @override
  String unpauseRecording() => "Pokračovať";

  @override
  String mapOffline() => "Mapa nie je dispozícií offline";

  @override
  String homeActivityOffline() =>
      "Aktivity svojích priateľov môžte vidieť len online";

  @override
  String actionRequiredOnline() => "Túto akciu je možné vykonať len online";

  @override
  String friendsOffline() => "Vašich priateľov môžte vidieť len online";

  @override
  String offlineDesc() => "Ak chcete zobraziť, pripojte sa k internetu";

  @override
  String offlineInit() => "Ste offline";

  @override
  String offlineInitDesc() => "Na inicializáciu aplikácie je potrebný internet";

  @override
  String confirmActivityDeletion() => "Vymazať aktivitu";

  @override
  String confirmActivityDeletionDesc() =>
      "Ste si istý že checete vymazať túto aktivitu?";

  @override
  String delete() => "Vymazať";

  @override
  String cancel() => "Späť";
}

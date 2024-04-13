import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mtaa_project/settings/language_profile.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/support.dart';

part "language_en.dart";
part "language_sk.dart";

final _languages = <String, LanguageProfile>{
  "en": _LanguageEN(),
  "sk": _LanguageSK(),
};

class LanguageManager with ChangeNotifier, ChangeNotifierAsync {
  LanguageManager._();
  static final instance = LanguageManager._();

  var _language = _languages["en"]!;
  LanguageProfile get language => _language;

  void _setLanguage(String code) {
    var language = _languages[code];
    if (language == null) throw SettingsError("Cannot find language $code");

    _language = language;
  }

  Future<void> setLanguage(String code) async {
    _setLanguage(code);
    await Settings.instance.language.setValue(code);
    notifyListenersAsync();
  }

  Future<void> load() async {
    for (final language in _languages.values) {
      initializeDateFormatting(language.locale);
    }

    _setLanguage(Settings.instance.language.getValue());
  }

  List<LanguageProfile> getAvailableLanguages() {
    return [..._languages.values];
  }
}

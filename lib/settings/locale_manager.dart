import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mtaa_project/settings/language_profile.dart';
import 'package:mtaa_project/settings/settings.dart';
import 'package:mtaa_project/support/support.dart';

part "language_en.dart";
part "language_sk.dart";

/// List of all supported languages
final _languages = <String, LanguageProfile>{
  "en": _LanguageEN(),
  "sk": _LanguageSK(),
};

/// Stores the currently selected language
class LanguageManager with ChangeNotifier, ChangeNotifierAsync {
  LanguageManager._();
  static final instance = LanguageManager._();

  /// Currently selected language
  var _language = _languages["en"]!;

  /// Currently selected language
  LanguageProfile get language => _language;

  /// Sets the current language
  void _setLanguage(String code) {
    var language = _languages[code];
    if (language == null) throw SettingsError("Cannot find language $code");

    _language = language;
  }

  /// Calls [_setLanguage] and notifies the listeners
  Future<void> setLanguage(String code) async {
    _setLanguage(code);
    await Settings.instance.language.setValue(code);
    notifyListenersAsync();
  }

  /// Initializes internationalization and sets the current language based on settings
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

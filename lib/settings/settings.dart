import 'dart:async';
import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'package:mtaa_project/app/debug_page.dart';

LocalStorage? _localStorageInstance;
LocalStorage get _localStorage {
  if (_localStorageInstance == null) {
    _localStorageInstance = LocalStorage("store.json");
    _localStorageInstance!.onError.addListener(() {
      debugMessage("[Settings] Error initializing local storage");
    });
  }

  return _localStorageInstance!;
}

/// Prevents multiple concurrent writes to the local storage
Future<void>? _storageLock;

/// Invalid stored data for a [SettingProperty]
class SettingsError implements Exception {
  const SettingsError(this.msg);

  final String msg;

  @override
  String toString() => 'SettingsError: $msg';
}

/// Represents a field stored in local storage
class SettingProperty<T> {
  SettingProperty._(this._key, {T? defaultValue}) : _default = defaultValue;

  /// For the field to be stored as
  final String _key;

  /// Default value, if nothing was stored yet
  final T? _default;

  /// Controller for sending change events
  final _controller = StreamController<T>.broadcast();

  /// Adds a listener for change events
  StreamSubscription<T> addListener(void Function(T newValue) handler) {
    return _controller.stream.listen(handler);
  }

  /// Gets the current stored value
  T getValue() {
    var data = _localStorage.getItem(_key);
    if (data == null) {
      if (null is T) return null as T;
      if (_default != null) return _default;
      throw SettingsError("Stored value $_key: $T is null");
    }

    if ("" is T) {
      return data as T;
    }

    if (0 is T || false is T) {
      return jsonDecode(data as String) as T;
    }

    throw SettingsError("Invalid type $T for settings property");
  }

  /// Sets a new value to be stored
  Future<void> setValue(T value) async {
    if (_storageLock != null) {
      _storageLock!.then((_) => setValue(value));
      return;
    }

    var locker = Completer<void>();
    _storageLock = locker.future;

    _controller.add(value);

    try {
      if (value == null) {
        await _localStorage.deleteItem(_key);
        return;
      }

      if (value is String) {
        await _localStorage.setItem(_key, value);
        return;
      }

      if (value is int || value is bool) {
        await _localStorage.setItem(_key, jsonEncode(value));
        return;
      }

      throw SettingsError("Invalid type $T for settings property");
    } finally {
      _storageLock = null;
      locker.complete();
    }
  }
}

/// Manager for all stored values
class Settings {
  Settings._();
  static final instance = Settings._();

  /// Current auth token to preserve login user
  final authToken = SettingProperty<String?>._("auth-token");

  /// Selected language for localization
  final language = SettingProperty<String>._("language", defaultValue: "en");

  /// If dark theme is enabled
  final darkTheme = SettingProperty<bool>._("dark-theme", defaultValue: false);

  /// If notifications are enabled
  final notificationsEnabled = SettingProperty<bool>._(
    "notifications-enabled",
    defaultValue: false,
  );

  /// User data stored for offline mode
  final cachedUser = SettingProperty<String?>._("cached-user");

  /// Level data stored for offline mode
  final cachedLevels = SettingProperty<String?>._("cached-levels");

  /// Activities stored for offline mode
  final cachedActivities = SettingProperty<String?>._("cached-activities");

  /// Activities stored to be uploaded after offline mode ends
  final cachedUploadQueue = SettingProperty<String?>._("cached-upload-queue");

  /// Waits for the local storage to be ready
  Future<void> ready() {
    return _localStorage.ready;
  }
}

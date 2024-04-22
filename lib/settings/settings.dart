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

Future<void>? _storageLock;

class SettingsError implements Exception {
  const SettingsError(this.msg);

  final String msg;

  @override
  String toString() => 'SettingsError: $msg';
}

class SettingProperty<T> {
  SettingProperty._(this._key, {T? defaultValue}) : _default = defaultValue;

  final String _key;
  final T? _default;
  final _controller = StreamController<T>.broadcast();
  Stream<T> get stream => _controller.stream;

  StreamSubscription<T> addListener(void Function(T newValue) handler) {
    return _controller.stream.listen(handler);
  }

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

class Settings {
  Settings._();
  static final instance = Settings._();

  final authToken = SettingProperty<String?>._("auth-token");
  final language = SettingProperty<String>._("language", defaultValue: "en");
  final darkTheme = SettingProperty<bool>._("dark-theme", defaultValue: false);
  final notificationsEnabled = SettingProperty<bool>._(
    "notifications-enabled",
    defaultValue: false,
  );

  final cachedUser = SettingProperty<String?>._("cached-user");
  final cachedLevels = SettingProperty<String?>._("cached-levels");
  final cachedActivities = SettingProperty<String?>._("cached-activities");
  final cachedUploadQueue = SettingProperty<String?>._("cached-upload-queue");

  Future<void> ready() {
    return _localStorage.ready;
  }
}

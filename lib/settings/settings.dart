import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

LocalStorage? _localStorageInstance;
LocalStorage get _localStorage {
  if (_localStorageInstance == null) {
    _localStorageInstance = LocalStorage("store.json");
    _localStorageInstance!.onError.addListener(() {
      debugPrint("Error initializing local storage");
    });
  }

  return _localStorageInstance!;
}

class SettingsError implements Exception {
  const SettingsError(this.msg);

  final String msg;

  @override
  String toString() => 'SettingsError: $msg';
}

class _SettingProperty<T> {
  _SettingProperty._(this._key, {T? defaultValue}) : _default = defaultValue;

  final String _key;
  final T? _default;

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
      return jsonDecode(T as String) as T;
    }

    throw SettingsError("Invalid type $T for settings property");
  }

  Future<void> setValue(T value) async {
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
  }
}

class Settings {
  Settings._();
  static final instance = Settings._();

  final authToken = _SettingProperty<String?>._("auth-token");
  final language = _SettingProperty<String>._("language", defaultValue: "en");

  Future<void> ready() {
    return _localStorage.ready;
  }
}

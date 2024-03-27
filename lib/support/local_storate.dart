import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

LocalStorage? _localStorage;
LocalStorage get localStorage {
  if (_localStorage == null) {
    _localStorage = LocalStorage("store.json");
    _localStorage!.onError.addListener(() {
      debugPrint("Error initializing local storage");
    });
  }

  return _localStorage!;
}

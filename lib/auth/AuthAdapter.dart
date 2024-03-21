import 'package:flutter/material.dart';
import 'package:mtaa_project/support/Observable.dart';

@immutable
class User {
  const User({required this.email});

  final String email;
}

class AuthAdapter extends Observable<AuthAdapter> {
  AuthAdapter._();
  static final instance = AuthAdapter._();

  User? get user => _user;
  User? _user;
  AuthAdapter setUser(User? value) {
    _user = value;
    setDirty();
    return this;
  }
}

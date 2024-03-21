import 'package:http/http.dart';
import 'package:mtaa_project/auth/user.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/observable.dart';
import 'package:mtaa_project/support/support.dart';

class AuthAdapter extends Observable<AuthAdapter> {
  AuthAdapter._();
  static final instance = AuthAdapter._();

  User? get user => _user;
  User? _user;

  Future<User> register(String fullName, String email, String password) async {
    var response = await post(
      backendURL.resolve("/auth/register"),
      body: <String, dynamic>{
        "fullName": fullName,
        "email": email,
        "password": password,
      },
    );

    var data = processHTTPResponse(response);
    var user = User.fromJson(data);

    _user = user;
    setDirty();

    return user;
  }

  Future<User> login(String email, String password) async {
    var response = await post(
      backendURL.resolve("/auth/login"),
      body: <String, dynamic>{
        "email": email,
        "password": password,
      },
    );

    var data = processHTTPResponse(response);
    var user = User.fromJson(data);

    _user = user;
    setDirty();

    return user;
  }
}

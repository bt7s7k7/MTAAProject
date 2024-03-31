import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/support/exceptions.dart';

Map<String, dynamic> processHTTPResponse(Response response) {
  var error = response.statusCode != 200;
  var body = response.body.isNotEmpty
      ? jsonDecode(response.body) as Map<String, dynamic>
      : <String, dynamic>{};
  if (error) {
    debugPrint("API Error ${response.statusCode}: $body");

    final message = switch (body) {
      {"message": String message} => message,
      {"errors": [{"message": String message}]} => message,
      _ => null,
    };

    if (response.statusCode == 401) throw NotAuthenticatedException();
    if (message == null) throw const APIError("No error message in response");

    throw UserException(message);
  } else {
    return body;
  }
}

void alertError(BuildContext context, String title, UserException exception) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(exception.msg),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void popupResult(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 1),
  ));
}

mixin ChangeNotifierAsync on ChangeNotifier {
  var _dirty = false;

  /// Merges change notifications in one task, so listeners do not need to be rebuild
  /// for every property changed, but only once. Also prevents an error when called
  /// during build of a widget.
  void notifyListenersAsync() {
    if (_dirty) return;
    _dirty = true;
    Future.microtask(
      () {
        _dirty = false;
        notifyListeners();
      },
    );
  }
}

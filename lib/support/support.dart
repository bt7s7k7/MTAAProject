import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/support/exceptions.dart';

Map<String, dynamic> processHTTPResponse(Response response) {
  var error = response.statusCode != 200;
  var body = jsonDecode(response.body) as Map<String, dynamic>;
  if (error) {
    final _ = switch (body) {
      {"message": String message} => throw UserException(message),
      {"errors": [{"message": String message}]} => throw UserException(message),
      _ => throw const APIError("No error message in response"),
    };
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

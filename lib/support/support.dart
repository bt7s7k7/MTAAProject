import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/services/update_aware.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/user/user.dart';

/// Processes a HTTP response, throws errors or returns the response data as JSON
Map<String, dynamic> processHTTPResponse(Response response) {
  var error = response.statusCode != 200;

  var body = switch (response.body.isNotEmpty) {
    true => switch (jsonDecode(response.body)) {
        Map<String, dynamic> result => result,
        List<dynamic> items => <String, dynamic>{"items": items},
        dynamic invalid =>
          throw APIError("Invalid body type ${invalid.runtimeType.toString()}")
      },
    false => <String, dynamic>{}
  };

  if (error) {
    debugMessage("[HTTP] API Error ${response.statusCode}: $body");

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

/// Shows an alert based on an [UserException]
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

/// Shows a toast
void popupResult(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 1),
  ));
}

/// Allows to deffer and merge listener notifications
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

/// Updates a list of entities based on a [UpdateEvent]
void updateList<T>(
    {required UpdateEvent event,
    required List<T> list,
    required int Function(T) idGetter,
    required T Function(Map<String, dynamic>) factory,
    required void Function(void Function()) callback,
    bool updateOnly = false}) {
  var index = list.indexWhere((v) => idGetter(v) == event.id);
  if (index == -1) {
    if (updateOnly) return;
    if (event.value == null) return;

    var activity = factory(event.value!);
    callback(() {
      list.insert(0, activity);
    });

    return;
  }
  if (event.value == null) {
    if (updateOnly) return;
    callback(() {
      list.removeAt(index);
    });
  } else {
    var sourceJSON = event.value!;
    var currentValue = list[index];

    if (currentValue is UpdateAware) {
      currentValue.patchUpdate(sourceJSON);
    }

    var newValue = factory(sourceJSON);
    callback(() {
      list[index] = newValue;
    });
  }
}

/// Updates entity user if relevant, used with [UpdateEvent]
void updateUserInList<T>({
  required User user,
  required List<T> list,
  required int Function(T element) userGetter,
  required T Function(T element, User user) userSetter,
  required void Function() callback,
}) {
  var affected = false;

  for (final (index, element) in list.indexed) {
    var userId = userGetter(element);
    if (userId == user.id) {
      list[index] = userSetter(element, user);
      affected = true;
    }
  }

  if (affected) callback();
}

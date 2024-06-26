import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user.dart';

/// Result of sending an invite returned by the backend
enum SendInviteResult { accepted, sent }

/// Response to an invite to send to the backend
enum InviteResponse { accept, deny }

///Allows for communicating with the friends controller on the backend
class FriendsAdapter with ChangeNotifier, ChangeNotifierAsync {
  FriendsAdapter._();
  static final instance = FriendsAdapter._();

  /// Searches for users based on query string
  Future<List<User>> searchUsers(String query) async {
    var auth = AuthAdapter.instance;
    var url = backendURL.resolveUri(Uri(
      path: "/friend/search",
      queryParameters: {"query": query},
    ));
    var response = await get(url, headers: auth.getAuthorizationHeaders());

    var data = processHTTPResponse(response);
    var users = switch (data) {
      {
        "users": List<dynamic> usersData,
      } =>
        usersData.map((v) => User.fromJson(v)).toList(),
      _ => throw const APIError("Invalid response for friends search")
    };

    return users;
  }

  /// Gets friends and invites
  Future<(List<User>, List<User>)> getFriendState() async {
    var auth = AuthAdapter.instance;
    var response = await get(
      backendURL.resolve("/friend"),
      headers: auth.getAuthorizationHeaders(),
    );

    var data = processHTTPResponse(response);
    var (users, invites) = switch (data) {
      {
        "friends": List<dynamic> usersData,
        "invites": List<dynamic> invitesData,
      } =>
        (
          usersData.map((v) => User.fromJson(v)).toList(),
          invitesData.map((v) => User.fromJson(v)).toList(),
        ),
      _ => throw const APIError("Invalid response for friend state")
    };

    return (users, invites);
  }

  /// Sends an invite to a user
  Future<SendInviteResult> sendInvite(User receiver) async {
    var auth = AuthAdapter.instance;
    var response = await post(
      backendURL.resolve("/friend/invite"),
      body: jsonEncode(<String, dynamic>{"id": receiver.id.toString()}),
      headers: {
        ...auth.getAuthorizationHeaders(),
        "content-type": "application/json",
      },
    );

    var data = processHTTPResponse(response);
    var result = switch (data) {
      {"result": "accepted"} => SendInviteResult.accepted,
      {"result": "sent"} => SendInviteResult.sent,
      _ => throw const APIError("Invalid response for send invite")
    };

    // Log the 'send_invite' event to Firebase Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'send_invite',
      parameters: {
        'receiver_id': receiver
            .id, // Consider anonymizing this if it's personally identifiable information.
        'result': result.toString(), // Log the result of the invite.
      },
    );

    return result;
  }

  /// Responds to an invite
  Future<void> respondInvite(User sender, InviteResponse inviteResponse) async {
    var auth = AuthAdapter.instance;
    var id = sender.id;
    var response = await put(
      backendURL.resolve("/friend/invite/$id/${inviteResponse.name}"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);

    // Log the 'respond_invite' event to Firebase Analytics
    FirebaseAnalytics.instance.logEvent(
      name: 'respond_invite',
      parameters: {
        'sender_id': sender
            .id, // Consider anonymizing this if it's personally identifiable information.
        'response': inviteResponse.name, // Log the response to the invite.
      },
    );
  }

  /// Removes a friendship with the specified user
  Future<void> removeFriend(User friend) async {
    var auth = AuthAdapter.instance;
    var id = friend.id;
    var response = await post(
      backendURL.resolve("/friend/remove/$id"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);
  }
}

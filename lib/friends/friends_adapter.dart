import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mtaa_project/auth/auth_adapter.dart';
import 'package:mtaa_project/auth/user.dart';
import 'package:mtaa_project/constants.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';

enum SendInviteResult { accepted, sent }

enum InviteResponse { accept, deny }

class Invite {
  Invite({required this.id, required this.sender});

  final int id;
  final User sender;

  factory Invite.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": int id, "sender": Map<String, dynamic> sender} =>
        Invite(id: id, sender: User.fromJson(sender)),
      _ => throw const APIError("Invalid fields to load a user"),
    };
  }
}

@immutable
class FriendState {
  const FriendState({required this.friends, required this.invites});

  final List<User> friends;
  final List<User> invites;
}

class FriendsAdapter with ChangeNotifier, ChangeNotifierAsync {
  FriendsAdapter._();
  static final instance = FriendsAdapter._();

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

  Future<SendInviteResult> sendInvite(User receiver) async {
    var auth = AuthAdapter.instance;
    var response = await post(
      backendURL.resolve("/friend/invite"),
      body: <String, dynamic>{"id": receiver.id.toString()},
      headers: auth.getAuthorizationHeaders(),
    );

    var data = processHTTPResponse(response);
    return switch (data) {
      {"result": "accepted"} => SendInviteResult.accepted,
      {"result": "sent"} => SendInviteResult.sent,
      _ => throw const APIError("Invalid response for send invite")
    };
  }

  Future<void> respondInvite(User sender, InviteResponse inviteResponse) async {
    var auth = AuthAdapter.instance;
    var id = sender.id;
    var response = await post(
      backendURL.resolve("/friend/invite/$id/${inviteResponse.name}"),
      headers: auth.getAuthorizationHeaders(),
    );

    processHTTPResponse(response);
  }

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

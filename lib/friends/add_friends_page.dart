import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtaa_project/friends/friends_adapter.dart';
import 'package:mtaa_project/friends/user_list.dart';
import 'package:mtaa_project/layout/layout_config.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  String query = "";
  List<User> users = [];
  Set<User> interactedUsers = {};
  Timer? _debounce;

  Future<void> _searchUsers() async {
    var usersResult = await FriendsAdapter.instance.searchUsers(query);
    setState(() {
      users = usersResult;
    });
  }

  @override
  void initState() {
    super.initState();

    _searchUsers();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      query = value;
      _searchUsers();
    });
  }

  void _sendInvite(User user) async {
    try {
      var result = await FriendsAdapter.instance.sendInvite(user);
      setState(() {
        interactedUsers.add(user);
      });
      if (!mounted) return;
      popupResult(
        context,
        switch (result) {
          SendInviteResult.accepted => "Added friend",
          SendInviteResult.sent => "Invite sent",
        },
      );
    } on UserException catch (err) {
      if (!mounted) return;
      alertError(context, "Send invite", err);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LayoutConfig.instance.setTitle("Add friends");

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: "Search",
              icon: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: UserList(
              users: users,
              onClick: (user) => debugPrint(user.toJson().toString()),
              actionBuilder: (user) => switch (interactedUsers.contains(user)) {
                true => const SizedBox.shrink(),
                false => FilledButton(
                    onPressed: () => _sendInvite(user),
                    child: const Text("Add"),
                  ),
              },
            ),
          )
        ],
      ),
    );
  }
}

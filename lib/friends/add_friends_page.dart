import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtaa_project/auth/user.dart';
import 'package:mtaa_project/friends/friends_adapter.dart';
import 'package:mtaa_project/friends/user_list.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  String query = "";
  List<User> users = [];
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              actionBuilder: (user) => FilledButton(
                onPressed: () {},
                child: const Text("Add"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

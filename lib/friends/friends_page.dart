import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/auth/user.dart';
import 'package:mtaa_project/friends/friends_adapter.dart';
import 'package:mtaa_project/friends/user_list.dart';
import 'package:mtaa_project/layout/layout_config.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<User> users = [];
  List<User> invites = [];

  void _refreshState() async {
    var (users, invites) = await FriendsAdapter.instance.getFriendState();
    setState(() {
      this.users = users;
      this.invites = invites;
    });
  }

  void _respondInvite(User sender, InviteResponse response) async {
    await FriendsAdapter.instance.respondInvite(sender, response);
    _refreshState();
  }

  void _removeFriend(User friend) async {
    await FriendsAdapter.instance.removeFriend(friend);
    _refreshState();
  }

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  @override
  Widget build(BuildContext context) {
    LayoutConfig.instance.setFocusedButton(2).setTitle("Friends");
    var router = GoRouter.of(context);

    var invitesList = UserList(
      users: invites,
      actionBuilder: (user) => Wrap(
        spacing: 10.0,
        children: [
          IconButton.filled(
            onPressed: () => _respondInvite(user, InviteResponse.accept),
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
          IconButton.filled(
            onPressed: () => _respondInvite(user, InviteResponse.deny),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      floatingActionButton: IconButton.filled(
        icon: const Icon(Icons.add),
        onPressed: () => router.goNamed("AddFriends"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ...(switch (invites.isNotEmpty) {
              true => [
                  Card(
                    child: Column(
                      children: [
                        const ListTile(title: Text("Invites")),
                        invitesList,
                      ],
                    ),
                  ),
                ],
              false => [],
            }),
            Expanded(
              child: UserList(
                users: users,
                onClick: (user) => _removeFriend(user),
              ),
            )
          ],
        ),
      ),
    );
  }
}

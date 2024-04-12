import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/friends/friends_adapter.dart';
import 'package:mtaa_project/friends/user_list.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/services/update_service.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<User> users = [];
  List<User> invites = [];

  StreamSubscription<UpdateEvent>? _subscription;

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

  @override
  void initState() {
    super.initState();

    _subscription = UpdateService.instance.addListener((event) {
      if (event.type == "friend") {
        updateList(
          event: event,
          list: users,
          idGetter: (user) => user.id,
          factory: (json) => User.fromJson(json),
          callback: setState,
        );
        return;
      }

      if (event.type == "invite") {
        updateList(
          event: event,
          list: invites,
          idGetter: (user) => user.id,
          factory: (json) => User.fromJson(json),
          callback: setState,
        );
        return;
      }

      if (event.type == "user") {
        updateList(
          event: event,
          list: users,
          idGetter: (user) => user.id,
          factory: (json) => User.fromJson(json),
          callback: setState,
          updateOnly: true,
        );

        updateList(
          event: event,
          list: invites,
          idGetter: (user) => user.id,
          factory: (json) => User.fromJson(json),
          callback: setState,
          updateOnly: true,
        );
      }
    });

    _refreshState();
  }

  @override
  void dispose() {
    _subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        onPressed: () => router.pushNamed("AddFriends"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListenableBuilder(
              listenable: LanguageManager.instance,
              builder: (_, __) => TitleMarker(
                title: LanguageManager.instance.language.friends(),
                focusedButton: 2,
              ),
            ),
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
                onClick: (user) => router.pushNamed("Friend", extra: user),
              ),
            )
          ],
        ),
      ),
    );
  }
}

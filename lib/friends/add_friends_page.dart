import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/friends/friends_adapter.dart';
import 'package:mtaa_project/friends/user_list.dart';
import 'package:mtaa_project/layout/title_marker.dart';
import 'package:mtaa_project/offline_mode/offline_service.dart';
import 'package:mtaa_project/offline_mode/offline_warning.dart';
import 'package:mtaa_project/settings/locale_manager.dart';
import 'package:mtaa_project/support/exceptions.dart';
import 'package:mtaa_project/support/support.dart';
import 'package:mtaa_project/user/user.dart';

/// Page for the user to find friends based on their name
class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  /// Current search query
  String query = "";

  /// Users found using the [query]
  List<User> users = [];

  /// List of users that an invitation has been sent to hide the add button
  Set<User> interactedUsers = {};

  /// Timer for debouncing the search
  Timer? _debounce;

  /// Loads a list of users based on the [query]
  Future<void> _searchUsers() async {
    if (OfflineService.instance.isOffline) return;

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

  /// Event handler for search field changed, performs debouncing before calling [_searchUsers]
  void _onSearchChanged(String value) {
    if (value == "×××dddd") {
      GoRouter.of(context).goNamed("Debug");
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      query = value;
    });
    _searchUsers();
  }

  /// Sends an invite to the specified user
  void _sendInvite(User user) async {
    if (OfflineService.instance.isOffline) return;

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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => TitleMarker(
              title: LanguageManager.instance.language.addFriends(),
            ),
          ),
          ListenableBuilder(
            listenable: LanguageManager.instance,
            builder: (_, __) => TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: LanguageManager.instance.language.search(),
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          OfflineWarning(
            label: () => LanguageManager.instance.language.offlineDesc(),
          ),
          Expanded(
            child: UserList(
              users: users,
              action: (user) => switch (interactedUsers.contains(user)) {
                true => const SizedBox.shrink(),
                false => ListenableBuilder(
                    listenable: LanguageManager.instance,
                    builder: (_, __) => FilledButton(
                      onPressed: () => _sendInvite(user),
                      child: Text(
                        LanguageManager.instance.language.addFriendAction(),
                      ),
                    ),
                  ),
              },
            ),
          )
        ],
      ),
    );
  }
}

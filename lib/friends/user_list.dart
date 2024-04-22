import 'package:flutter/material.dart';
import 'package:mtaa_project/friends/user_view.dart';
import 'package:mtaa_project/user/user.dart';

/// Displays a list of users
class UserList extends StatelessWidget {
  const UserList({
    super.key,
    required this.users,
    this.onClick,
    this.action,
  });

  /// Users to display
  final List<User> users;

  /// Callback after the user has been clicked
  final void Function(User user)? onClick;

  /// Action to show trailing the [ListTile]
  final Widget Function(User user)? action;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: users
          .map(
            (user) => UserView(
              title: user.fullName,
              icon: user.icon,
              subtitle: "${user.points} points",
              onClick: onClick == null ? null : () => onClick!(user),
              action: action == null ? null : action!(user),
            ),
          )
          .toList(),
    );
  }
}

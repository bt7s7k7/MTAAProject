import 'package:flutter/material.dart';
import 'package:mtaa_project/friends/user_view.dart';
import 'package:mtaa_project/user/user.dart';

class UserList extends StatelessWidget {
  const UserList({
    super.key,
    required this.users,
    this.onClick,
    this.actionBuilder,
  });

  final List<User> users;
  final void Function(User user)? onClick;
  final Widget Function(User user)? actionBuilder;

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
              action: actionBuilder == null ? null : actionBuilder!(user),
            ),
          )
          .toList(),
    );
  }
}

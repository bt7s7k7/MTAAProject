import 'package:flutter/material.dart';
import 'package:mtaa_project/user/user_icon.dart';
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
            (user) => _UserElement(
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

class _UserElement extends StatelessWidget {
  const _UserElement(
      {required this.title,
      required this.icon,
      required this.subtitle,
      this.action,
      this.onClick});

  final String title;
  final String? icon;
  final String subtitle;
  final Widget? action;
  final void Function()? onClick;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClick,
      title: Text(title),
      subtitle: Text(subtitle),
      leading: UserIcon(icon: icon),
      trailing: action,
    );
  }
}

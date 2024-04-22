import 'package:flutter/material.dart';
import 'package:mtaa_project/user/user_icon.dart';

class UserView extends StatelessWidget {
  const UserView({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    this.action,
    this.onClick,
  });

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

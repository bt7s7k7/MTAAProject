import 'package:flutter/material.dart';
import 'package:mtaa_project/user/user_icon.dart';

/// Displays a user in a list
class UserView extends StatelessWidget {
  const UserView({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    this.action,
    this.onClick,
  });

  /// Name of the user
  final String title;

  /// URL of the user icon, shows default if `null`
  final String? icon;

  /// Subtitle to display under the user name
  final String subtitle;

  /// Action to show trailing the [ListTile]
  final Widget? action;

  /// Callback after the user has been clicked
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

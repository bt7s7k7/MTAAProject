import 'package:flutter/material.dart';
import 'package:mtaa_project/constants.dart';

class UserIcon extends StatelessWidget {
  const UserIcon({
    super.key,
    required this.icon,
  });

  final String? icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Image.network(
        icon == null ? defaultUserIcon : backendURL.resolve(icon!).toString(),
        fit: BoxFit.cover,
      ),
    );
  }
}

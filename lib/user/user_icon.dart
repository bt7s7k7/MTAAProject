import 'package:flutter/material.dart';
import 'package:mtaa_project/constants.dart';

class UserImage extends StatelessWidget {
  const UserImage({
    super.key,
    required this.icon,
  });

  final String? icon;

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? const Image(
            image: AssetImage("assets/default.png"),
          )
        : Image.network(
            backendURL.resolve(icon!).toString(),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Image(
              image: AssetImage("assets/default.png"),
            ),
          );
  }
}

class UserIcon extends StatelessWidget {
  const UserIcon({
    super.key,
    required this.icon,
  });

  final String? icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: UserImage(icon: icon),
    );
  }
}

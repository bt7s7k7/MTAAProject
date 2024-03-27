import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/layout/layout_config.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    LayoutConfig.instance.setFocusedButton(2).setTitle("Friends");
    var router = GoRouter.of(context);

    return Scaffold(
      floatingActionButton: IconButton.filled(
        icon: const Icon(Icons.add),
        onPressed: () => router.goNamed("AddFriends"),
      ),
      body: const Placeholder(),
    );
  }
}

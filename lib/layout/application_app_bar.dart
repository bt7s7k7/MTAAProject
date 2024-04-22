import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shows the name of the current screen and a back button if necessary
class ApplicationAppBar extends StatelessWidget {
  const ApplicationAppBar({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final showBack = router.canPop();

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
      leading: switch (showBack) {
        false => null,
        true => IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.chevron_left),
          )
      },
      actions: trailing != null ? [trailing!] : [],
    );
  }
}

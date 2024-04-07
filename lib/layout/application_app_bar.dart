import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

AppBar applicationAppBar(BuildContext context, String title,
    {Widget? trailing}) {
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
    actions: trailing != null ? [trailing] : [],
  );
}

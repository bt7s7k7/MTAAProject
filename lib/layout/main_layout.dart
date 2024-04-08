import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/layout/application_app_bar.dart';
import 'package:mtaa_project/layout/layout_config.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final layoutConfig = LayoutConfig.instance;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: layoutConfig,
          builder: (context, __) => applicationAppBar(
            context,
            layoutConfig.title,
            trailing: IconButton(
              onPressed: () => router.pushNamed("Profile"),
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: ListenableBuilder(
        listenable: Listenable.merge([layoutConfig, LanguageManager.instance]),
        builder: (context, child) => BottomNavigationBar(
          currentIndex: layoutConfig.focusedButton,
          onTap: (value) {
            router.goNamed(
              switch (value) {
                0 => "Home",
                1 => "Recording",
                2 => "Friends",
                _ => throw Exception("Invalid button number"),
              },
            );
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: LanguageManager.instance.language.home(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.radio_button_checked),
              label: LanguageManager.instance.language.recording(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: LanguageManager.instance.language.friends(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/layout/application_app_bar.dart';
import 'package:mtaa_project/layout/layout_config.dart';
import 'package:mtaa_project/layout/screen_format_builder.dart';
import 'package:mtaa_project/settings/locale_manager.dart';

final _routes = <({IconData icon, String Function() title, String route})>[
  (
    icon: Icons.home,
    title: () => LanguageManager.instance.language.home(),
    route: "Home"
  ),
  (
    icon: Icons.radio_button_checked,
    title: () => LanguageManager.instance.language.recording(),
    route: "Recording"
  ),
  (
    icon: Icons.people,
    title: () => LanguageManager.instance.language.friends(),
    route: "Friends"
  ),
];

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final layoutConfig = LayoutConfig.instance;

    var appBar = PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ListenableBuilder(
        listenable: layoutConfig,
        builder: (context, __) => ApplicationAppBar(
          title: layoutConfig.title,
          trailing: IconButton(
            onPressed: () => router.pushNamed("Profile"),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ),
      ),
    );

    return ScreenFormatBuilder(
      phoneLayout: () => Scaffold(
        appBar: appBar,
        body: child,
        bottomNavigationBar: ListenableBuilder(
          listenable:
              Listenable.merge([layoutConfig, LanguageManager.instance]),
          builder: (context, child) => BottomNavigationBar(
              currentIndex: layoutConfig.focusedButton,
              onTap: (value) {
                router.goNamed(_routes[value].route);
              },
              items: _routes
                  .map(
                    (route) => BottomNavigationBarItem(
                      icon: Icon(route.icon),
                      label: route.title(),
                    ),
                  )
                  .toList()),
        ),
      ),
      tabletLayout: () => Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 200,
                child: ListenableBuilder(
                  listenable: Listenable.merge(
                      [layoutConfig, LanguageManager.instance]),
                  builder: (_, __) => ListView(
                    children: _routes.indexed
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.$2.title()),
                            leading: Icon(entry.$2.icon),
                            onTap: () {
                              router.goNamed(entry.$2.route);
                            },
                            selected: layoutConfig.focusedButton == entry.$1,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const VerticalDivider(
                thickness: 1,
                width: 1,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Expanded(child: child),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

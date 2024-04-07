import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/activity/recording_page.dart';
import 'package:mtaa_project/auth/login_register_page.dart';
import 'package:mtaa_project/friends/add_friends_page.dart';
import 'package:mtaa_project/friends/friends_page.dart';
import 'package:mtaa_project/home_page.dart';
import 'package:mtaa_project/layout/main_layout.dart';
import 'package:mtaa_project/user/profile_page.dart';

final _rootNavigationKey = GlobalKey<NavigatorState>();
final _homeNavigationKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: "/",
  navigatorKey: _rootNavigationKey,
  routes: [
    GoRoute(
      path: "/login",
      name: "Login",
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: "/register",
      name: "Register",
      builder: (context, state) => const RegisterPage(),
    ),
    ShellRoute(
      navigatorKey: _homeNavigationKey,
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: "/",
          name: "Home",
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: "/profile",
          name: "Profile",
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: "/recording",
          name: "Recording",
          builder: (context, state) => const RecordingPage(),
        ),
        GoRoute(
          path: "/friends",
          name: "Friends",
          builder: (context, state) => const FriendsPage(),
        ),
        GoRoute(
          path: "/friends/add",
          name: "AddFriends",
          builder: (context, state) => const AddFriendsPage(),
        ),
      ],
    ),
  ],
);

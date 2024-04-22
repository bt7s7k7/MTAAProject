import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtaa_project/activity/activity_page.dart';
import 'package:mtaa_project/app/debug_page.dart';
import 'package:mtaa_project/auth/login_register_page.dart';
import 'package:mtaa_project/friends/add_friends_page.dart';
import 'package:mtaa_project/friends/friend_page.dart';
import 'package:mtaa_project/friends/friends_page.dart';
import 'package:mtaa_project/home/home_page.dart';
import 'package:mtaa_project/layout/main_layout.dart';
import 'package:mtaa_project/recording/recording_page.dart';
import 'package:mtaa_project/recording/recording_setup_page.dart';
import 'package:mtaa_project/user/profile_page.dart';
import 'package:mtaa_project/user/user.dart';

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
    GoRoute(
      path: "/recording/active",
      name: "RecordingActive",
      builder: (context, state) => const RecordingPage(),
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
          path: "/activity",
          name: "Activity",
          builder: (context, state) =>
              ActivityPage(activityId: state.extra as int),
        ),
        GoRoute(
          path: "/profile",
          name: "Profile",
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: "/friend",
          name: "Friend",
          builder: (context, state) => FriendPage(user: state.extra as User),
        ),
        GoRoute(
          path: "/recording",
          name: "Recording",
          builder: (context, state) => const RecordingSetupPage(),
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
        GoRoute(
          path: "/_debug",
          name: "Debug",
          builder: (context, state) => const DebugPage(),
        ),
      ],
    ),
  ],
);

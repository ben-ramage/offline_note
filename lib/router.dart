import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_note/app_scaffold_with_navbar.dart';
import 'package:offline_note/features/create/presentation/pages/create_page.dart';
import 'package:offline_note/features/journal/presentation/pages/journal_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/create',
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return AppScaffoldWithNavbar(state: state, child: child);
      },
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreatePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const JournalPage(),
        ),
      ],
    ),
  ],
);

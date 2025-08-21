import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../view/screen/home.dart';
import '../view/screen/post_write_screen.dart';
import '../view/screen/post_write_screen2.dart';
import '../view/screen/post_write_screen3.dart';
import '../view/screen/post_write_screen4.dart';

/// ✅ **홈 브랜치**
StatefulShellBranch buildHomeBranch() {
  return StatefulShellBranch(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'Home'),
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          print('home_routes.dart: 홈 경로 접근');
          return const NoTransitionPage(
            child: RootScreen(label: 'COSMOSX 월컴', detailsPath: "/PostWrite"),
          );
        },
        routes: [
          GoRoute(
            path: 'PostWrite',
            redirect: (context, state) {
              final isLoggedIn = Provider.of<UserProvider>(context, listen: false).accessToken != null;
              return isLoggedIn ? null : '/login';
            },
            pageBuilder: (context, state) {
              print('home_routes.dart: PostWrite 경로 접근');
              final extraData = state.extra as Map<String, dynamic>?;
              final lastParam = extraData?['lastParam'];
              return MaterialPage(
                key: state.pageKey,
                child: PostWrite(passedSubMenuCode: lastParam),
              );
            },
          ),
          GoRoute(
            path: 'PostWriteScreen2',
            redirect: (context, state) {
              final isLoggedIn = Provider.of<UserProvider>(context, listen: false).accessToken != null;
              return isLoggedIn ? null : '/login';
            },
            pageBuilder: (context, state) {
              print('home_routes.dart: PostWrite 경로 접근');
              final extraData = state.extra as Map<String, dynamic>?;
              final lastParam = extraData?['lastParam'];
              return MaterialPage(
                key: state.pageKey,
                child: PostWriteScreen2(passedSubMenuCode: lastParam),
              );
            },
          ),
          GoRoute(
            path: 'PostWriteScreen3',
            redirect: (context, state) {
              final isLoggedIn = Provider.of<UserProvider>(context, listen: false).accessToken != null;
              return isLoggedIn ? null : '/login';
            },
            pageBuilder: (context, state) {
              print('home_routes.dart: PostWrite 경로 접근');
              final extraData = state.extra as Map<String, dynamic>?;
              final lastParam = extraData?['lastParam'];
              return MaterialPage(
                key: state.pageKey,
                child: PostWriteScreen3(passedSubMenuCode: lastParam),
              );
            },
          ),
          GoRoute(
            path: 'PostWriteScreen4',
            redirect: (context, state) {
              final isLoggedIn = Provider.of<UserProvider>(context, listen: false).accessToken != null;
              return isLoggedIn ? null : '/login';
            },
            pageBuilder: (context, state) {
              print('home_routes.dart: PostWrite 경로 접근');
              final extraData = state.extra as Map<String, dynamic>?;
              final lastParam = extraData?['lastParam'];
              return MaterialPage(
                key: state.pageKey,
                child: PostWriteScreen4(passedSubMenuCode: lastParam),
              );
            },
          ),
        ],
      ),
    ],
  );
}

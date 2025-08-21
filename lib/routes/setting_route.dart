import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view/screen/home.dart';

StatefulShellBranch buildSettingsBranch() {
  return StatefulShellBranch(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: '설정'),
    routes: [
      GoRoute(
        path: '/set',
        pageBuilder: (context, state) {
          print('settings_routes.dart: /set 접근');
          return const NoTransitionPage(child: RootScreen(label: '설정', detailsPath: '/set/details'));
        },
      ),
    ],
  );
}

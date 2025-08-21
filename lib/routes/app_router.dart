import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view/screen/post_write_screen2.dart';
import '../view/widget/navigation.dart';

import 'free_route.dart';
import 'home_route.dart';
import 'member_route.dart';
import 'news_route.dart';
import 'notice_route.dart';
import 'record_route.dart';

/// 🔑 **네비게이터 키 설정**
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// 🏠 **GoRouter 설정**
final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        buildHomeBranch(),       // ✅ 홈 관련 라우트
        buildNewsBranch(),       // ✅ 뉴스 및 공지사항 라우트
        buildFreeBranch(),  // ✅ 커뮤니티 라우트
        buildRecordBranch(),   // ✅ 설정 관련 라우트
        buildNoticeBranch(),     // ✅ 로그인 및 회원 관련 라우트
        buildMemberBranch(),
      ],
    ),

    /// 📌 **이미지 업로드 포함 글쓰기**
    // GoRoute(
    //   path: '/PostWriteWithImageUpload',
    //   pageBuilder: (context, state) {
    //     print('app_router.dart: PostWriteWithImageUpload 경로 접근');
    //     return MaterialPage(
    //       key: state.pageKey,
    //       child: PostWriteWithImageUpload(),
    //     );
    //   },
    // ),
  ],
);

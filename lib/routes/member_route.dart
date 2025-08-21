import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../view/screen/board/etcXXX/sns_signup.dart';
import '../view/screen/member_page.dart';
import '../view/screen/login.dart';
import '../view/screen/local_signup.dart';

/// ✅ **회원 관련 브랜치**
StatefulShellBranch buildMemberBranch() {
  return StatefulShellBranch(
    navigatorKey: GlobalKey<NavigatorState>(debugLabel: '멤버정보'),
    routes: [
      /// 🏠 **회원 페이지 (로그인 상태일 때)**
      GoRoute(
        path: '/member',
        pageBuilder: (context, state) {
          print('member_routes.dart: /member 접근');
          final userProvider = Provider.of<UserProvider>(context, listen: false);

          if (userProvider.accessToken != null) {
            return const NoTransitionPage(child: MemberPage());
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login', extra: UniqueKey());
            });
            return const NoTransitionPage(child: Login(label: 'Login', detailsPath_a: '/login'));
          }
        },
      ),

      /// 🔑 **로그인 페이지**
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) {
          print('member_routes.dart: /login 접근');
          final userProvider = Provider.of<UserProvider>(context, listen: false);

          return userProvider.accessToken == null
              ? const NoTransitionPage(child: Login(label: 'Login', detailsPath_a: '/login/details'))
              : const NoTransitionPage(child: MemberPage());
        },
      ),

      /// 📝 **로컬 회원가입 페이지**
      GoRoute(
        path: '/localSignup',
        builder: (context, state) {
          print('member_routes.dart: /localSignup 접근');
          return const LocalSignupPage();
        },
      ),

      /// 🌎 **SNS 회원가입 페이지**
      GoRoute(
        path: '/snsSignup',
        builder: (context, state) {
          print('member_routes.dart: /snsSignup 접근');
          return const SnsSignupPage();
        },
      ),

      /// 🔄 **카카오 로그인 콜백**
      GoRoute(
        path: '/auth/kakao/callback',
        builder: (context, state) {
          print('member_routes.dart: /auth/kakao/callback 접근');

          final queryParams = state.queryParameters;
          final code = queryParams['code'];
          final error = queryParams['error'];

          if (error != null) {
            print('member_routes.dart: 카카오 로그인 에러: $error');
          } else if (code != null) {
            print('member_routes.dart: 카카오 로그인 인증 코드: $code');
          }

          // 로그인 후 메인 페이지로 리다이렉트
          return const MemberPage();
        },
      ),
    ],
  );
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_naver_login/flutter_naver_login.dart';

import '../../provider/user_provider.dart';

class LoginoutWidget extends StatefulWidget {
  const LoginoutWidget({super.key});

  @override
  _LoginoutWidgetState createState() => _LoginoutWidgetState();
}

class _LoginoutWidgetState extends State<LoginoutWidget> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isHovered = false;

  Future<void> _logout(BuildContext context, UserProvider userProvider) async {
    // 로컬 로그아웃
    userProvider.clearUser();
    await _secureStorage.deleteAll();
    print('Secure Storage 비움');

    // 카카오 로그아웃 시도
    try {
      if (kIsWeb) {
        print('웹에서 카카오 로그아웃 시도');
        await kakao.UserApi.instance.logout();
        await kakao.UserApi.instance.unlink();
      } else {
        print('모바일에서 카카오 로그아웃 시도');
        await kakao.UserApi.instance.logout();
        await kakao.UserApi.instance.unlink();
      }
      print('카카오 로그아웃 성공');
    } catch (error) {
      print('카카오 로그아웃 실패: $error');
    }

    // 구글 로그아웃 시도
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      print('구글 로그아웃 성공');
    } catch (error) {
      print('구글 로그아웃 실패: $error');
    }

    // // 네이버 로그아웃 시도
    // try {
    //   await FlutterNaverLogin.logOut();
    //   print('네이버 로그아웃 성공');
    // } catch (error) {
    //   print('네이버 로그아웃 실패: $error');
    // }

    // 로그인 페이지로 이동
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username.isNotEmpty;

    return Row(
      children: [
        if (isLoggedIn) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                userProvider.nickname,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _logout(context, userProvider),
            icon: const Icon(Icons.logout),
          ),
        ] else ...[
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: InkWell(
              onTap: () => context.go('/login'),
              borderRadius: BorderRadius.circular(20), // 타원형을 위한 경계 설정
              splashColor: Colors.grey, // 클릭 시의 잔물결 색상
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1), // 타원형 모양
                  color: _isHovered ? Colors.transparent : Colors.transparent,
                ),
                child: const Row(
                  children: [
                    Text('로그인 ',style: TextStyle(fontSize: 12,color: Colors.white),),
                    Icon(Icons.login),
                  ],
                ),
              ),
            ),
          ),

        ],
      ],
    );
  }
}

class LoginStyle2 extends StatefulWidget {
  const LoginStyle2({super.key});

  @override
  State<LoginStyle2> createState() => _LoginStyle2State();
}

class _LoginStyle2State extends State<LoginStyle2> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _logout(BuildContext context, UserProvider userProvider) async {
    // 로컬 로그아웃
    userProvider.clearUser();
    await _secureStorage.deleteAll();
    print('Secure Storage 비움');

    // 카카오 로그아웃 시도
    try {
      if (kIsWeb) {
        print('웹에서 카카오 로그아웃 시도');
        await kakao.UserApi.instance.logout();
        await kakao.UserApi.instance.unlink();
      } else {
        print('모바일에서 카카오 로그아웃 시도');
        await kakao.UserApi.instance.logout();
        await kakao.UserApi.instance.unlink();
      }
      print('카카오 로그아웃 성공');
    } catch (error) {
      print('카카오 로그아웃 실패: $error');
    }

    // 구글 로그아웃 시도
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      print('구글 로그아웃 성공');
    } catch (error) {
      print('구글 로그아웃 실패: $error');
    }

    // // 네이버 로그아웃 시도
    // try {
    //   await FlutterNaverLogin.logOut();
    //   print('네이버 로그아웃 성공');
    // } catch (error) {
    //   print('네이버 로그아웃 실패: $error');
    // }

    // 로그인 페이지로 이동
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username.isNotEmpty;

    return Row(
      children: [
        if (isLoggedIn) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  const Text('신 대항해시대 이제는 우주다'),
                  Text(
                    userProvider.nickname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _logout(context, userProvider),
            icon: const Icon(Icons.logout),
          ),
        ] else ...[
          const Text('신 대항해시대 이제는 우주다'),
        ],
      ],
    );
  }
}


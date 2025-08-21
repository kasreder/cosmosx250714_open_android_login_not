import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage 패키지 임포트
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../../../provider/user_provider.dart';
import '../../../widget/appbar.dart';
import '../../../widget/drawer.dart';

class SnsSignupPage extends StatefulWidget {
  const SnsSignupPage({super.key});

  @override
  State<SnsSignupPage> createState() => _SnsSignupPageState();
}

class _SnsSignupPageState extends State<SnsSignupPage> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Secure Storage 인스턴스
  String? accessToken;
  String? readaccessToken;
  String? refreshToken;
  String? provider;

  Future<void> _handleGoogleSignup() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
    );
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      print('Google User: ${account?.displayName}');
    } catch (error) {
      print('Google Sign-In Error: $error');
    }
  }

  // Future<void> _handleKakaoSignup(BuildContext context) async {
  //   try {
  //     kakao.OAuthToken token;
  //
  //     // 로딩 인디케이터 표시
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return Center(child: CircularProgressIndicator());
  //       },
  //     );
  //
  //     // 카카오톡 앱이 설치되어 있는지 확인하고 로그인 시도
  //     if (await kakao.isKakaoTalkInstalled()) {
  //       token = await kakao.UserApi.instance.loginWithKakaoTalk();
  //     } else {
  //       token = await kakao.UserApi.instance.loginWithKakaoAccount();
  //     }
  //
  //     // JWT 토큰 생성
  //     final jwt = JWT({
  //       'provider': 'kakao',
  //       'accessToken': token.accessToken,
  //     });
  //
  //     final signedToken = jwt.sign(SecretKey('cosmosxkey'));
  //
  //     // 서버로 로그인 요청
  //     var response = await _dio.post(
  //       'https://terraforming.info/api/auth/kakao',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $signedToken',
  //         },
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final user = response.data;
  //
  //       setState(() {
  //         Provider.of<UserProvider>(context, listen: false).setUser(
  //           username: user['username'] ?? 'Unknown',
  //           email: user['email'] ?? 'Unknown',
  //           nickname: user['nickname'] ?? 'Unknown',
  //           accessToken: signedToken,
  //           profession: user['profession'] ?? 'profession1',
  //           provider: user['provider'] ?? 'provider1',
  //           sns_id: user['sns_id'] ?? 1234,
  //           id: user['id'] ?? 1111,
  //         );
  //       });
  //
  //       // 보안 저장소에 토큰 저장
  //       _secureStorage.write(key: 'kakao_token', value: token.accessToken);
  //       _secureStorage.write(key: 'jwt_token', value: signedToken);
  //       _secureStorage.write(key: 'provider', value: user['provider'] ?? 'provider1');
  //
  //       // 성공 시 메인 페이지로 전환
  //       Navigator.of(context).pop(); // 로딩 인디케이터 닫기
  //       GoRouter.of(context).go('/');
  //     } else {
  //       Navigator.of(context).pop(); // 로딩 인디케이터 닫기
  //       print('Failed to sign up with Kakao');
  //     }
  //   } catch (error) {
  //     Navigator.of(context).pop(); // 로딩 인디케이터 닫기
  //     print('Kakao Sign-Up Error: $error');
  //   }
  // }


  Future<void> _handleKakaoSignup(BuildContext context) async {
    try {
      print('_handleKakaoSignup 1');
      kakao.OAuthToken token;
      print('_handleKakaoSignup 2');

      // 앱에서 사용 시
      if (await kakao.isKakaoTalkInstalled()) {
        print('_handleKakaoSignup 3');
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        print('_handleKakaoSignup 4');
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      print('Kakao User 받은토큰 Token: $token');


      // JWT 토큰 생성
      final jwt = JWT({
        'provider': 'kakao',
        'accessToken': token.accessToken,
      });

      // 비밀키로 서명
      final signedToken = jwt.sign(SecretKey('cosmosxkey')); // 서버와 동일한 시크릿 키 사용
      print('Kakao User 백엔드로 Token: $signedToken');

      var response = await _dio.post(
        'https://terraforming.info/api/auth/kakao',
        options: Options(
          headers: {
            'Authorization': 'Bearer $signedToken',
           },
        ),
      );

      if (response.statusCode == 200) {
        final user = response.data;
        print('전달받은 유저 데이터: $user');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<UserProvider>(context, listen: false).setUser(
            username: user['username'] ?? 'username세팅',
            email: user['email'] ?? 'email세팅',
            nickname: user['nickname'] ?? 'nickname세팅',
            accessToken: signedToken,
            grade: user['grade'] ?? 'grade세팅',
            provider: user['provider'] ?? 'provider세팅',
            sns_id: user['sns_id'] ?? 1234,
            id: user['id'] ?? 1111,
            points: user['points'],
          );

          accessToken=user['accessToken'];
          readaccessToken = _secureStorage.read(key: 'jwt_token') as String?;
          // refreshToken=user['refreshToken'];
          provider=user['provider'];
          print('시큐어저장소에 최초 저장될 수작업된 토큰: $signedToken');
          print('시큐어저장소에 최초 저장될 되돌려받은 토큰: $accessToken');
          print('시큐어저장소에 최초 시큐어 저장될 카카오 토큰: $readaccessToken');
          // print('시큐어저장소에 리프레쉬 저장될 토큰: $refreshToken');
          print('시큐어저장소에 리프레쉬 저장될 토큰: $provider');

          // 화면을 즉시 전환
          GoRouter.of(context).go('/');
          print('화면을 즉시 전환');

          // 토큰을 Flutter Secure Storage에 저장
          // await _secureStorage.write(key: 'jwt_token', value:accessToken );
          _secureStorage.write(key: 'jwt_token', value:signedToken );
          _secureStorage.write(key: 'provider', value:provider);
          _secureStorage.write(key: 'kakao_token', value:token.accessToken );
          // if (user['refreshToken'] != null) {
          //   _secureStorage.write(key: 'refresh_token', value:refreshToken);
          // }
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   GoRouter.of(context).go('/');
          // });

          print('정보 등록 완료 200끝');
        });

        print('정보 등록 완료');
      } else {
        print('Failed to sign up with Kakao');
      }
    } catch (error) {
      print('Kakao Sign-Up Error: $error');
    }
  }

  // Future<void> _handleNaverSignup() async {
  //   try {
  //     final NaverLoginResult result = await FlutterNaverLogin.logIn();
  //     print('Naver User: ${result.account}');
  //   } catch (error) {
  //     print('Naver Sign-In Error: $error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "SNS Signup",
        appBar: AppBar(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _handleGoogleSignup,
              child: const Text('Sign Up with Google'),
            ),
            ElevatedButton(
              onPressed: () => _handleKakaoSignup(context),
              child: const Text('Sign Up with Kakao'),
            ),
            // ElevatedButton(
            //   onPressed: _handleNaverSignup,
            //   child: const Text('Sign Up with Naver'),
            // ),
          ],
        ),
      ),
      drawer: const BaseDrawer(),
    );
  }
}

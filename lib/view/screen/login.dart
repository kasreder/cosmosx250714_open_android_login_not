import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;

import '../../provider/user_provider.dart';
import '../../util/responsive_width.dart';
import '../widget/appbar.dart';
import '../widget/drawer.dart';

class Login extends StatefulWidget {
  const Login({
    required this.label,
    required this.detailsPath_a,
    super.key,
  });

  final String label;
  final String detailsPath_a;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  bool rememberMe = false; // 상태 변수 예시

  String? accessToken;
  String? refreshToken;
  String? provider;

  Future<void> _login() async {
    try {
      var response = await _dio.post('https://api.cosmosx.co.kr/login', data: {
        'email': _emailController.text,
        'password': _passwordController.text,
      });

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is Map && data.containsKey('accessToken')) {
          print('Response data: $data');
          accessToken = data['accessToken'];
          Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);
          print('Decoded Token: $decodedToken');

          if (decodedToken.containsKey('username') &&
              decodedToken.containsKey('nickname') &&
              decodedToken.containsKey('email') &&
              decodedToken.containsKey('id')) {
            print('Decoded username: ${decodedToken['username']}');
            print('Decoded nickname: ${decodedToken['nickname']}');
            print('Decoded email: ${decodedToken['email']}');
            print('Decoded id: ${decodedToken['id']}');
            print('Data points: ${data['points']}');

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<UserProvider>(context, listen: false).setUser(
                username: decodedToken['username'],
                nickname: decodedToken['nickname'],
                email: decodedToken['email'],
                grade: decodedToken['grade'] ?? 'grade로그인세팅',
                provider: decodedToken['provider'] ?? '가입경로1',
                sns_id: 0 ?? 1,
                id: decodedToken['id'],
                accessToken: accessToken,
                points: data['points'],

              );
            });

            await _secureStorage.write(key: 'jwt_token', value: accessToken);
            print('Token saved securely');

            // 페이지의 모든 값을 초기화
            setState(() {
              _emailController.clear(); // 입력값 초기화
              _passwordController.clear(); // 입력값 초기화
              rememberMe = false; // 상태 초기화
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              GoRouter.of(context).go('/');
            });

            String? token = await _secureStorage.read(key: 'jwt_token');
            if (token != null) {
              print('Token retrieved from secure storage: $token');
            } else {
              print('Token not found in secure storage');
            }
          } else {
            print('Decoded token does not contain necessary fields');
          }
        } else {
          String errorMessage = data['message'] ?? 'Login failed. Please try again.';
          _showError(errorMessage);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleKakaoSignup(BuildContext context) async {
    try {
      kakao.OAuthToken token;

      if (await kakao.isKakaoTalkInstalled()) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      print('Kakao User 받은토큰 Token: $token');
      await _secureStorage.write(key: 'kakao_token', value: token.accessToken);

      final signedToken = _createJWT(token.accessToken, 'kakao');
      await _secureStorage.write(key: 'jwt_token', value: signedToken);
      print('Kakao User 백엔드로 Token: $signedToken');

      var response = await _dio.post(
        'https://api.cosmosx.co.kr/api/auth/kakao',
        options: Options(
          headers: {
            'Authorization': 'Bearer $signedToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final user = response.data;
        print('전달받은 유저 데이터: $user');
        // WidgetsBinding.instance.addPostFrameCallback((_) async
        {
          Provider.of<UserProvider>(context, listen: false).setUser(
            username: user['username'] ?? 'username로그인세팅',
            email: user['email'] ?? 'email로그인세팅',
            nickname: user['nickname'] ?? 'nickname로그인세팅',
            accessToken: signedToken,
            grade: user['grade'] ?? 'grade로그인세팅',
            provider: user['provider'] ?? 'provider로그인세팅',
            sns_id: user['sns_id'] ?? 1234,
            id: user['id'] ?? 1111,
            points: user['points'],
          );

          accessToken = user['accessToken'];
          provider = user['provider'];
          print('시큐어저장소에 저장된 되돌려받은 토큰: $accessToken');
          print('시큐어저장소에 저장된 토큰: $provider');

          await _secureStorage.write(key: 'provider', value: provider);

          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   GoRouter.of(context).go('/');
          // });
          GoRouter.of(context).go('/');
        }
        // );
        print('정보 등록 완료');
      } else {
        print('Failed to sign up with Kakao');
      }
    } catch (error) {
      print('Kakao Sign-Up Error: $error');
    }
  }

  Future<void> _handleGoogleSignup() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com');
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      print('Google User: ${account?.displayName}');
    } catch (error) {
      print('Google Sign-In Error: $error');
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

  String _createJWT(String accessToken, String provider) {
    final jwt = JWT({
      'provider': provider,
      'accessToken': accessToken,
    });
    return jwt.sign(SecretKey('cosmosxkey'));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SelectableText(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "로그인",
        appBar: AppBar(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: ResponsiveWidth.getResponsiveWidth(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 100, 8, 8),
                  child: Text('아직은 소박하지만, 큰 꿈을 품고 함께 만들어가는 커뮤니티',style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w800),),
                ),
                const Text('우주로 가자',style: TextStyle(fontSize: 60, fontWeight: FontWeight.w800),),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 40),
                  child: Column(
                    children: [
                      Text('두근두근 새로운 소식, 어디 없나?',style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w800),),
                      Text('사람들의 반응까지, 나도 한 마디 얹어 볼까?',style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w800),),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width:ResponsiveWidth_B.getResponsiveWidth(context),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () => _handleKakaoSignup(context),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.yellow; // 호버 시 배경색
                              }
                              return Theme.of(context).primaryColorLight;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Theme.of(context).primaryColor;
                              }
                              return Theme.of(context).primaryColor; // 기본 배경색을 테마 색상으로
                            }),
                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // 모서리를 각지게 설정
                              ),
                            ),
                            // elevation: WidgetStateProperty.all(0), // 버튼 그림자 제거
                          ),
                          child: const Text('카카오로 로그인'),
                        ),
                      ),
                    ),
                    
                    // Padding(
                    //   padding: const EdgeInsets.all(4.0),
                    //   child: ElevatedButton(
                    //     onPressed: _handleGoogleSignup,
                    //     child: const Text('구글로 로그인'),
                    //   ),
                    // ),
                    SizedBox(
                      width:ResponsiveWidth_B.getResponsiveWidth(context),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Enter Email'),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ),
                    SizedBox(
                      width:ResponsiveWidth_B.getResponsiveWidth(context),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Enter Password'),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      width:ResponsiveWidth_B.getResponsiveWidth(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                context.go('/localSignup');
                              },
                              child: const Text('로컬 가입하기',style: TextStyle(fontSize:15),),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              onPressed: _login,
                              child: const Text('로그인',style: TextStyle(fontSize:15),),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(16.0),
                          //   child: ElevatedButton(
                          //     onPressed: _handleNaverSignup,
                          //     child: const Text('네이버로 로그인'),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Text('COSMOSX',style: TextStyle(fontSize: 70, color: Colors.black12,fontWeight: FontWeight.w800),),
              ],
            ),
          ),
        ),
      ),
      drawer: const BaseDrawer(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:go_router/go_router.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:provider/provider.dart';
//
// import '../../provider/user_provider.dart';
// import '../widget/appbar.dart';
// import '../widget/drawer.dart';
//
// class Login extends StatefulWidget {
//   const Login({
//     required this.label,
//     required this.detailsPath_a,
//     super.key,
//   });
//
//   final String label;
//   final String detailsPath_a;
//
//   @override
//   State<Login> createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//   final Dio _dio = Dio();
//
//   Future<void> _login() async {
//     try {
//       var response = await _dio.post('https://api.cosmosx.co.kr/login', data: {
//         'email': _emailController.text,
//         'password': _passwordController.text,
//       });
//
//       print('Response status: ${response.statusCode}');
//       // print('Response body: ${response.data}');
//
//       if (response.statusCode == 200) {
//         var data = response.data;
//         // if (data is Map && data.containsKey('accessToken') && data.containsKey('refreshToken')) {
//         if (data is Map && data.containsKey('accessToken')) {
//
//           print('Response data: $data');
//           String accessToken = data['accessToken'];
//           // String refreshToken = data['refreshToken'];
//           Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
//           print('Decoded Token: $decodedToken');
//
//           // Ensure the token contains the necessary fields
//           if (decodedToken.containsKey('username') && decodedToken.containsKey('nickname') && decodedToken.containsKey('email') && decodedToken.containsKey('id')) {
//             print('Decoded username: ${decodedToken['username']}');
//             print('Decoded nickname: ${decodedToken['nickname']}');
//             print('Decoded email: ${decodedToken['email']}');
//             print('Decoded id: ${decodedToken['id']}');
//
//             ///개인정보 입력
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Provider.of<UserProvider>(context, listen: false).setUser(
//                 username: decodedToken['username'],
//                 nickname: decodedToken['nickname'],
//                 email: decodedToken['email'],
//                 profession: decodedToken['profession'] ?? 'Unknown',
//                 provider: decodedToken['provider'] ?? '가입경로1',
//                 sns_id: 0 ?? 1,
//                 id: decodedToken['id'],
//                 accessToken: accessToken,
//                 // refreshToken: refreshToken,
//               );
//             });
//
//             // Save token securely
//             await _secureStorage.write(key: 'jwt_token', value: accessToken);
//             // await _secureStorage.write(key: 'refresh_token', value: refreshToken);
//             print('Save token securely');
//
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               GoRouter.of(context).go('/');
//             });
//
//             String? token = await _secureStorage.read(key: 'jwt_token');
//             if (token != null) {
//               print('Token retrieved from secure storage: $token');
//             } else {
//               print('Token not found in secure storage');
//             }
//           } else {
//             print('Decoded token does not contain necessary fields');
//           }
//         } else {
//           String errorMessage = data['message'] ?? 'Login failed. Please try again.';
//           _showError(errorMessage);
//         }
//       } else {
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       _showError(e.toString());
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: SelectableText(message),
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: BaseAppBar(
//         title: "새소식",
//         appBar: AppBar(),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Enter Email'),
//                 keyboardType: TextInputType.text,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(labelText: 'Enter Password'),
//                 keyboardType: TextInputType.text,
//                 obscureText: true,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: _login,
//                 child: const Text('로그인'),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextButton(
//                 onPressed: () {
//                   context.go('/localSignup');
//                 },
//                 child: const Text('로컬 가입하기'),
//               ),
//             ),
//             TextButton(
//               onPressed: () => context.go(widget.detailsPath_a),
//               child: const Text('View details'),
//             ),
//           ],
//         ),
//       ),
//       drawer: const BaseDrawer(),
//     );
//   }
// }

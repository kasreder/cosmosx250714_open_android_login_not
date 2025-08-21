import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
  String _nickname = '';
  String _email = '';
  String _grade = '';
  String _provider = '';
  int _id = 0;
  int _sns_id = 0;
  String? _accessToken;
  String? _refreshToken;
  int _points = 0;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  String get username => _username;
  String get nickname => _nickname;
  String get email => _email;
  String get grade => _grade;
  String? get provider => _provider;
  int get id => _id;
  int? get sns_id => _sns_id;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  int get points => _points;

  UserProvider() {
    loadTokens().then((_) {
      checkAccessTokenAndFetchUserData();
    });
  }

  void setUser({
    required String username,
    required String nickname,
    required String email,
    required String grade,
    String? provider,
    required int id,
    int? sns_id,
    String? accessToken,
    String? refreshToken,
    required int points,
  }) {
    _username = username;
    _nickname = nickname;
    _email = email;
    _grade = grade;
    _provider = provider!;
    _id = id;
    _sns_id = sns_id!;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _points = points;
    notifyListeners();
  }

  void updatePoints(int points) {
    _points = points;
    notifyListeners();
  }

  void clearUser() {
    _username = '';
    _nickname = '';
    _email = '';
    _grade = '';
    _provider = '';
    _id = 0;
    _sns_id = 0;
    _accessToken = null;
    _refreshToken = null;
    _secureStorage.delete(key: 'jwt_token');
    _secureStorage.delete(key: 'refresh_token');
    _points = 0;
    notifyListeners();
  }

  Future<void> loadTokens() async {
    try {
      print('loadTokens 시작');
      _accessToken = await _secureStorage.read(key: 'jwt_token');
      print('loadTokens _accessToken');
      _refreshToken = await _secureStorage.read(key: 'refresh_token');
      print('loadTokens _refreshToken');
      _provider = (await _secureStorage.read(key: 'provider'))!;
      print('loadTokens _provider');
      print('loadTokens 완료: accessToken=$_accessToken, refreshToken=$_refreshToken, provider=$_provider');
      print('loadTokens userProvider.loadTokens 끝');
      notifyListeners();
    } catch (e) {
      print('loadTokens 에러: $e');
    }
  }

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    _accessToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    }
    await _secureStorage.write(key: 'jwt_token', value: accessToken);
    notifyListeners();
  }

  Future<void> checkAccessTokenAndFetchUserData() async {
    try {
      print('checkAccessTokenAndFetchUserData 시작');
      print('_accessToken : $_accessToken ');
      print('_provider : $_provider ');

      if (_accessToken != null) {
        print('1');
        if (_provider == 'kakao') {
          print('2');
          // 카카오 사용자인 경우 토큰 만료 검증을 생략하고 바로 fetchSNSUserData 호출
          await fetchSNSUserData();
        } else {
          print('3');
          // 로컬 사용자인 경우 토큰 만료 검증 후 fetchUserData 호출
          if (!isTokenExpired(_accessToken!)) {
            print('isTokenExpired $_accessToken');
            await fetchUserData();
          } else {
            clearUser();
            print('checkAccessTokenAndFetchUserData 클리어');
          }
        }
        print('checkAccessTokenAndFetchUserData 끝');
      } else {
        clearUser();
        print('checkAccessTokenAndFetchUserData 클리어');
      }
    } catch (e) {
      print('checkAccessTokenAndFetchUserData 에러: $e');
      clearUser();
    }
  }

  Future<void> fetchUserData() async {
    print('로컬 로그인 인증하기 시작---------------------------');
    try {
      var response = await _dio.get(
        'https://api.cosmosx.co.kr/api/auth/verifyTokenAndFetchUser',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );
      print('로컬 로그인 인증하기 응답 대기 대기받음 ---------');
      print('로컬 Response status: ${response.statusCode}');
      print('로컬 Response status: ${response.data}');
      if (response.statusCode == 200) {
        print('로컬 로그인 인증하기 응답 받음 ---------');
        var data = response.data;
        String? token = data['accessToken'];
        print('111133333 decode: $token');
        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
          print('111133333 decodedToken: $decodedToken');
          print(decodedToken['username']);
          if (decodedToken.isNotEmpty) {
            setUser(
              username: decodedToken['username'],
              nickname: decodedToken['nickname'],
              email: decodedToken['email'] ?? '메일체크',
              grade: decodedToken['grade'] ?? '등급체크',
              provider: decodedToken['provider'] ?? '가입경로',
              sns_id: decodedToken['id'] ?? 111111110,
              accessToken: token,
              id: decodedToken['id'] ?? 0,
              points: data['points'],
            );
            print('11112 Response status: ${decodedToken['nickname']}');
          } else {
            clearUser();
          }
        } catch (e) {
          print('JWT 디코딩 에러: $e');
          clearUser();
        }
      } else {
        clearUser();
      }
    } catch (e) {
      print('로컬 로그인 인증하기 에러: $e');
      clearUser();
    }
  }

  Future<void> fetchSNSUserData() async {
    print('카카오 로그인 인증하기 시작---------------------------');

    // // JWT 토큰 생성
    // final jwt = JWT({
    //   'provider': 'kakao',
    //   'accessToken': _accessToken,
    // });
    //
    // // 비밀키로 서명
    // final signedToken = jwt.sign(SecretKey('cosmosxkey'));



    try {
      var response = await _dio.post(
        'https://api.cosmosx.co.kr/api/auth/kakao',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken'},
        ),
      );
      print('SNS 로그인 인증하기 응답 대기 대기받음 ---------');
      print('SNS Response status: ${response.statusCode}');
      print('SNS Response status: ${response.data}');
      if (response.statusCode == 200) {
        print('SNS 로그인 인증하기 응답 받음 ---------');
        final user = response.data;
        print('전달받은 유저 데이터: $user');
        print('SNS 정보: $user');
        if (user != null) {
          setUser(
            username: user['username'] ?? 'username세팅',
            email: user['email'] ?? 'email세팅',
            nickname: user['nickname'] ?? 'email팅',
            accessToken: user['accessToken'],
            grade: user['grade'] ?? 'grade세팅',
            provider: user['provider'] ?? 'provider세팅',
            sns_id: user['sns_id'] ?? 1234,
            id: user['id'] ?? 1111,
            points: user['points'],
          );
          print('SNS Response status: ${user['nickname']}');
        } else {
          clearUser();
        }
      } else {
        clearUser();
      }
    } catch (snsError) {
      print('SNS 로그인 인증하기 에러: $snsError');
      clearUser();
    }
  }

  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  @override
  String toString() {
    return 'UserProvider{'
        'username: $_username, '
        'nickname: $_nickname, '
        'email: $_email, '
        'grade: $_grade, '
        'provider: $_provider, '
        'id: $_id, '
        'sns_id: $_sns_id, '
        'accessToken: $_accessToken, '
        'refreshToken: $_refreshToken}';
  }
}

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

String createJWT(String accessToken, String provider) {
  final jwt = JWT({
    'provider': provider,
    'accessToken': accessToken,
  });
  return jwt.sign(SecretKey('cosmosxkey'));
}
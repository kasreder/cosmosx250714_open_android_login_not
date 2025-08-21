import 'package:jwt_decode/jwt_decode.dart';


Future<bool> isTokenValid(String token) async {
  try {
    if (Jwt.isExpired(token)) {
      return false;
    }
    return true;
  } catch (e) {
    print('Error checking token validity: $e');
    return false;
  }
}

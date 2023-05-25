import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = new FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> readToken() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token;
  }
}
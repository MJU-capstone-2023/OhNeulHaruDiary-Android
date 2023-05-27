import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = new FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> readAccessToken() async {
    String? token = await _storage.read(key: 'access_token');
    return token;
  }

  Future<String?> readRefreshToken() async {
    String? token = await _storage.read(key: 'refresh_token');
    return token;
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // 액세스 토큰 재발급
  Future<String?> refreshTokenToAccessToken(String refreshToken) async {
    final refreshUrl =
        Uri.parse('http://15.165.111.191:8001/auth/token/refresh');
    final response =
        await http.post(refreshUrl, body: {'refresh_token': refreshToken});

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['access_token'];
    }

    return null;
  }

  // 액세스 토큰을 사용하여 인증된 API 호출을 수행
  Future<http.Response> authorizedApiCall(String url, String accessToken,
      {Map<String, String>? headers}) async {
    headers ??= {};
    headers['Authorization'] = 'Bearer $accessToken';
    final response = await http.get(Uri.parse(url), headers: headers);

    // 리프레시 토큰을 사용하여 새로운 액세스 토큰을 갱신하고 다시 호출
    if (response.statusCode == 401) {
      final refreshToken = await readRefreshToken();
      if (refreshToken != null) {
        final newAccessToken = await refreshTokenToAccessToken(refreshToken);
        if (newAccessToken != null) {
          headers['Authorization'] = 'Bearer $newAccessToken';
          final newResponse = await http.get(Uri.parse(url), headers: headers);
          return newResponse;
        }
      }
    }

    return response;
  }
}

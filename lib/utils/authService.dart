import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException(this.message);
}

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
        Uri.parse('${dotenv.env['BASE_URL']}/auth/token/refresh');
    final response =
        await http.post(refreshUrl, body: {'refresh_token': refreshToken});

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['access_token'];
    }

    return null;
  }

  // 액세스 토큰을 사용하여 인증된 API 호출을 수행
  Future<http.Response> get(String url, String accessToken,
      {Map<String, String>? headers}) async {
    return authorizedApiCall(url, accessToken, method: 'GET', headers: headers);
  }

  Future<http.Response> post(String url, String accessToken,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    return authorizedApiCall(url, accessToken,
        method: 'POST', headers: headers, body: body);
  }

  Future<http.Response> patch(String url, String accessToken,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    return authorizedApiCall(url, accessToken,
        method: 'PATCH', headers: headers, body: body);
  }

  Future<http.Response> delete(String url, String accessToken,
      {Map<String, String>? headers}) async {
    return authorizedApiCall(url, accessToken,
        method: 'DELETE', headers: headers);
  }

  Future<http.Response> put(String url, String accessToken,
      {Map<String, String>? headers}) async {
    return authorizedApiCall(url, accessToken,
        method: 'PUT', headers: headers);
  }

  Future<http.Response> authorizedApiCall(String url, String accessToken,
      {Map<String, String>? headers,
      Map<String, dynamic>? body,
      required String method}) async {
    headers ??= {};
    headers['Authorization'] = 'Bearer $accessToken';
    headers['Content-Type'] = 'application/json';

    http.Response response;
    Uri uri = Uri.parse(url);

    String? bodyJson;
    if (body != null) {
      bodyJson = jsonEncode(body);
    }

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: bodyJson);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: bodyJson);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode == 401) {
      final refreshToken = await readRefreshToken();
      if (refreshToken != null) {
        final newAccessToken = await refreshTokenToAccessToken(refreshToken);
        if (newAccessToken != null) {
          headers['Authorization'] = 'Bearer $newAccessToken';
          return authorizedApiCall(url, newAccessToken,
              headers: headers, body: body, method: method);
        }
      }
      throw UnauthenticatedException('No refresh token available'); // 리프레시 토큰이 없을 때
    }

    return response;
  }
}

import 'dart:convert';

import 'package:SoundTrek/models/JWT.dart';
import 'package:SoundTrek/resources/Endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthenticationService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> register(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse(Endpoints.register),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      JWT jwt = JWT.fromJson(jsonDecode(response.body));
      await secureStorage.write(key: 'jwt_token', value: jwt.token);
      await secureStorage.write(key: 'userId', value: jwt.userId.toString());
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(Endpoints.login),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      JWT jwt = JWT.fromJson(jsonDecode(response.body));
      await secureStorage.write(key: 'jwt_token', value: jwt.token);
      await secureStorage.write(key: 'userId', value: jwt.userId.toString());
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  Future<String?> getUID() async {
    return await secureStorage.read(key: 'userId');
  }

  Future<bool> isTokenExpired() async {
    String? token = await secureStorage.read(key: 'jwt_token');
    if (token != null) {
      return JwtDecoder.isExpired(token);
    }
    return true;
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'userId');
  }
}

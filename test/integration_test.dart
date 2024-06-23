import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Register a new user', () async {
    var response = await http.post(
      Uri.parse('http://10.205.8.136:5274/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'newUserTest',
        'email': 'newusertest@example.com',
        'password': 'test123',
      }),
    );

    expect(response.statusCode, 200);
    var data = jsonDecode(response.body);
    expect(data['Token'], isNotNull);
    expect(data['UserId'], isNotNull);
  });

  test('Login existing user', () async {
    var response = await http.post(
      Uri.parse('http://10.205.8.136:5274/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': 'existingUser',
        'password': 'userPassword',
      }),
    );

    expect(response.statusCode, 200);
    var data = jsonDecode(response.body);
    expect(data['Token'], isNotNull);
    expect(data['UserId'], isNotNull);
  });

  test('Fetch latest noise level map', () async {
    var response = await http.get(Uri.parse('http://10.205.8.136:5274/latestMap'));
    expect(response.statusCode, 200);
    List noiseLevels = jsonDecode(response.body);
    expect(noiseLevels.isNotEmpty, true);
    expect(noiseLevels.first['latitude'], isNotNull);
    expect(noiseLevels.first['longitude'], isNotNull);
    expect(noiseLevels.first['lAeq'], isNotNull);
  });
}

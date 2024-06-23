import 'dart:convert';

import 'package:SoundTrek/models/Geofence.dart';
import 'package:SoundTrek/models/NoiseLevel.dart';
import 'package:SoundTrek/resources/Endpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('User Authentication', () {
    test('User registration', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == Endpoints.register) {
          return http.Response('{"success": true, "userId": 1}', 200);
        }
        return http.Response('Error', 404);
      });

      var response = await client.post(Uri.parse(Endpoints.register), body: {
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'testpassword',
      });

      expect(response.statusCode, 200);
      expect(response.body, contains('success'));
    });

    test('User login', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == Endpoints.login) {
          return http.Response('{"token": "fake_token", "userId": 1}', 200);
        }
        return http.Response('Error', 404);
      });

      var response = await client.post(Uri.parse(Endpoints.login), body: {
        'email': 'test@example.com',
        'password': 'testpassword',
      });

      expect(response.statusCode, 200);
      expect(response.body, contains('token'));
    });
  });

  group('Noise Level Data', () {
    test('Fetch latest noise map', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == Endpoints.latestMap) {
          return http.Response('[{"latitude": 10.0, "longitude": 20.0, "lAeq": 50.0}]', 200);
        }
        return http.Response('Error', 404);
      });

      var response = await client.get(Uri.parse(Endpoints.latestMap));
      List<NoiseLevel> noiseLevels = (jsonDecode(response.body) as List).map((e) => NoiseLevel.fromJson(e)).toList();

      expect(response.statusCode, 200);
      expect(noiseLevels.first.LAeq, 50.0);
    });
  });

  group('Geofence Data', () {
    test('Fetch geofence data', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == Endpoints.geofence(1)) {
          // Assuming geofence method is correctly defined to fetch by ID
          return http.Response('{"geofenceId": 1, "latitude": 44.5000, "longitude": 26.0500}', 200);
        }
        return http.Response('Error', 404);
      });

      var response = await client.get(Uri.parse(Endpoints.geofence(1) as String));
      Geofence geofence = Geofence.fromJson(jsonDecode(response.body));

      expect(response.statusCode, 200);
      expect(geofence.geofenceId, 1);
    });
  });

  group('Achievement Data', () {
    test('Fetch achievement', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == Endpoints.latestMap) {
          return http.Response('[{"latitude": 10.0, "longitude": 20.0, "lAeq": 50.0}]', 200);
        }
        return http.Response('Error', 404);
      });

      var response = await client.get(Uri.parse(Endpoints.latestMap));
      List<NoiseLevel> noiseLevels = (jsonDecode(response.body) as List).map((e) => NoiseLevel.fromJson(e)).toList();

      expect(response.statusCode, 200);
      expect(noiseLevels.first.LAeq, 50.0);
    });
  });

  group('User_info Data', () {
    test('Fetch user data', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == Endpoints.geofence(1)) {
          // Assuming geofence method is correctly defined to fetch by ID
          return http.Response('{"geofenceId": 1, "latitude": 44.5000, "longitude": 26.0500}', 200);
        }
        return http.Response('Error', 404);
      });

      var response = await client.get(Uri.parse(Endpoints.geofence(1) as String));
      Geofence geofence = Geofence.fromJson(jsonDecode(response.body));

      expect(response.statusCode, 200);
      expect(geofence.geofenceId, 1);
    });
  });
}

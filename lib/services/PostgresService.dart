import 'dart:convert';

import 'package:SoundTrek/models/NoiseLevel.dart';
import 'package:SoundTrek/models/UsersInfo.dart';
import 'package:SoundTrek/resources/Endpoints.dart';
import 'package:http/http.dart' as http;

class PostgresService {
  Future<List<NoiseLevel>> fetchMap() async {
    final response = await http.get(Uri.parse(Endpoints.latestMap));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      List<NoiseLevel> noiseLevels = jsonData.map((json) => NoiseLevel.fromJson(json)).toList();
      return noiseLevels;
    } else {
      throw Exception('Failed to load noise level');
    }
  }

  Future<UsersInfo> fetchUserInfo(int userId) async {
    final response = await http.get(Uri.parse(Endpoints.userInfoById(userId)));

    if (response.statusCode == 200) {
      dynamic jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      UsersInfo user = UsersInfo.fromJson(jsonData);
      return user;
    } else {
      throw Exception('Failed to load User Info');
    }
  }

  Future<NoiseLevel> fetchNoiseLevel(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(Endpoints.getNoiseLevel(latitude, longitude)));

    if (response.statusCode == 200) {
      dynamic jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      NoiseLevel noiseLevel = NoiseLevel.fromJson(jsonData);
      return noiseLevel;
    } else {
      return NoiseLevel(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        LAeq: 0,
        LA50: 0,
        measurementsCount: 0,
      );
    }
  }

  Future<http.Response> postNoiseLevel(NoiseLevel noiseLevel) async {
    final url = Uri.parse(Endpoints.addNoiseLevel);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(noiseLevel.toJson());

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      print('NoiseLevel posted successfully: ${response.body}');
    } else {
      print('Failed to post NoiseLevel: ${response.statusCode}');
    }

    return response;
  }

  Future<void> updateUserScore(int userId, int score) async {
    final url = Uri.parse(Endpoints.updateUserScore(userId));
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'newScore': score});

    http.put(url, headers: headers, body: body);
  }

  Future<void> updateUserStreak(int userId, int streak) async {
    final url = Uri.parse(Endpoints.updateUserStreak(userId));
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'newStreak': streak});

    http.put(url, headers: headers, body: body);
  }

  Future<void> updateUserTimeMeasured(int userId, int timeMeasured) async {
    final url = Uri.parse(Endpoints.updateUserTimeMeasured(userId));
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'newTimeMeasured': "00:00:${timeMeasured.toString().padLeft(2, '0')}"});

    http.put(url, headers: headers, body: body);
  }

  Future<void> updateUserAllTimeMeasured(int userId, int allTimeMeasured) async {
    final url = Uri.parse(Endpoints.updateUserAllTimeMeasured(userId));
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'newAllTimeMeasured': "00:00:${allTimeMeasured.toString().padLeft(2, '0')}"});

    http.put(url, headers: headers, body: body);
  }

  Future<List<UsersInfo>> getTopUsersByScore() async {
    final response = await http.get(Uri.parse(Endpoints.topUsersByScore));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      List<UsersInfo> users = jsonData.map((json) => UsersInfo.fromJson(json)).toList();
      return users;
    } else {
      throw Exception('Failed to load top users by score');
    }
  }

  Future<List<UsersInfo>> getTopUsersByMaxScore() async {
    final response = await http.get(Uri.parse(Endpoints.topUsersByMaxScore));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      List<UsersInfo> users = jsonData.map((json) => UsersInfo.fromJson(json)).toList();
      return users;
    } else {
      throw Exception('Failed to load top users by max score');
    }
  }

  Future<List<UsersInfo>> getTopUsersByStreak() async {
    final response = await http.get(Uri.parse(Endpoints.topUsersByStreak));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      List<UsersInfo> users = jsonData.map((json) => UsersInfo.fromJson(json)).toList();
      return users;
    } else {
      throw Exception('Failed to load top users by streak');
    }
  }

  Future<List<UsersInfo>> getTopUsersByAllTimeStreak() async {
    final response = await http.get(Uri.parse(Endpoints.topUsersByAllTimeStreak));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData.toString());
      List<UsersInfo> users = jsonData.map((json) => UsersInfo.fromJson(json)).toList();
      return users;
    } else {
      throw Exception('Failed to load top users by all time streak');
    }
  }
}

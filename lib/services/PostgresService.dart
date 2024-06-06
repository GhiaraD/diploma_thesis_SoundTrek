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
}

class Endpoints {
  // static const String apiName = "http://192.168.2.234:5274";

  static const String apiName = "http://10.205.8.136:5274";

  // Auth endpoints
  static const String register = "$apiName/register";
  static const String login = "$apiName/login";

  // Noise Level endpoints
  static String getNoiseLevel(double latitude, double longitude) =>
      "$apiName/noiseLevel?latitude=$latitude&longitude=$longitude";
  static const String addNoiseLevel = "$apiName/noiseLevel";
  static const String latestMap = "$apiName/latestMap";

  static String noiseLevelsByDay(double latitude, double longitude, String day) =>
      "$apiName/noiseLevelsByDay?latitude=$latitude&longitude=$longitude&day=$day";

  static String noiseLevelsByMonth(double latitude, double longitude, String month) =>
      "$apiName/noiseLevelsByMonth?latitude=$latitude&longitude=$longitude&day=$month";

  static String noiseLevelsByYear(double latitude, double longitude, String year) =>
      "$apiName/noiseLevelsByYear?latitude=$latitude&longitude=$longitude&day=$year";

  static String noiseLevelsByWeek(double latitude, double longitude, String weekStartDay) =>
      "$apiName/noiseLevelsByWeek?latitude=$latitude&longitude=$longitude&day=$weekStartDay";

  // User Info endpoints
  static String userInfoById(int userId) => "$apiName/userInfo/$userId";
  static const String topUsersByScore = "$apiName/userInfo/score";
  static const String topUsersByMaxScore = "$apiName/userInfo/maxScore";
  static const String topUsersByStreak = "$apiName/userInfo/streak";
  static const String topUsersByAllTimeStreak = "$apiName/userInfo/allTimeStreak";

  // Update user info endpoints with placeholders for userId
  static String updateUserScore(int userId) => "$apiName/userInfo/$userId/score";

  static String updateUserStreak(int userId) => "$apiName/userInfo/$userId/streak";

  static String updateUserTimeMeasured(int userId) => "$apiName/userInfo/$userId/timeMeasured";

  static String updateUserAllTimeMeasured(int userId) => "$apiName/userInfo/$userId/allTimeMeasured";
}

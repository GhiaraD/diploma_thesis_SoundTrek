class UsersInfo {
  int userId;
  DateTime createdAt;
  String username;
  int streak;
  int allTimeStreak;
  int score;
  int maxScore;
  String monthMaxScore;
  Duration timeMeasured;
  Duration maxTime;
  String monthMaxTime;
  Duration allTimeMeasured;

  UsersInfo({
    this.userId = 0,
    DateTime? createdAt,
    this.username = "",
    this.streak = 0,
    this.allTimeStreak = 0,
    this.score = 0,
    this.maxScore = 0,
    this.monthMaxScore = "",
    this.timeMeasured = Duration.zero,
    this.maxTime = Duration.zero,
    this.monthMaxTime = "",
    this.allTimeMeasured = Duration.zero,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory constructor to create an instance from JSON
  factory UsersInfo.fromJson(Map<String, dynamic> json) {
    return UsersInfo(
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      username: json['username'],
      streak: json['streak'],
      allTimeStreak: json['allTimeStreak'],
      score: json['score'],
      maxScore: json['maxScore'],
      monthMaxScore: json['monthMaxScore'],
      timeMeasured: parseDuration(json['timeMeasured']),
      maxTime: parseDuration(json['maxTime']),
      monthMaxTime: json['monthMaxTime'],
      allTimeMeasured: parseDuration(json['allTimeMeasured']),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'username': username,
      'streak': streak,
      'allTimeStreak': allTimeStreak,
      'score': score,
      'maxScore': maxScore,
      'monthMaxScore': monthMaxScore,
      'timeMeasured': timeMeasured.inMinutes,
      'maxTime': maxTime.inMinutes,
      'monthMaxTime': monthMaxTime,
      'allTimeMeasured': allTimeMeasured.inMinutes,
    };
  }
}

Duration parseDuration(String s) {
  if (s[0] == "'") s = s.substring(1, s.length - 1);
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  List<String> parts = s.split('.');
  if (parts.length > 1) {
    days = int.parse(parts[0]);
    parts = parts[1].split(':');
  } else {
    parts = parts[0].split(':');
  }
  days = int.parse(parts[0]);
  hours = int.parse(parts[1]);
  minutes = int.parse(parts[2]);
  return Duration(days: days, hours: hours, minutes: minutes, seconds: seconds);
}

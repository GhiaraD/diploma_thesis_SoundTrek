import 'dart:convert';

class NoiseLevel {
  final num latitude;
  final num longitude;
  final DateTime timestamp;
  final num LAeq;
  final num LA50;
  final num measurementsCount;

  NoiseLevel(
      {required this.latitude,
      required this.longitude,
      required this.timestamp,
      required this.LAeq,
      required this.LA50,
      required this.measurementsCount});

  factory NoiseLevel.fromJson(Map<String, dynamic> json) {
    return NoiseLevel(
      latitude: json['lat'],
      longitude: json['long'],
      timestamp: DateTime.parse(json['time']),
      LAeq: json['lAeq'],
      LA50: json['lA50'],
      measurementsCount: json['measurementsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'long': longitude,
      'time': timestamp.toIso8601String(),
      'lAeq': LAeq,
      'lA50': LA50,
      'measurementsCount': measurementsCount,
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}

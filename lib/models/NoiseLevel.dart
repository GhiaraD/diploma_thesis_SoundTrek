import 'dart:convert';

class NoiseLevel {
  final num? latitude;
  final num? longitude;
  final DateTime timestamp;
  num? LAeq;
  num? LA50;
  final num? measurementsCount;

  NoiseLevel(
      {required this.latitude,
      required this.longitude,
      required this.timestamp,
      required this.LAeq,
      required this.LA50,
      required this.measurementsCount});

  factory NoiseLevel.fromJson(Map<String, dynamic> json) {
    return NoiseLevel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['time']),
      LAeq: json['lAeq'],
      LA50: json['lA50'],
      measurementsCount: json['measurementsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'time': timestamp.toIso8601String(),
      'lAeq': LAeq,
      'lA50': LA50,
      'measurementsCount': measurementsCount,
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  static void sortNoiseLevels(List<NoiseLevel> noiseLevels) {
    noiseLevels.sort((a, b) {
      if (a.latitude == b.latitude && a.longitude == b.longitude) {
        return a.timestamp.compareTo(b.timestamp);
      } else {
        if (a.latitude != b.latitude) {
          return a.latitude!.compareTo(b.latitude!);
        } else {
          return a.longitude!.compareTo(b.longitude!);
        }
      }
    });
  }
}

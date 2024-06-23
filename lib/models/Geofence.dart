class Geofence {
  int geofenceId;
  double latitude;
  double longitude;
  double radius;
  double multiplier;
  String color;

  Geofence({
    required this.geofenceId,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.multiplier,
    required this.color,
  });

  // Factory constructor for creating a new Geofence instance from a map (deserialization)
  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      geofenceId: json['geofenceId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      multiplier: json['multiplier'],
      color: json['color'],
    );
  }

  // Method for converting Geofence instance to a map (serialization)
  Map<String, dynamic> toJson() {
    return {
      'geofenceId': geofenceId,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'multiplier': multiplier,
      'color': color,
    };
  }
}

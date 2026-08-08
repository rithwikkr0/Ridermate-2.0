/// RiderMate 2.0 — Route Model & Polyline Structure
class RoutePoint {
  final double latitude;
  final double longitude;
  final double speedKmh;
  final int timestamp;
  final double elevationMeters;
  final double headingDegrees;
  final double accuracyMeters;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.timestamp,
    required this.elevationMeters,
    this.headingDegrees = 0,
    this.accuracyMeters = 0,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'speedKmh': speedKmh,
        'timestamp': timestamp,
        'elevationMeters': elevationMeters,
        'headingDegrees': headingDegrees,
        'accuracyMeters': accuracyMeters,
      };

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        speedKmh: (json['speedKmh'] as num).toDouble(),
        timestamp: json['timestamp'] as int,
        elevationMeters: (json['elevationMeters'] as num).toDouble(),
        headingDegrees: (json['headingDegrees'] as num?)?.toDouble() ?? 0,
        accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble() ?? 0,
      );
}

class RouteModel {
  final String id;
  final String name;
  final List<RoutePoint> polylinePoints;

  const RouteModel({
    required this.id,
    required this.name,
    required this.polylinePoints,
  });
}

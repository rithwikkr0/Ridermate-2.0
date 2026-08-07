/// RiderMate 2.0 — Route Model & Polyline Structure
class RoutePoint {
  final double latitude;
  final double longitude;
  final double speedKmh;
  final int timestamp;
  final double elevationMeters;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.timestamp,
    required this.elevationMeters,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'speedKmh': speedKmh,
        'timestamp': timestamp,
        'elevationMeters': elevationMeters,
      };

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        speedKmh: (json['speedKmh'] as num).toDouble(),
        timestamp: json['timestamp'] as int,
        elevationMeters: (json['elevationMeters'] as num).toDouble(),
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

/// RiderMate 2.0 — Ride Trajectory Point Model
class RidePointModel {
  final double latitude;
  final double longitude;
  final int timestamp;
  final double speed; // km/h
  final double heading; // degrees (0 - 360)
  final double accuracy; // meters

  const RidePointModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speed,
    this.heading = 0.0,
    this.accuracy = 0.0,
  });

  /// Validates whether coordinates fall within valid physical Earth boundaries.
  bool get isValid =>
      latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0 &&
      !(latitude == 0.0 && longitude == 0.0);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'speed': speed,
        'heading': heading,
        'accuracy': accuracy,
      };

  factory RidePointModel.fromJson(Map<String, dynamic> json) => RidePointModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: json['timestamp'] as int,
        speed: (json['speed'] as num).toDouble(),
        heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      );
}

/// RiderMate 2.0 — Ride Trajectory Point Model
/// Ported from Project B types.ts
class RidePointModel {
  final double latitude;
  final double longitude;
  final int timestamp;
  final double speed; // km/h

  const RidePointModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speed,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'speed': speed,
      };

  factory RidePointModel.fromJson(Map<String, dynamic> json) => RidePointModel(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timestamp: json['timestamp'] as int,
        speed: (json['speed'] as num).toDouble(),
      );
}

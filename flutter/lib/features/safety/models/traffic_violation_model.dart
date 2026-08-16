/// RiderMate 2.0 — Traffic Violation & Safety Event Data Model
enum ViolationType {
  overspeed,
  wrongWay,
  routeDeviation,
  harshBraking,
  harshAcceleration,
  dangerousCornering,
  other;

  static ViolationType fromString(String val) {
    return ViolationType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ViolationType.other,
    );
  }

  String get displayName {
    switch (this) {
      case ViolationType.overspeed:
        return 'Overspeed Warning';
      case ViolationType.wrongWay:
        return 'Wrong-Way Route Alert';
      case ViolationType.routeDeviation:
        return 'Route Deviation';
      case ViolationType.harshBraking:
        return 'Harsh Braking Event';
      case ViolationType.harshAcceleration:
        return 'Harsh Acceleration';
      case ViolationType.dangerousCornering:
        return 'Dangerous Cornering';
      case ViolationType.other:
        return 'Safety Event';
    }
  }
}

enum ViolationSeverity {
  low,
  medium,
  high,
  critical;

  static ViolationSeverity fromString(String val) {
    return ViolationSeverity.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ViolationSeverity.low,
    );
  }
}

class TrafficViolation {
  final String id;
  final String userId;
  final String? rideId;
  final String? vehicleId;
  final ViolationType type;
  final ViolationSeverity severity;
  final int pointsDeducted;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double speedKmh;
  final double speedLimitKmh;
  final double confidence;
  final String source;
  final String evidence;
  final String status;

  const TrafficViolation({
    required this.id,
    required this.userId,
    this.rideId,
    this.vehicleId,
    required this.type,
    this.severity = ViolationSeverity.low,
    required this.pointsDeducted,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.speedKmh = 0.0,
    this.speedLimitKmh = 80.0,
    this.confidence = 1.0,
    this.source = 'telemetry',
    this.evidence = '',
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'ride_id': rideId,
      'vehicle_id': vehicleId,
      'type': type.name,
      'severity': severity.name,
      'points': pointsDeducted,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'speed': speedKmh,
      'speed_limit': speedLimitKmh,
      'confidence': confidence,
      'source': source,
      'evidence': evidence,
      'status': status,
    };
  }

  factory TrafficViolation.fromMap(Map<String, dynamic> map) {
    return TrafficViolation(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      rideId: map['ride_id'] as String?,
      vehicleId: map['vehicle_id'] as String?,
      type: ViolationType.fromString(map['type'] as String? ?? 'other'),
      severity: ViolationSeverity.fromString(map['severity'] as String? ?? 'low'),
      pointsDeducted: (map['points'] as num? ?? 0).toInt(),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      speedKmh: (map['speed'] as num? ?? 0.0).toDouble(),
      speedLimitKmh: (map['speed_limit'] as num? ?? 80.0).toDouble(),
      confidence: (map['confidence'] as num? ?? 1.0).toDouble(),
      source: map['source'] as String? ?? 'telemetry',
      evidence: map['evidence'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
    );
  }
}

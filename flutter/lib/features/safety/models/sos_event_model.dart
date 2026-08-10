import 'dart:convert';

enum SosStatus { initiated, countdown, active, cancelled, completed, failed }

/// RiderMate 2.0 — Canonical SOS Event Model
class SosEventModel {
  final String id;
  final String userId;
  final String? rideId;
  final SosStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime? locationTimestamp;
  final DateTime startedAt;
  final DateTime? cancelledAt;
  final DateTime? resolvedAt;
  final List<String> contactAttempts;
  final String message;

  const SosEventModel({
    required this.id,
    required this.userId,
    this.rideId,
    this.status = SosStatus.initiated,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.locationTimestamp,
    required this.startedAt,
    this.cancelledAt,
    this.resolvedAt,
    this.contactAttempts = const [],
    this.message = '',
  });

  SosEventModel copyWith({
    String? id,
    String? userId,
    String? rideId,
    SosStatus? status,
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? locationTimestamp,
    DateTime? startedAt,
    DateTime? cancelledAt,
    DateTime? resolvedAt,
    List<String>? contactAttempts,
    String? message,
  }) {
    return SosEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rideId: rideId ?? this.rideId,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      locationTimestamp: locationTimestamp ?? this.locationTimestamp,
      startedAt: startedAt ?? this.startedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      contactAttempts: contactAttempts ?? this.contactAttempts,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'ride_id': rideId,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'location_timestamp': locationTimestamp?.toIso8601String(),
      'started_at': startedAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'contact_attempts': jsonEncode(contactAttempts),
      'message': message,
    };
  }

  factory SosEventModel.fromMap(Map<String, dynamic> map) {
    SosStatus parseStatus(dynamic raw) {
      if (raw == null) return SosStatus.initiated;
      try {
        return SosStatus.values.byName(raw.toString().toLowerCase());
      } catch (_) {
        return SosStatus.initiated;
      }
    }

    DateTime? parseOptDate(dynamic val) {
      if (val == null) return null;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString());
    }

    List<String> parseAttempts(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return SosEventModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      rideId: map['ride_id'] as String?,
      status: parseStatus(map['status']),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      accuracy: map['accuracy'] != null ? (map['accuracy'] as num).toDouble() : null,
      locationTimestamp: parseOptDate(map['location_timestamp']),
      startedAt: parseOptDate(map['started_at']) ?? DateTime.now(),
      cancelledAt: parseOptDate(map['cancelled_at']),
      resolvedAt: parseOptDate(map['resolved_at']),
      contactAttempts: parseAttempts(map['contact_attempts']),
      message: map['message'] as String? ?? '',
    );
  }
}

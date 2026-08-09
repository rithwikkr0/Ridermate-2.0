enum MemoryPrivacy { private, friends, public }

/// RiderMate 2.0 — Canonical Memory Model
class MemoryModel {
  final String id;
  final String userId;
  final String? rideId;
  final String imagePath;
  final String? thumbnailPath;
  final String caption;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MemoryPrivacy privacy;
  final double? rideDistance;
  final int? rideDuration; // in seconds

  const MemoryModel({
    required this.id,
    required this.userId,
    this.rideId,
    required this.imagePath,
    this.thumbnailPath,
    required this.caption,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.createdAt,
    required this.updatedAt,
    this.privacy = MemoryPrivacy.private,
    this.rideDistance,
    this.rideDuration,
  });

  MemoryModel copyWith({
    String? id,
    String? userId,
    String? rideId,
    String? imagePath,
    String? thumbnailPath,
    String? caption,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? createdAt,
    DateTime? updatedAt,
    MemoryPrivacy? privacy,
    double? rideDistance,
    int? rideDuration,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rideId: rideId ?? this.rideId,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      caption: caption ?? this.caption,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      privacy: privacy ?? this.privacy,
      rideDistance: rideDistance ?? this.rideDistance,
      rideDuration: rideDuration ?? this.rideDuration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'ride_id': rideId,
      'image_path': imagePath,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'privacy': privacy.name,
      'ride_distance': rideDistance,
      'ride_duration': rideDuration,
    };
  }

  factory MemoryModel.fromMap(Map<String, dynamic> map) {
    MemoryPrivacy parsePrivacy(dynamic raw) {
      if (raw == null) return MemoryPrivacy.private;
      try {
        return MemoryPrivacy.values.byName(raw.toString().toLowerCase());
      } catch (_) {
        return MemoryPrivacy.private;
      }
    }

    DateTime parseDateTime(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      return DateTime.tryParse(raw.toString()) ?? DateTime.now();
    }

    return MemoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      rideId: map['ride_id'] as String?,
      imagePath: map['image_path'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      caption: map['caption'] as String? ?? '',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      locationName: map['location_name'] as String?,
      createdAt: parseDateTime(map['created_at']),
      updatedAt: parseDateTime(map['updated_at']),
      privacy: parsePrivacy(map['privacy']),
      rideDistance: map['ride_distance'] != null ? (map['ride_distance'] as num).toDouble() : null,
      rideDuration: map['ride_duration'] as int?,
    );
  }
}

import '../../profile/models/vehicle_model.dart';
import '../../profile/models/emergency_contact_model.dart';

class UserPreferences {
  final String theme; // dark, light, system
  final String unit; // km, miles
  final String language;
  final bool pushNotificationsEnabled;

  const UserPreferences({
    this.theme = 'dark',
    this.unit = 'km',
    this.language = 'en',
    this.pushNotificationsEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'unit': unit,
        'language': language,
        'pushNotificationsEnabled': pushNotificationsEnabled,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        theme: json['theme'] as String? ?? 'dark',
        unit: json['unit'] as String? ?? 'km',
        language: json['language'] as String? ?? 'en',
        pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      );
}

/// RiderMate 2.0 — Full User Model
class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String profilePhotoUrl;
  final String bio;
  final String riderLevel;
  final int xp;
  final double totalDistanceKm;
  final int totalRides;
  final List<String> achievements;
  final List<EmergencyContactModel> emergencyContacts;
  final List<VehicleModel> vehicles;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePhotoUrl,
    required this.bio,
    required this.riderLevel,
    required this.xp,
    required this.totalDistanceKm,
    required this.totalRides,
    required this.achievements,
    required this.emergencyContacts,
    required this.vehicles,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  String get photoUrl => profilePhotoUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'profilePhotoUrl': profilePhotoUrl,
        'bio': bio,
        'riderLevel': riderLevel,
        'xp': xp,
        'totalDistanceKm': totalDistanceKm,
        'totalRides': totalRides,
        'achievements': achievements,
        'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
        'preferences': preferences.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserModel.guest() {
    final now = DateTime.now();
    return UserModel(
      id: 'user_demo',
      username: 'demo_rider',
      fullName: 'RiderMate Pro',
      email: 'demo@ridermate.app',
      phone: '+919876543210',
      profilePhotoUrl: '',
      bio: 'RiderMate Rider',
      riderLevel: 'Novice',
      xp: 100,
      totalDistanceKm: 0.0,
      totalRides: 0,
      achievements: const [],
      emergencyContacts: const [],
      vehicles: const [],
      preferences: const UserPreferences(),
      createdAt: now,
      updatedAt: now,
    );
  }
}

import 'dart:convert';

import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/database_service.dart';
import '../../auth/models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/emergency_contact_model.dart';
import 'user_repository.dart';

/// Real SQLite-backed UserRepository.
/// Reads/writes the full UserModel from the `users`, `vehicles`, and
/// `emergency_contacts` tables. Data persists across app restarts.
/// Replaces MockUserRepository.
class SqliteUserRepository implements UserRepository {
  final DatabaseService _db;
  final String userId; // Injected by AuthController after login

  SqliteUserRepository(this._db, {required this.userId});

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<List<VehicleModel>> _loadVehicles() async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'vehicles',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return rows
          .map(
            (r) => VehicleModel(
              id: r['id'] as String,
              brand: r['brand'] as String? ?? r['model_name'] as String? ?? 'Bike',
              model: r['model'] as String? ?? r['model_name'] as String? ?? 'Standard',
              year: r['year'] as int? ?? 2024,
              registrationNumber: r['registration_number'] as String? ?? '',
              fuelType: r['fuel_type'] as String? ?? 'Petrol',
              engineCapacityCc: r['engine_cc'] as int? ?? 150,
              color: r['color'] as String? ?? '',
              serviceDueDate: r['service_due_date'] != null
                  ? (DateTime.tryParse(r['service_due_date'] as String) ?? DateTime.now().add(const Duration(days: 365)))
                  : DateTime.now().add(const Duration(days: 365)),
              isDefault: (r['is_default'] as int? ?? r['is_primary'] as int? ?? 0) == 1,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<EmergencyContactModel>> _loadContacts() async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'emergency_contacts',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return rows
          .map(
            (r) => EmergencyContactModel(
              id: r['id'] as String,
              name: r['name'] as String,
              relation: (r['relation'] ?? r['relationship'] ?? 'Contact') as String,
              phone: (r['phone'] ?? r['phone_number'] ?? '') as String,
              orderIndex: (r['order_index'] ?? r['is_primary'] ?? 0) as int? ?? 0,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<UserModel?> _loadUser() async {
    final db = await _db.database;
    final rows =
        await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) return null;
    final row = rows.first;

    List<String> achievements;
    try {
      achievements = (jsonDecode(row['achievements'] as String? ?? '[]')
              as List<dynamic>)
          .map((e) => e as String)
          .toList();
    } catch (_) {
      achievements = [];
    }

    UserPreferences prefs;
    try {
      prefs = UserPreferences.fromJson(
        jsonDecode(row['preferences'] as String? ?? '{}')
            as Map<String, dynamic>,
      );
    } catch (_) {
      prefs = const UserPreferences();
    }

    return UserModel(
      id: row['id'] as String,
      username: row['username'] as String,
      fullName: row['full_name'] as String,
      email: row['email'] as String,
      phone: row['phone'] as String? ?? '',
      profilePhotoUrl: row['photo_url'] as String? ?? '',
      bio: row['bio'] as String? ?? '',
      riderLevel: row['rider_level'] as String? ?? 'Novice',
      xp: row['xp'] as int? ?? 0,
      totalDistanceKm: (row['distance_km'] as num?)?.toDouble() ?? 0.0,
      totalRides: row['total_rides'] as int? ?? 0,
      achievements: achievements,
      emergencyContacts: await _loadContacts(),
      vehicles: await _loadVehicles(),
      preferences: prefs,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // ── UserRepository implementation ────────────────────────────────────────

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final user = await _loadUser();
      if (user == null) {
        return Result.failure(
          const StorageError('User not found in local database.', ),
        );
      }
      return Result.success(user);
    } catch (e) {
      return Result.failure(StorageError('Failed to load user: $e'));
    }
  }

  @override
  Future<Result<UserModel>> updateProfile(UserModel updatedUser) async {
    try {
      final db = await _db.database;
      await db.update(
        'users',
        {
          'username': updatedUser.username,
          'full_name': updatedUser.fullName,
          'email': updatedUser.email,
          'phone': updatedUser.phone,
          'photo_url': updatedUser.profilePhotoUrl,
          'bio': updatedUser.bio,
          'rider_level': updatedUser.riderLevel,
          'xp': updatedUser.xp,
          'distance_km': updatedUser.totalDistanceKm,
          'total_rides': updatedUser.totalRides,
          'achievements': jsonEncode(updatedUser.achievements),
          'preferences': jsonEncode(updatedUser.preferences.toJson()),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      final reloaded = await _loadUser();
      if (reloaded == null) {
        return Result.failure(
          const StorageError('Failed to reload profile after update.'),
        );
      }
      return Result.success(reloaded);
    } catch (e) {
      return Result.failure(StorageError('Failed to update profile: $e'));
    }
  }

  @override
  Future<Result<List<VehicleModel>>> addVehicle(
      VehicleModel vehicle) async {
    try {
      final db = await _db.database;
      await db.insert('vehicles', {
        'id': vehicle.id,
        'user_id': userId,
        'brand': vehicle.brand,
        'model': vehicle.model,
        'year': vehicle.year,
        'registration_number': vehicle.registrationNumber,
        'fuel_type': vehicle.fuelType,
        'engine_cc': vehicle.engineCapacityCc,
        'color': vehicle.color,
        'service_due_date': vehicle.serviceDueDate.toIso8601String(),
        'is_default': vehicle.isDefault ? 1 : 0,
      });
      final vehicles = await _loadVehicles();
      return Result.success(vehicles);
    } catch (e) {
      return Result.failure(StorageError('Failed to add vehicle: $e'));
    }
  }

  @override
  Future<Result<List<VehicleModel>>> deleteVehicle(
      String vehicleId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'vehicles',
        where: 'id = ? AND user_id = ?',
        whereArgs: [vehicleId, userId],
      );
      final vehicles = await _loadVehicles();
      return Result.success(vehicles);
    } catch (e) {
      return Result.failure(StorageError('Failed to delete vehicle: $e'));
    }
  }

  @override
  Future<Result<List<EmergencyContactModel>>> addEmergencyContact(
      EmergencyContactModel contact) async {
    try {
      final db = await _db.database;
      await db.insert('emergency_contacts', {
        'id': contact.id,
        'user_id': userId,
        'name': contact.name,
        'relation': contact.relation,
        'phone': contact.phone,
        'order_index': contact.orderIndex,
      });
      final contacts = await _loadContacts();
      return Result.success(contacts);
    } catch (e) {
      return Result.failure(
          StorageError('Failed to add emergency contact: $e'));
    }
  }
}

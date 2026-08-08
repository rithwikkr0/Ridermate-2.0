import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/features/auth/services/sqlite_auth_service.dart';
import 'package:ridermate/features/profile/repositories/sqlite_user_repository.dart';
import 'package:ridermate/features/auth/models/user_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteAuthService & SqliteUserRepository Integration Tests', () {
    late DatabaseService dbService;
    late SqliteAuthService authService;

    setUp(() async {
      dbService = DatabaseService.instance;
      authService = SqliteAuthService(dbService);
    });

    tearDown(() async {
      final db = await dbService.database;
      await db.delete('users');
      await db.delete('vehicles');
      await db.delete('emergency_contacts');
    });

    test('Register new user succeeds and saves to SQLite', () async {
      final res = await authService.register(
        'Rithwik Rider',
        'rithwik@ridermate.app',
        'securePassword123',
      );

      expect(res.isSuccess, isTrue);
      final user = res.dataOrNull!;
      expect(user.fullName, equals('Rithwik Rider'));
      expect(user.email, equals('rithwik@ridermate.app'));

      // Direct SQL query to verify row in SQLite database table
      final db = await dbService.database;
      final rows = await db.query('users', where: 'email = ?', whereArgs: ['rithwik@ridermate.app']);
      expect(rows.length, equals(1));
      expect(rows.first['full_name'], equals('Rithwik Rider'));
    });

    test('Login with registered credentials succeeds', () async {
      await authService.register(
        'Rithwik Rider',
        'rithwik@ridermate.app',
        'securePassword123',
      );

      final loginRes = await authService.login('rithwik@ridermate.app', 'securePassword123');
      expect(loginRes.isSuccess, isTrue);
      expect(loginRes.dataOrNull!.fullName, equals('Rithwik Rider'));
    });

    test('Login with wrong password fails', () async {
      await authService.register(
        'Rithwik Rider',
        'rithwik@ridermate.app',
        'securePassword123',
      );

      final loginRes = await authService.login('rithwik@ridermate.app', 'wrongPassword');
      expect(loginRes.isFailure, isTrue);
    });

    test('Profile updates persist in SQLite database across reloads', () async {
      final regRes = await authService.register(
        'Rithwik Rider',
        'rithwik@ridermate.app',
        'securePassword123',
      );
      final initialUser = regRes.dataOrNull!;

      final userRepo = SqliteUserRepository(dbService, userId: initialUser.id);
      final updatedUser = UserModel(
        id: initialUser.id,
        username: 'rithwik_pro',
        fullName: 'Rithwik Pro Rider',
        email: initialUser.email,
        phone: '+919999999999',
        profilePhotoUrl: 'https://example.com/photo.jpg',
        bio: 'Track day enthusiast & long distance tourer.',
        riderLevel: 'Pro',
        xp: 1500,
        totalDistanceKm: 350.5,
        totalRides: 12,
        achievements: const ['century_rider', 'iron_week'],
        emergencyContacts: const [],
        vehicles: const [],
        preferences: const UserPreferences(),
        createdAt: initialUser.createdAt,
        updatedAt: DateTime.now(),
      );

      final updateRes = await userRepo.updateProfile(updatedUser);
      expect(updateRes.isSuccess, isTrue);

      // Create a fresh repository instance to simulate app restart
      final freshRepo = SqliteUserRepository(dbService, userId: initialUser.id);
      final loadedRes = await freshRepo.getCurrentUser();
      expect(loadedRes.isSuccess, isTrue);
      final loadedUser = loadedRes.dataOrNull!;
      expect(loadedUser.fullName, equals('Rithwik Pro Rider'));
      expect(loadedUser.bio, equals('Track day enthusiast & long distance tourer.'));
      expect(loadedUser.phone, equals('+919999999999'));
    });
  });
}

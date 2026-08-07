import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/core/services/storage_service.dart';
import 'package:ridermate/features/auth/services/mock_auth_service.dart';
import 'package:ridermate/features/auth/services/session_service.dart';

import 'package:ridermate/features/profile/repositories/user_repository.dart';
import 'package:ridermate/features/profile/models/vehicle_model.dart';

void main() {
  group('Auth & User Management Unit Tests', () {
    test('MockAuthService completes login successfully', () async {
      final authService = MockAuthService();
      final result = await authService.login('john@ridermate.app', 'password123');
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.fullName, equals('John Rider'));
    });

    test('SessionService persists tokens', () async {
      final storage = MockStorageService();
      final sessionService = MockSessionService(storage);
      await sessionService.saveSession(accessToken: 'token_abc', refreshToken: 'ref_123', userId: 'user-001');

      final storedToken = await sessionService.getAccessToken();
      expect(storedToken, equals('token_abc'));
    });

    test('UserRepository adds vehicle correctly', () async {
      final repo = MockUserRepository();
      final newVehicle = VehicleModel(
        id: 'v2',
        brand: 'BMW',
        model: 'R 1250 GS',
        year: 2024,
        registrationNumber: 'MH-12-GS-9999',
        fuelType: 'Petrol',
        engineCapacityCc: 1254,
        color: 'Triple Black',
        serviceDueDate: DateTime.now(),
      );

      final res = await repo.addVehicle(newVehicle);
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.length, equals(2));
    });
  });
}

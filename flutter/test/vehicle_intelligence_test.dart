import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/core/vehicle_intelligence/vehicle_intelligence_service.dart';

void main() {
  group('VehicleIntelligenceService Tests', () {
    late VehicleIntelligenceService service;

    setUp(() {
      service = VehicleIntelligenceService();
    });

    test('isValidIndianRegNumber should return true for valid formats', () {
      expect(service.isValidIndianRegNumber('KA01AB1234'), isTrue);
      expect(service.isValidIndianRegNumber('ka01ab1234'), isTrue);
      expect(service.isValidIndianRegNumber('KA 01 AB 1234'), isTrue);
      expect(service.isValidIndianRegNumber('KA-01-AB-1234'), isTrue);
      expect(service.isValidIndianRegNumber('MH12QQ1234'), isTrue);
      expect(service.isValidIndianRegNumber('DL1C1234'), isTrue);
    });

    test('isValidIndianRegNumber should return false for invalid formats', () {
      expect(service.isValidIndianRegNumber('KA01AB123'), isFalse); // too short
      expect(service.isValidIndianRegNumber('K01AB1234'), isFalse); // one state char
      expect(service.isValidIndianRegNumber('KA01AB12345'), isFalse); // too long
      expect(service.isValidIndianRegNumber('1234AB1234'), isFalse); // invalid start
    });

    test('lookupVehicle returns null for ManualVehicleProvider', () async {
      final result = await service.lookupVehicle('KA01AB1234');
      expect(result, isNull);
    });
  });
}

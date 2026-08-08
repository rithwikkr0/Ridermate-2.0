import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridermate/core/models/ride_point_model.dart';
import 'package:ridermate/core/services/location_service.dart';
import 'package:ridermate/core/errors/app_error.dart';
import 'package:ridermate/core/errors/result.dart';

void main() {
  group('GPS Location & Telemetry Unit Tests', () {
    test('Location model conversion correctly formats telemetry fields', () {
      final point = RidePointModel(
        latitude: 12.971598,
        longitude: 77.594566,
        timestamp: 1700000000000,
        speed: 45.5,
        heading: 180.0,
        accuracy: 4.2,
      );

      expect(point.latitude, equals(12.971598));
      expect(point.longitude, equals(77.594566));
      expect(point.timestamp, equals(1700000000000));
      expect(point.speed, equals(45.5));
      expect(point.heading, equals(180.0));
      expect(point.accuracy, equals(4.2));
      expect(point.isValid, isTrue);
    });

    test('Invalid coordinate handling detects out-of-bounds coordinates', () {
      const invalidLat = RidePointModel(
        latitude: 120.0, // Invalid lat > 90
        longitude: 77.594566,
        timestamp: 1700000000000,
        speed: 0,
      );
      expect(invalidLat.isValid, isFalse);

      const invalidLng = RidePointModel(
        latitude: 12.971598,
        longitude: -200.0, // Invalid lng < -180
        timestamp: 1700000000000,
        speed: 0,
      );
      expect(invalidLng.isValid, isFalse);

      const zeroPoint = RidePointModel(
        latitude: 0.0,
        longitude: 0.0, // Null Island (0,0) considered uninitialized
        timestamp: 1700000000000,
        speed: 0,
      );
      expect(zeroPoint.isValid, isFalse);
    });

    test('Location model JSON serialization and deserialization preserves telemetry', () {
      final original = RidePointModel(
        latitude: 19.0760,
        longitude: 72.8777,
        timestamp: 1700001000000,
        speed: 60.0,
        heading: 270.5,
        accuracy: 3.5,
      );

      final json = original.toJson();
      final restored = RidePointModel.fromJson(json);

      expect(restored.latitude, equals(original.latitude));
      expect(restored.longitude, equals(original.longitude));
      expect(restored.speed, equals(original.speed));
      expect(restored.heading, equals(original.heading));
      expect(restored.accuracy, equals(original.accuracy));
      expect(restored.isValid, isTrue);
    });

    test('MockLocationService provides valid simulated location stream for testing', () async {
      final service = MockLocationService();
      final currentRes = await service.getCurrentLocation();

      expect(currentRes.isSuccess, isTrue);
      final current = currentRes.dataOrNull!;
      expect(current.isValid, isTrue);
      expect(current.speed, greaterThan(0));

      final streamPoints = await service.getLocationStream().take(3).toList();
      expect(streamPoints.length, equals(3));
      for (final pt in streamPoints) {
        expect(pt.isValid, isTrue);
        expect(pt.accuracy, greaterThan(0));
      }
    });

    test('LocationError correctly encapsulates typed error codes and messages', () {
      const disabledErr = LocationError('Location services disabled.', code: 'location_disabled');
      expect(disabledErr.code, equals('location_disabled'));
      expect(disabledErr.message, contains('disabled'));

      const deniedErr = PermissionError('Permission denied.', code: 'location_denied');
      expect(deniedErr.code, equals('location_denied'));
    });
  });
}

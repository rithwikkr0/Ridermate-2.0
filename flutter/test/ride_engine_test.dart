import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/core/utils/geo_utils.dart';
import 'package:ridermate/core/utils/unit_converters.dart';
import 'package:ridermate/features/rides/services/statistics_engine.dart';
import 'package:ridermate/features/rides/services/mock_ride_generator.dart';

void main() {
  group('Ride Engine Unit Tests', () {
    test('Haversine distance calculation is accurate', () {
      // Mumbai (19.0760, 72.8777) to Pune (18.5204, 73.8567) ~ 120km
      final distance = GeoUtils.calculateDistance(19.0760, 72.8777, 18.5204, 73.8567);
      expect(distance, greaterThan(110.0));
      expect(distance, lessThan(130.0));
    });

    test('Unit converters produce correct conversions', () {
      expect(UnitConverters.kmToMiles(100.0), closeTo(62.1371, 0.01));
      expect(UnitConverters.msToKmh(10.0), equals(36.0));
    });

    test('StatisticsEngine calculates calories & environmental savings', () {
      final calories = StatisticsEngine.calculateCalories(40.0, const Duration(hours: 1));
      expect(calories, equals(1240));

      final fuelSaved = StatisticsEngine.calculateFuelSaved(100.0);
      expect(fuelSaved, closeTo(3.5, 0.1));
    });

    test('MockRideGenerator produces valid RideEngineModel list', () {
      final rides = MockRideGenerator.generateList(10);
      expect(rides.length, equals(10));
      expect(rides.first.title, isNotEmpty);
      expect(rides.first.distanceKm, greaterThan(0.0));
    });
  });
}

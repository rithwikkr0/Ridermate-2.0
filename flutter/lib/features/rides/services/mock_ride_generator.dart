import 'dart:math';
import '../models/ride_engine_model.dart';
import '../models/route_model.dart';
import 'statistics_engine.dart';

/// RiderMate 2.0 — Mock Ride Generator
class MockRideGenerator {
  static final _random = Random(42);

  static const List<String> _titles = [
    'Morning Coastal Cruise',
    'Western Ghats Climb',
    'City Express Commute',
    'Sunset Highway Lap',
    'Dawn Patrol Run',
    'Weekend Mountain Tour'
  ];

  static const List<String> _vehicles = [
    'KTM Duke 390',
    'BMW R 1250 GS',
    'Royal Enfield Himalayan',
    'Kawasaki Ninja 650'
  ];

  static const List<String> _weathers = [
    'Sunny 26°C',
    'Partly Cloudy 24°C',
    'Clear Night 21°C',
    'Breezy 25°C'
  ];

  static RideEngineModel generateSingle({int index = 0}) {
    final title = _titles[index % _titles.length];
    final vehicle = _vehicles[index % _vehicles.length];
    final weather = _weathers[index % _weathers.length];

    final distanceKm = 10.0 + _random.nextDouble() * 50.0;
    final durationMinutes = (distanceKm * 1.8).round();
    final avgSpeed = 25.0 + _random.nextDouble() * 25.0;
    final maxSpeed = avgSpeed + 15.0 + _random.nextDouble() * 20.0;
    final elevation = 100.0 + _random.nextDouble() * 400.0;
    final startTime = DateTime.now().subtract(Duration(days: index, hours: _random.nextInt(12)));
    final duration = Duration(minutes: durationMinutes);

    final points = List.generate(10, (i) {
      return RoutePoint(
        latitude: 19.0760 + (i * 0.005),
        longitude: 72.8777 + (i * 0.005),
        speedKmh: avgSpeed + (i % 3 == 0 ? 5.0 : -3.0),
        timestamp: startTime.add(Duration(minutes: i * 2)).millisecondsSinceEpoch,
        elevationMeters: elevation + (i * 10),
      );
    });

    return RideEngineModel(
      id: 'ride-mock-$index',
      title: title,
      vehicle: vehicle,
      startTime: startTime,
      endTime: startTime.add(duration),
      duration: duration,
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      averageSpeedKmh: double.parse(avgSpeed.toStringAsFixed(1)),
      maxSpeedKmh: double.parse(maxSpeed.toStringAsFixed(1)),
      elevationMeters: double.parse(elevation.toStringAsFixed(0)),
      caloriesBurned: StatisticsEngine.calculateCalories(distanceKm, duration),
      weather: weather,
      routePoints: points,
      rideScore: StatisticsEngine.calculateRideScore(avgSpeed, maxSpeed, 0),
    );
  }

  static List<RideEngineModel> generateList(int count) {
    return List.generate(count, (index) => generateSingle(index: index));
  }
}

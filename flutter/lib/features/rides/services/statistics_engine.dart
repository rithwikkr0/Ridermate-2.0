import '../models/route_model.dart';

/// RiderMate 2.0 — Statistics Engine
class StatisticsEngine {
  static double calculateAverageSpeed(List<RoutePoint> points) {
    if (points.isEmpty) return 0.0;
    final totalSpeed = points.fold<double>(0.0, (sum, p) => sum + p.speedKmh);
    return totalSpeed / points.length;
  }

  static double calculateMaxSpeed(List<RoutePoint> points) {
    if (points.isEmpty) return 0.0;
    return points.map((p) => p.speedKmh).reduce((a, b) => a > b ? a : b);
  }

  static int calculateCalories(double distanceKm, Duration duration) {
    return (distanceKm * 25 + duration.inMinutes * 4).round();
  }

  static double calculateFuelSaved(double distanceKm) {
    return (distanceKm * 0.035); // Estimated liters saved vs car
  }

  static double calculateCo2Saved(double distanceKm) {
    return (distanceKm * 0.082); // Estimated kg CO2 saved
  }

  static int calculateRideScore(double avgSpeed, double maxSpeed, int overspeeds) {
    int score = 100;
    if (maxSpeed > 80) score -= 15;
    score -= (overspeeds * 5);
    return score.clamp(50, 100);
  }
}

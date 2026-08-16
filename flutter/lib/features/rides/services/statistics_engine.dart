import '../../../core/services/database_service.dart';
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

  static Future<List<double>> getWeeklyDistances(String userId, {int weeks = 8}) async {
    final db = await DatabaseService.instance.database;
    final now = DateTime.now();
    final results = List.filled(weeks, 0.0);
    
    for (int i = 0; i < weeks; i++) {
      final start = now.subtract(Duration(days: (i + 1) * 7)).millisecondsSinceEpoch;
      final end = now.subtract(Duration(days: i * 7)).millisecondsSinceEpoch;
      
      final res = await db.rawQuery('''
        SELECT SUM(distance_km) as total 
        FROM rides 
        WHERE user_id = ? AND start_time >= ? AND start_time < ?
      ''', [userId, start, end]);
      
      if (res.isNotEmpty && res.first['total'] != null) {
        results[weeks - 1 - i] = (res.first['total'] as num).toDouble();
      }
    }
    return results;
  }

  static Future<List<double>> getSafetyScoreTrend(String userId, {int weeks = 8}) async {
    final db = await DatabaseService.instance.database;
    final now = DateTime.now();
    final results = List.filled(weeks, 100.0);
    
    for (int i = 0; i < weeks; i++) {
      final startIso = now.subtract(Duration(days: (i + 1) * 7)).toIso8601String();
      final endIso = now.subtract(Duration(days: i * 7)).toIso8601String();
      
      final res = await db.rawQuery('''
        SELECT COUNT(*) as violations 
        FROM traffic_violations 
        WHERE user_id = ? AND timestamp >= ? AND timestamp < ?
      ''', [userId, startIso, endIso]);
      
      if (res.isNotEmpty) {
        final violations = (res.first['violations'] as num).toInt();
        results[weeks - 1 - i] = (100.0 - (violations * 5)).clamp(0, 100).toDouble();
      }
    }
    return results;
  }

  static Future<List<Map<String, dynamic>>> getTopRoutes(String userId, {int limit = 5}) async {
    final db = await DatabaseService.instance.database;
    final res = await db.rawQuery('''
      SELECT origin, destination, COUNT(*) as count 
      FROM rides 
      WHERE user_id = ? AND origin != '' AND destination != ''
      GROUP BY origin, destination 
      ORDER BY count DESC 
      LIMIT ?
    ''', [userId, limit]);
    
    return res;
  }
}

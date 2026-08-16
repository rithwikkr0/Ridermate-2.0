import 'package:flutter/foundation.dart';
import '../../../core/services/database_service.dart';
import '../../rides/services/statistics_engine.dart';

class AnalyticsController extends ChangeNotifier {
  final String userId;

  bool isLoading = true;
  double totalDistance = 0.0;
  int totalRides = 0;
  int totalDurationSecs = 0;
  double avgSpeed = 0.0;
  double maxSpeed = 0.0;
  double totalElevation = 0.0;
  int totalCalories = 0;

  List<double> weeklyDistances = [];
  List<double> safetyScoreTrend = [];
  List<Map<String, dynamic>> topRoutes = [];

  AnalyticsController(this.userId) {
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService.instance.database;

      // Overall stats
      final statsRes = await db.rawQuery('''
        SELECT 
          SUM(distance_km) as dist, 
          COUNT(*) as count, 
          SUM(duration_seconds) as dur, 
          AVG(average_speed) as avg_spd, 
          MAX(max_speed) as max_spd,
          SUM(elevation) as elev,
          SUM(calories) as cal
        FROM rides 
        WHERE user_id = ?
      ''', [userId]);

      if (statsRes.isNotEmpty) {
        final row = statsRes.first;
        totalDistance = (row['dist'] as num?)?.toDouble() ?? 0.0;
        totalRides = (row['count'] as num?)?.toInt() ?? 0;
        totalDurationSecs = (row['dur'] as num?)?.toInt() ?? 0;
        avgSpeed = (row['avg_spd'] as num?)?.toDouble() ?? 0.0;
        maxSpeed = (row['max_spd'] as num?)?.toDouble() ?? 0.0;
        totalElevation = (row['elev'] as num?)?.toDouble() ?? 0.0;
        totalCalories = (row['cal'] as num?)?.toInt() ?? 0;
      }

      // Trends
      weeklyDistances = await StatisticsEngine.getWeeklyDistances(userId, weeks: 7); // For 7 columns chart
      safetyScoreTrend = await StatisticsEngine.getSafetyScoreTrend(userId, weeks: 8);
      topRoutes = await StatisticsEngine.getTopRoutes(userId, limit: 5);

    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void refresh() {
    _loadData();
  }
}

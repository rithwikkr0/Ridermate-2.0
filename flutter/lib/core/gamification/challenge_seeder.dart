import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

class ChallengeSeeder {
  static Future<void> seedDefaultChallenges() async {
    final db = await DatabaseService.instance.database;
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM challenges');
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    
    if (count == 0) {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30)).toIso8601String();
      final startDate = now.toIso8601String();
      
      final defaultChallenges = [
        {
          'id': 'chal_1',
          'title': 'Weekend Warrior',
          'description': 'Complete 3 rides on weekends',
          'type': 'rides',
          'target_value': 3.0,
          'xp_reward': 200,
          'start_date': startDate,
          'end_date': endDate,
          'is_active': 1,
        },
        {
          'id': 'chal_2',
          'title': 'Century Rider',
          'description': 'Ride 100km in a week',
          'type': 'distance',
          'target_value': 100.0,
          'xp_reward': 300,
          'start_date': startDate,
          'end_date': endDate,
          'is_active': 1,
        },
        {
          'id': 'chal_3',
          'title': 'Safety Champion',
          'description': 'Complete 5 rides with 0 violations',
          'type': 'safe_rides',
          'target_value': 5.0,
          'xp_reward': 250,
          'start_date': startDate,
          'end_date': endDate,
          'is_active': 1,
        },
        {
          'id': 'chal_4',
          'title': 'Memory Maker',
          'description': 'Create 10 memories',
          'type': 'memories',
          'target_value': 10.0,
          'xp_reward': 150,
          'start_date': startDate,
          'end_date': endDate,
          'is_active': 1,
        },
        {
          'id': 'chal_5',
          'title': 'Social Rider',
          'description': 'Make 5 community posts',
          'type': 'posts',
          'target_value': 5.0,
          'xp_reward': 100,
          'start_date': startDate,
          'end_date': endDate,
          'is_active': 1,
        },
      ];

      for (var challenge in defaultChallenges) {
        await db.insert('challenges', challenge, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }
}

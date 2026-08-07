import '../models/community_models.dart';

abstract class LeaderboardService {
  Future<List<LeaderboardRankModel>> getWeeklyLeaderboard();
}

class MockLeaderboardService implements LeaderboardService {
  @override
  Future<List<LeaderboardRankModel>> getWeeklyLeaderboard() async {
    return const [
      LeaderboardRankModel(rank: 1, name: 'Arjun K.', avatarUrl: '', distanceKm: 284.0),
      LeaderboardRankModel(rank: 2, name: 'Priya S.', avatarUrl: '', distanceKm: 256.0),
      LeaderboardRankModel(rank: 3, name: 'John Rider', avatarUrl: '', distanceKm: 248.0, isCurrentUser: true),
      LeaderboardRankModel(rank: 4, name: 'Rahul M.', avatarUrl: '', distanceKm: 210.0),
    ];
  }
}

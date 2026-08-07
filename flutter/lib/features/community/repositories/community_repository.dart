import '../models/community_models.dart';
import '../services/friend_manager_service.dart';
import '../services/club_manager_service.dart';
import '../services/challenge_engine_service.dart';
import '../services/leaderboard_service.dart';

abstract class CommunityRepository {
  Future<List<FriendModel>> getFriends();
  Future<List<RideClubModel>> getClubs();
  Future<List<ChallengeModel>> getChallenges();
  Future<List<LeaderboardRankModel>> getLeaderboard();
}

class MockCommunityRepository implements CommunityRepository {
  final FriendManagerService friendManager;
  final ClubManagerService clubManager;
  final ChallengeEngineService challengeEngine;
  final LeaderboardService leaderboardService;

  MockCommunityRepository({
    required this.friendManager,
    required this.clubManager,
    required this.challengeEngine,
    required this.leaderboardService,
  });

  @override
  Future<List<FriendModel>> getFriends() => friendManager.getFriendsList();

  @override
  Future<List<RideClubModel>> getClubs() => clubManager.getClubs();

  @override
  Future<List<ChallengeModel>> getChallenges() => challengeEngine.getActiveChallenges();

  @override
  Future<List<LeaderboardRankModel>> getLeaderboard() => leaderboardService.getWeeklyLeaderboard();
}

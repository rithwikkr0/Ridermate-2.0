import '../errors/result.dart';

abstract class GamificationRepository {
  Future<Result<int>> getUserXP(String userId);
  Future<Result<String>> getUserLevel(String userId);
  Future<Result<bool>> awardXP(String userId, String eventType, int xpAmount, String referenceId);
  Future<Result<List<Map<String, dynamic>>>> getUserAchievements(String userId);
  Future<Result<List<Map<String, dynamic>>>> getActiveChallenges();
  Future<Result<Map<String, dynamic>?>> getUserChallenge(String userId, String challengeId);
  Future<Result<bool>> updateChallengeProgress(String userId, String challengeId, double progress);
  Future<Result<bool>> unlockAchievement(String userId, String type, String title, String description, int xpReward, String icon);
  Future<Result<List<Map<String, dynamic>>>> getLeaderboard(int limit);
}

import 'gamification_repository.dart';
import 'xp_config.dart';

class GamificationEngine {
  final GamificationRepository repository;

  GamificationEngine(this.repository);

  Future<void> onRideCompleted(String userId, String rideId, double distanceKm, int violations) async {
    final baseReward = XpConfig.rideCompletedBase + distanceKm.round();
    
    // Base Ride XP
    await repository.awardXP(userId, 'RIDE_COMPLETED', baseReward, rideId);
    
    // Safe Ride Bonus
    if (violations == 0) {
      await repository.awardXP(userId, 'SAFE_RIDE', XpConfig.safeRide, rideId);
    }
    
    // Mileage Milestones
    await _checkMileageMilestones(userId);
    
    // Achievements
    await repository.unlockAchievement(userId, 'first_ride', 'First Ride', 'Completed your first ride!', 100, 'emoji_events');
    // For 10 rides, 50 rides, we would check total_rides from users table, skipping for simplicity in this engine logic block.
  }

  Future<void> onMemoryCreated(String userId, String memoryId) async {
    await repository.awardXP(userId, 'MEMORY_CREATED', XpConfig.memoryCreated, memoryId);
    await repository.unlockAchievement(userId, 'memory_maker', 'Memory Maker', 'Created a memory', 50, 'photo_camera');
  }

  Future<void> onCommunityPost(String userId, String postId) async {
    await repository.awardXP(userId, 'COMMUNITY_POST', XpConfig.communityPost, postId);
  }

  Future<void> onFriendAdded(String userId, String friendId) async {
    await repository.awardXP(userId, 'FRIEND_ADDED', XpConfig.friendAdded, friendId);
  }

  Future<void> onMaintenanceCompleted(String userId, String vehicleId, String recordId) async {
    await repository.awardXP(userId, 'MAINTENANCE_COMPLETED', XpConfig.maintenanceCompleted, recordId);
  }

  Future<void> onGroupRideCompleted(String userId, String groupRideId) async {
    await repository.awardXP(userId, 'GROUP_RIDE_COMPLETED', XpConfig.groupRideCompleted, groupRideId);
  }

  Future<void> onReferralConverted(String userId, String refereeId) async {
    await repository.unlockAchievement(
      userId,
      'squad_recruiter',
      'Squad Recruiter',
      'Invited a new rider to RiderMate who joined your squad!',
      0,
      'group_add',
    );
  }

  Future<void> _checkMileageMilestones(String userId) async {
    // In a real app we'd query distance_km. We can approximate or just leave it for now.
    // If distance > 100km etc.
    // This is mocked to show intention.
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/features/community/services/friend_manager_service.dart';
import 'package:ridermate/features/community/services/club_manager_service.dart';
import 'package:ridermate/features/community/services/challenge_engine_service.dart';
import 'package:ridermate/features/community/services/leaderboard_service.dart';
import 'package:ridermate/features/community/repositories/community_repository.dart';

void main() {
  group('Community Platform Unit Tests', () {
    test('MockFriendManagerService fetches friends list', () async {
      final friendService = MockFriendManagerService();
      final friends = await friendService.getFriendsList();
      expect(friends.length, equals(3));
      expect(friends.first.name, equals('Arjun K.'));
    });

    test('MockClubManagerService joins club', () async {
      final clubService = MockClubManagerService();
      final clubs = await clubService.getClubs();
      expect(clubs.length, equals(2));
      final res = await clubService.joinClub(clubs.first.id);
      expect(res.isSuccess, isTrue);
    });

    test('MockChallengeEngineService returns active challenges', () async {
      final challengeService = MockChallengeEngineService();
      final challenges = await challengeService.getActiveChallenges();
      expect(challenges.length, equals(2));
    });

    test('MockCommunityRepository aggregates community data', () async {
      final repo = MockCommunityRepository(
        friendManager: MockFriendManagerService(),
        clubManager: MockClubManagerService(),
        challengeEngine: MockChallengeEngineService(),
        leaderboardService: MockLeaderboardService(),
      );

      final leaderboard = await repo.getLeaderboard();
      expect(leaderboard.length, equals(4));
      expect(leaderboard.first.rank, equals(1));
    });
  });
}

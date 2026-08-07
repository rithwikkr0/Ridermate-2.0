/// RiderMate 2.0 — Comprehensive Community & Social Models
class FriendModel {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isOnline;
  final String lastSeenText;

  const FriendModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.isOnline,
    required this.lastSeenText,
  });
}

class RideClubModel {
  final String id;
  final String name;
  final String iconEmoji;
  final int memberCount;
  final double totalDistanceKm;
  final String description;
  final bool isJoined;

  const RideClubModel({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.memberCount,
    required this.totalDistanceKm,
    required this.description,
    this.isJoined = false,
  });
}

class ChallengeModel {
  final String id;
  final String title;
  final double progressPercent; // 0.0 to 1.0
  final String deadlineText;
  final int participantCount;
  final bool isJoined;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.progressPercent,
    required this.deadlineText,
    required this.participantCount,
    this.isJoined = false,
  });
}

class LeaderboardRankModel {
  final int rank;
  final String name;
  final String avatarUrl;
  final double distanceKm;
  final bool isCurrentUser;

  const LeaderboardRankModel({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.distanceKm,
    this.isCurrentUser = false,
  });
}

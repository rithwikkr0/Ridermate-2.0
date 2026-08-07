import '../models/community_models.dart';
import '../../../core/errors/result.dart';

abstract class ClubManagerService {
  Future<List<RideClubModel>> getClubs();
  Future<Result<bool>> joinClub(String clubId);
  Future<Result<bool>> leaveClub(String clubId);
}

class MockClubManagerService implements ClubManagerService {
  final List<RideClubModel> _clubs = [
    const RideClubModel(id: 'c1', name: 'Mumbai Riders Squad', iconEmoji: '🏙️', memberCount: 128, totalDistanceKm: 24500.0, description: 'Premier urban & highway touring group in Mumbai.', isJoined: true),
    const RideClubModel(id: 'c2', name: 'Western Ghats Crew', iconEmoji: '⛰️', memberCount: 56, totalDistanceKm: 18200.0, description: 'Mountain pass twists and weekend cornering passion.'),
  ];

  @override
  Future<List<RideClubModel>> getClubs() async => List.unmodifiable(_clubs);

  @override
  Future<Result<bool>> joinClub(String clubId) async {
    return Result.success(true);
  }

  @override
  Future<Result<bool>> leaveClub(String clubId) async {
    return Result.success(true);
  }
}

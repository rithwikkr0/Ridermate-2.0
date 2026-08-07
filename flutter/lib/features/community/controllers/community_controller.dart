import '../../../providers/base_controller.dart';
import '../models/community_models.dart';
import '../repositories/community_repository.dart';

/// RiderMate 2.0 — Community Controller
class CommunityController extends BaseController {
  final CommunityRepository repository;

  List<FriendModel> friends = [];
  List<RideClubModel> clubs = [];
  List<ChallengeModel> challenges = [];
  List<LeaderboardRankModel> leaderboard = [];

  CommunityController(this.repository);

  Future<void> loadCommunityOverview() async {
    setState(ViewState.loading);
    friends = await repository.getFriends();
    clubs = await repository.getClubs();
    challenges = await repository.getChallenges();
    leaderboard = await repository.getLeaderboard();
    setState(ViewState.success);
  }
}

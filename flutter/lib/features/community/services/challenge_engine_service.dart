import '../models/community_models.dart';
import '../../../core/errors/result.dart';

abstract class ChallengeEngineService {
  Future<List<ChallengeModel>> getActiveChallenges();
  Future<Result<bool>> joinChallenge(String challengeId);
}

class MockChallengeEngineService implements ChallengeEngineService {
  final List<ChallengeModel> _challenges = const [
    ChallengeModel(id: 'ch1', title: 'Monthly 500km Endurance', progressPercent: 0.45, deadlineText: 'Aug 31', participantCount: 340, isJoined: true),
    ChallengeModel(id: 'ch2', title: 'Western Ghats Elevation King', progressPercent: 0.25, deadlineText: 'Aug 15', participantCount: 180),
  ];

  @override
  Future<List<ChallengeModel>> getActiveChallenges() async => _challenges;

  @override
  Future<Result<bool>> joinChallenge(String challengeId) async => Result.success(true);
}

import 'dart:async';
import '../../providers/base_controller.dart';
import 'gamification_repository.dart';
import 'gamification_engine.dart';
import 'xp_config.dart';

class GamificationController extends BaseController {
  final GamificationRepository repository;
  late final GamificationEngine engine;
  
  String _currentUserId = 'user_guest';

  GamificationController(this.repository) {
    engine = GamificationEngine(repository);
  }

  int _xp = 0;
  String _level = 'Novice';
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _activeChallenges = [];
  List<Map<String, dynamic>> _leaderboard = [];

  int get xp => _xp;
  String get level => _level;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get activeChallenges => _activeChallenges;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  
  final StreamController<String> _levelUpStreamController = StreamController<String>.broadcast();
  Stream<String> get onLevelUp => _levelUpStreamController.stream;

  void setUserId(String userId) {
    if (userId.isEmpty) {
      _currentUserId = 'user_guest';
    } else {
      _currentUserId = userId;
    }
    loadUserStats();
  }

  Future<void> loadUserStats() async {
    setState(ViewState.loading);
    
    final xpResult = await repository.getUserXP(_currentUserId);
    if (xpResult.isSuccess) {
      _xp = xpResult.dataOrNull!;
      _level = XpConfig.getLevelForXp(_xp);
    }
    
    final achResult = await repository.getUserAchievements(_currentUserId);
    if (achResult.isSuccess) {
      _achievements = achResult.dataOrNull!;
    }
    
    final challResult = await repository.getActiveChallenges();
    if (challResult.isSuccess) {
      _activeChallenges = challResult.dataOrNull!;
      
      // Merge with user progress
      List<Map<String, dynamic>> enriched = [];
      for (var challenge in _activeChallenges) {
        final progressRes = await repository.getUserChallenge(_currentUserId, challenge['id']);
        double currentProgress = 0.0;
        String status = 'active';
        if (progressRes.isSuccess && progressRes.dataOrNull != null) {
          currentProgress = (progressRes.dataOrNull!['progress'] as num).toDouble();
          status = progressRes.dataOrNull!['status'] as String;
        }
        enriched.add({
          ...challenge,
          'current_progress': currentProgress,
          'status': status,
        });
      }
      _activeChallenges = enriched;
    }
    
    final leaderResult = await repository.getLeaderboard(10);
    if (leaderResult.isSuccess) {
      _leaderboard = leaderResult.dataOrNull!;
    }

    setState(ViewState.initial);
  }

  Future<void> awardEvent(String eventType, int xp, String refId) async {
    final oldLevel = _level;
    final res = await repository.awardXP(_currentUserId, eventType, xp, refId);
    if (res.isSuccess && res.dataOrNull == true) {
      await loadUserStats();
      if (_level != oldLevel) {
        _levelUpStreamController.add(_level);
      }
    }
  }

  @override
  void dispose() {
    _levelUpStreamController.close();
    super.dispose();
  }
}

import '../../../providers/base_controller.dart';
import '../services/ai_provider.dart';
import '../services/conversation_memory.dart';
import '../repositories/ai_repository.dart';
import '../services/azure_safety_coach_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/network/azure_api_client.dart';

class ChatDisplayMessage {
  final String text;
  final bool isFromAi;

  const ChatDisplayMessage(this.text, this.isFromAi);
}

/// RiderMate 2.0 — AI Controller
class AiController extends BaseController {
  final AiRepository repository;
  final ConversationMemory memory = ConversationMemory();
  final AzureSafetyCoachService _safetyCoach;

  AiController(this.repository) : _safetyCoach = AzureSafetyCoachService(AzureApiClient());

  int _readinessScore = 0;
  int get readinessScore => _readinessScore;
  String _currentUserId = '';

  SafetyAssessment? currentAssessment;

  void refreshForUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId.isNotEmpty) {
        _loadReadinessScore(userId);
      }
    }
  }

  Future<void> _loadReadinessScore(String userId) async {
    final db = await DatabaseService.instance.database;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    // Get rides in last 7 days
    final ridesRes = await db.rawQuery('SELECT COUNT(*) as count FROM rides WHERE user_id = ? AND start_time >= ?', [userId, sevenDaysAgo]);
    final recentRides = (ridesRes.first['count'] as num).toInt();

    // Get safety score violations
    final safetyRes = await db.rawQuery('SELECT COUNT(*) as violations FROM traffic_violations WHERE user_id = ?', [userId]);
    final totalViolations = (safetyRes.first['violations'] as num).toInt();
    final computedSafetyScore = (100.0 - (totalViolations * 5)).clamp(0, 100).toDouble();

    // Fake maintenance score since we don't have full logic here easily, or simple query
    int maintenanceScore = 100;

    // Readiness logic
    int calculatedScore = computedSafetyScore.toInt();
    if (recentRides == 0) calculatedScore -= 5;
    calculatedScore = ((calculatedScore + maintenanceScore) / 2).round();
    
    _readinessScore = calculatedScore.clamp(0, 100);

    // Get Azure Assessment
    currentAssessment = await _safetyCoach.analyzeSafetyProfile(
      userId: userId,
      totalDistanceKm: 120.0,
      totalRides: recentRides,
      avgSpeedKmh: 25.0,
      maxSpeedKmh: 80.0,
      overspeedCount: totalViolations,
      safetyScore: computedSafetyScore,
    );

    notifyListeners();
  }

  List<ChatDisplayMessage> get messages => memory.messages
      .map((msg) => ChatDisplayMessage(msg.content, msg.role == AiRole.model))
      .toList();

  Future<void> sendMessage(String userMessage) async {
    memory.addMessage(AiRole.user, userMessage);
    setState(ViewState.loading);

    final res = await repository.askCopilot(userMessage);
    if (res.isSuccess) {
      memory.addMessage(AiRole.model, res.dataOrNull!);
      setState(ViewState.success);
    } else {
      setState(ViewState.error, error: res.errorOrNull);
    }
  }
}


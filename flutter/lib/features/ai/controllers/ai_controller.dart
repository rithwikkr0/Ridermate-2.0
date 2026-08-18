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
  final DateTime timestamp;

  const ChatDisplayMessage(this.text, this.isFromAi, {DateTime? timestamp})
      : timestamp = timestamp ?? const _DefaultDateTime();
}

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

/// RiderMate 2.0 — Production AI Copilot Controller
class AiController extends BaseController {
  final AiRepository repository;
  final ConversationMemory memory = ConversationMemory();
  final AzureSafetyCoachService _safetyCoach;

  AiController(this.repository) : _safetyCoach = AzureSafetyCoachService(AzureApiClient());

  int _readinessScore = 95;
  int get readinessScore => _readinessScore;
  String _currentUserId = '';
  String? _lastUserPrompt;

  SafetyAssessment? currentAssessment;

  void refreshForUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId.isNotEmpty && userId != 'user_guest') {
        _loadReadinessScore(userId);
      } else {
        _readinessScore = 90;
        notifyListeners();
      }
    }
  }

  Future<void> _loadReadinessScore(String userId) async {
    try {
      final db = await DatabaseService.instance.database;
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

      // Get rides in last 7 days
      final ridesRes = await db.rawQuery(
        'SELECT COUNT(*) as count FROM rides WHERE user_id = ? AND start_time >= ?',
        [userId, sevenDaysAgo],
      );
      final recentRides = (ridesRes.first['count'] as num?)?.toInt() ?? 0;

      // Get safety score violations
      final safetyRes = await db.rawQuery(
        'SELECT COUNT(*) as violations FROM traffic_violations WHERE user_id = ?',
        [userId],
      );
      final totalViolations = (safetyRes.first['violations'] as num?)?.toInt() ?? 0;
      final computedSafetyScore = (100.0 - (totalViolations * 5)).clamp(0, 100).toDouble();

      int maintenanceScore = 100;
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
    } catch (_) {
      _readinessScore = 92;
      notifyListeners();
    }
  }

  List<ChatDisplayMessage> get messages => memory.messages
      .map((msg) => ChatDisplayMessage(msg.content, msg.role == AiRole.model, timestamp: msg.timestamp))
      .toList();

  Future<void> sendMessage(String userMessage) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) return;

    _lastUserPrompt = trimmed;
    memory.addMessage(AiRole.user, trimmed);
    setState(ViewState.loading);

    try {
      final res = await repository.askCopilot(trimmed);
      if (res.isSuccess && res.dataOrNull != null) {
        memory.addMessage(AiRole.model, res.dataOrNull!);
        setState(ViewState.success);
      } else {
        setState(ViewState.error, error: res.errorOrNull);
      }
    } catch (e) {
      setState(ViewState.error);
    }
  }

  Future<void> retryLastMessage() async {
    if (_lastUserPrompt != null && _lastUserPrompt!.isNotEmpty) {
      setState(ViewState.loading);
      try {
        final res = await repository.askCopilot(_lastUserPrompt!);
        if (res.isSuccess && res.dataOrNull != null) {
          memory.addMessage(AiRole.model, res.dataOrNull!);
          setState(ViewState.success);
        } else {
          setState(ViewState.error, error: res.errorOrNull);
        }
      } catch (e) {
        setState(ViewState.error);
      }
    }
  }

  void clearConversation() {
    memory.clearHistory();
    _lastUserPrompt = null;
    setState(ViewState.initial);
  }
}

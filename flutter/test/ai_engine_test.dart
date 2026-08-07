import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/features/ai/services/ai_provider.dart';
import 'package:ridermate/features/ai/services/prompt_builder.dart';
import 'package:ridermate/features/ai/services/conversation_memory.dart';
import 'package:ridermate/features/ai/services/ride_coach_service.dart';
import 'package:ridermate/features/ai/services/recommendation_engine.dart';

void main() {
  group('AI Intelligence Engine Unit Tests', () {
    test('MockAiProvider generates valid responses', () async {
      final provider = MockAiProvider();
      final res = await provider.generateResponse(prompt: 'Tell me about the weather');
      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull, contains('Partly cloudy'));
    });

    test('PromptBuilder constructs structured prompts', () {
      final prompt = PromptBuilder()
          .addSystemRole('Coach')
          .addContext('User', 'John')
          .addTask('Give advice')
          .build();

      expect(prompt, contains('SYSTEM: Coach'));
      expect(prompt, contains('CONTEXT [User]: John'));
      expect(prompt, contains('TASK: Give advice'));
    });

    test('ConversationMemory stores chat history', () {
      final memory = ConversationMemory();
      memory.addMessage(AiRole.user, 'Hello AI');
      expect(memory.messages.length, equals(1));
      expect(memory.messages.first.content, equals('Hello AI'));
    });

    test('RideCoachService produces defensive insights', () {
      final insights = RideCoachService.generateInsights(avgSpeedKmh: 48.0, safetyScore: 92, distanceKm: 42.5);
      expect(insights.length, equals(2));
      expect(insights.first.category, equals('Defensive Riding'));
    });

    test('RecommendationEngine provides smart suggestions', () {
      final recs = RecommendationEngine.getRecommendations();
      expect(recs.length, greaterThan(0));
      expect(recs.first.title, isNotEmpty);
    });
  });
}

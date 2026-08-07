import '../../../core/errors/result.dart';
import '../services/ai_provider.dart';

abstract class AiRepository {
  Future<Result<String>> askCopilot(String prompt);
}

class MockAiRepository implements AiRepository {
  final AiProvider provider;

  MockAiRepository(this.provider);

  @override
  Future<Result<String>> askCopilot(String prompt) {
    return provider.generateResponse(prompt: prompt);
  }
}

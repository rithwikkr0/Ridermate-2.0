import '../../../providers/base_controller.dart';
import '../services/ai_provider.dart';
import '../services/conversation_memory.dart';
import '../repositories/ai_repository.dart';

class ChatDisplayMessage {
  final String text;
  final bool isFromAi;

  const ChatDisplayMessage(this.text, this.isFromAi);
}

/// RiderMate 2.0 — AI Controller
class AiController extends BaseController {
  final AiRepository repository;
  final ConversationMemory memory = ConversationMemory();

  AiController(this.repository);

  int get readinessScore => 92;

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

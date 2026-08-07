import 'ai_provider.dart';

class ConversationMemory {
  final List<AiMessage> _messages = [];

  List<AiMessage> get messages => List.unmodifiable(_messages);

  void addMessage(AiRole role, String content) {
    _messages.add(AiMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-${_messages.length}',
      role: role,
      content: content,
      timestamp: DateTime.now(),
    ));
  }

  void clearHistory() => _messages.clear();
}

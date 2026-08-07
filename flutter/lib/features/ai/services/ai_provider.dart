import '../../../core/errors/result.dart';

enum AiRole { user, model, system }

class AiMessage {
  final String id;
  final AiRole role;
  final String content;
  final DateTime timestamp;

  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// RiderMate 2.0 — AI Provider Interface (Plug-and-play architecture)
abstract class AiProvider {
  Future<Result<String>> generateResponse({
    required String prompt,
    String? systemInstruction,
    List<AiMessage>? conversationHistory,
  });
}

class MockAiProvider implements AiProvider {
  @override
  Future<Result<String>> generateResponse({
    required String prompt,
    String? systemInstruction,
    List<AiMessage>? conversationHistory,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = prompt.toLowerCase();

    if (lower.contains('weather')) {
      return Result.success('Partly cloudy 24°C in Mumbai today. Ideal for coastal riding with tailwinds E 15 km/h.');
    } else if (lower.contains('chain') || lower.contains('tire') || lower.contains('maintenance')) {
      return Result.success('Recommended tire pressure: 32 PSI (Front), 36 PSI (Rear). Clean and lube drive chain every 500 km.');
    } else if (lower.contains('sos') || lower.contains('first aid')) {
      return Result.success('Emergency Checklist: 1. Stay calm. 2. Verify rider safety. 3. Contact primary emergency contact or local dispatch.');
    }

    return Result.success('RiderMate AI: Ready to assist with route planning, safety scores, and riding telemetry analysis!');
  }
}

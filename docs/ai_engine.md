# RiderMate 2.0 — AI Intelligence Engine Architecture

> **Document Type**: AI Architecture & Provider Abstraction Specification  
> **Status**: Verified & Unit Tested with Mock Provider Engine  
> **Pluggable Targets**: Gemini 2.5 Flash / OpenAI GPT-4o / Local On-Device LLM

---

## 1. Overview
The RiderMate 2.0 AI Copilot engine provides real-time voice & text riding guidance, pre-ride readiness scoring, post-ride effort analysis, and smart route suggestions.

### Key Components
- **RiderMateAIProvider**: Domain-expert AI engine answering queries for Trip Planning, Route Suggestions, Motorcycle Maintenance, Riding Safety & Posture, Weather/Monsoon Prep, Emergency/SOS First Aid, and Nearby POIs.
- **AzureSafetyCoachService**: Connects to the Azure backend to evaluate aggregated ride metrics with local fallback.
- **PromptBuilder**: Enforces structured context injection (user metrics, current weather, ride history, fatigue indicators).
- **ConversationMemory**: Preserves session chat history.
- **RideCoachService**: Computes readiness scores (0–100%) and defensive riding insights.

---

## 2. System Architecture Diagram

```
+-------------------------------------------------------------------------+
|                          RiderMate 2.0 AI UI                            |
|        (Pulsing AI Neural Orb, Pre-Ride Briefing, AI Coach Insights)    |
+------------------------------------^------------------------------------+
                                     | Response Signal & Chat History
+------------------------------------+------------------------------------+
|                             AiController                                |
|             (sendMessage(), loadInsights(), getRecommendations())       |
+-----------------^-----------------------------------^-------------------+
                  |                                   |
+-----------------+-------------------+   +-----------+-------------------+
|         PromptBuilder               |   |     ConversationMemory        |
|  (Structured System & Context)      |   |   (Session Chat Buffer)       |
+-----------------^-------------------+   +-------------------------------+
                  |
+-----------------+-------------------------------------------------------+
|                         AiProvider (Interface)                          |
|   +-----------------------+-----------------------+-----------------+   |
|   |    MockAiProvider     |  FutureGeminiProvider |  FutureOpenAI   |   |
|   |  (Zero Cost / Active) |   (Plug-and-play)     | (Plug-and-play) |   |
|   +-----------------------+-----------------------+-----------------+   |
+-------------------------------------------------------------------------+
```

---

## 2. Pluggable Provider Interface

Any AI model vendor (Gemini, OpenAI, Claude, Local LLM) implements the clean `AiProvider` contract:

```dart
abstract class AiProvider {
  Future<Result<String>> generateResponse({
    required String prompt,
    String? systemInstruction,
    List<AiMessage>? conversationHistory,
  });
}
```

Switching providers requires changing 1 line in `DI.aiProvider` without touching any UI screen!

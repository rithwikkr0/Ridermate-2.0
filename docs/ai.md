# AI Copilot Engine

## Overview
The AI Copilot engine provides real-time voice & text riding guidance, pre-ride readiness scoring, post-ride effort analysis, and smart route suggestions.

## Key Components
- **MockAiProvider / GeminiClient**: Processes natural language user prompts and returns contextual rider insights.
- **PromptBuilderService**: Enforces structured context injection (user metrics, current weather, ride history, fatigue indicators).
- **ConversationMemoryService**: Preserves session chat history.
- **RideCoachService**: Computes readiness scores (0-100%) and safety advisories based on sleep, weather, and training load.

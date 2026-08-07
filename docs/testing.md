# RiderMate 2.0 — Testing & Quality Assurance Guide

> **Framework**: Flutter Test Suite · **Total Tests**: 26 Passing (100% Green)

---

## 1. Test Architecture Overview

```
test/
├── ai_engine_test.dart            ← 5 Unit Tests (MockAiProvider, PromptBuilder, Memory)
├── auth_profile_test.dart         ← 3 Unit Tests (Session, MockAuth, UserRepository)
├── community_platform_test.dart   ← 4 Unit Tests (FriendManager, ClubManager, Challenges)
├── garage_management_test.dart   ← 3 Unit Tests (FuelManager, ExpenseCalc, Reminders)
├── maps_navigation_test.dart      ← 4 Unit Tests (OSM Config, Route Planning, Search)
├── ride_engine_test.dart          ← 4 Unit Tests (Haversine, Stats, RideGenerator)
├── safety_engine_test.dart        ← 2 Unit Tests (SafetyScore, SOS Countdown)
└── widget_test.dart               ← 1 Widget Test (App Launch, Splash settle)
```

---

## 2. Test Execution Command

```bash
cd flutter
flutter test
```

# Changelog

All notable changes to the RiderMate 2.0 project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0] - 2026-08-19

### Added
- **Full Authentication System**: SQLite persistence with password hashing, email validation, visibility toggles, loading indicators, session restoration, and password reset flow.
- **RiderMate AI Copilot**: Domain-expert AI provider covering trip planning, route suggestions, motorcycle maintenance, cornering/safety, weather advisory, and emergency first aid. Added hero readiness card on Dashboard, dedicated Floating Action Button, and voice mode navigation.
- **Vehicle Intelligence & Challan Management**: SQLite v11 schema tracking vehicle documents, insurance/PUC expiry alerts, and traffic challans.
- **Gamification Engine**: Rider XP thresholds (Novice to Legend), weekly challenges, and achievement milestone tracking.
- **Azure Cloud Sync & Integration**: End-to-end multi-user REST APIs on FastAPI with JWT auth, idempotency deduplication, and Azure Blob Storage media management.
- **Notification Intelligence**: 8 Android notification channels with category filtering, quiet hours, throttling deduplication, and deep linking.

### Changed
- Cleaned and consolidated `docs/` architecture documents into single canonical sources per topic.
- Archived `design_reference/` (33 MB) to dedicated `design-reference` branch to optimize repository clone weight.
- Removed legacy `project_b_inspection/` React/TypeScript prototype folder.
- Replaced deprecated Radio widgets in settings and community report dialogs.

### Verified
- `flutter analyze`: 0 errors.
- `flutter test`: 193/193 tests passed (100%).
- `backend/tests`: 7/7 pytest + 11/11 master cloud QA integration tests passed (100%).
- `flutter build apk --release`: 62.1 MB signed APK verified.

---

## [v1.0.0-alpha] - 2026-08-07

### Added
- **UI & Foundation Engine**: Dark glassmorphism design system using Circuit Orange (`#FF6B00`) theme tokens across 32+ screens.
- **State Architecture**: `MultiProvider` registration with 8 feature controllers (`AuthController`, `ProfileController`, `RideController`, `SosController`, `AiController`, `CommunityController`, `GarageController`, `NavigationController`, `WeatherController`).
- **Live OpenWeather Integration**: `OpenWeatherService` HTTP client with temperature, humidity, wind telemetry, hourly forecasts, and automated Ride Suitability Score calculation.
- **Live Telemetry & Safety**: Haversine distance calculator, live ride telemetry simulator, SOS emergency 5-second countdown timer, and crash detection heuristics.
- **AI Copilot**: Natural language AI chat, voice orb animation, readiness score computation, and prompt builder service.
- **Garage Management**: Fuel fill logger, mileage calculator (km/L), maintenance service logs, and automated mileage alert engine.
- **Community Platform**: Rider social feed, squad club rosters, group chat UI, and weekly rankings leaderboard.
- **Automated Verification**: Comprehensive unit test suite (`28/28 PASS`), static analyzer (`0 Errors, 0 Warnings`), and verified release APK (`50.6 MB`) installed on physical Android device.

### Changed
- Standardized file paths and route navigation to use `GoRouter` named paths.
- Replaced hardcoded UI widgets with dynamic controller state.

### Fixed
- Fixed Windows Gradle R8 minification task lock issue in `android/app/build.gradle.kts`.
- Fixed multi-user Android ADB streamed installation scoping.

### Known Issues
- Real-time FCM push notification payload receiver pending live server key configuration.
- SQLite local database fallback for memories journal currently operating with mock repository provider.

### Upcoming Features
- Supabase PostgreSQL production schema sync.
- Offline MapLibre vector tile tile-pack downloader.

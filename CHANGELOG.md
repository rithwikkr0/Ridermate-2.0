# Changelog

All notable changes to the RiderMate 2.0 project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

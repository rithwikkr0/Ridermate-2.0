# RiderMate 2.0 — Production Mobility Platform

![RiderMate Logo](flutter/assets/images/ridermate_icon.png)

[![Flutter](https://img.shields.io/badge/Flutter-3.11.5-02569B?logo=flutter)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-v1.0.0--alpha-FF6B00)](#versioning)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#license)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)](#verification)
[![Test Suite](https://img.shields.io/badge/Tests-28%2F28%20Passed-success)](#testing)

---

## 📌 Project Overview
**RiderMate 2.0** is an Android-first, production-grade smart mobility application designed for motorcyclists and cyclists. It provides high-precision ride telemetry, AI voice coaching, automated crash detection with SOS emergency broadcast, garage fuel & maintenance tracking, OpenWeather telemetry, and a rider community platform.

Built with a dark glassmorphic design system using **Circuit Orange (`#FF6B00`)** theme tokens, RiderMate 2.0 operates with a zero-cost architecture utilizing a 4-tier decoupled pattern with seamless offline mock-to-live backend failovers.

---

## 🔥 Key Feature Modules

| Feature Module | Description | State |
| :--- | :--- | :--- |
| **☀️ Live Weather Engine** | Real-time OpenWeather API integration, wind & humidity metrics, hourly forecasts, and automated Ride Suitability Score calculation (0-100%). | **Live Telemetry** |
| **🏍️ Ride Engine** | High-precision Haversine distance telemetry, speed monitoring, elevation tracking, calories burned, and GPX/PDF export. | **Connected** |
| **🤖 AI Copilot** | Natural language riding assistant, pulsing voice orb, pre-ride readiness scoring, and defensive coaching insights. | **Connected** |
| **🚨 SOS Emergency Engine** | Automated crash detection heuristics, accelerometer vector analysis, emergency contact alerts, and 5-second countdown safety system. | **Connected** |
| **🗺️ Maps & Navigation** | MapLibre GL vector maps, OpenStreetMap integration, route options (Fastest/Scenic/Mountain), saved routes, and heatmap explorer. | **Connected** |
| **👥 Community Platform** | Rider social feed, squad club management, member rosters, group chat, and weekly rankings leaderboards. | **Connected** |
| **🔧 Garage Management** | Motorcycle profiles, fuel log tracker, mileage calculator (km/L), maintenance log records, and automated service reminders. | **Connected** |
| **👤 Auth & Profile** | MultiProvider user session management, profile stats overview, achievement badges, and settings customization. | **Connected** |

---

## 🏗️ System Architecture

```mermaid
graph TD
    subgraph Presentation Layer
        UI["Flutter UI (32+ Glassmorphic Screens)"]
        Widgets["Reusable Glass Cards & Controls"]
    end

    subgraph State Management
        Controllers["Provider Controllers (ChangeNotifier)"]
    end

    subgraph Repository Abstraction
        Repos["Data Repositories"]
    end

    subgraph Service & Telemetry Layer
        WeatherService["OpenWeather API Service"]
        RideEngine["Haversine & Statistics Engine"]
        SafetyEngine["Crash Detection & SOS Countdown"]
        AiEngine["AiCoach & Prompt Builder"]
        GarageEngine["Fuel & Maintenance Engine"]
    end

    subgraph Data Sources
        LocalMock["Local Mock & Offline Fallback Engine"]
        RemoteBackend["FastAPI + Supabase Backend"]
    end

    UI --> Controllers
    Controllers --> Repos
    Repos --> Service & Telemetry Layer
    Service & Telemetry Layer --> LocalMock
    Service & Telemetry Layer --> RemoteBackend
```

---

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart) — Android-First target
- **Design System**: Custom Dark Glassmorphism with Circuit Orange (`#FF6B00`) tokens
- **State Management**: `provider` (MultiProvider pattern)
- **Routing**: `go_router`
- **Backend API**: FastAPI (Python)
- **Database**: PostgreSQL (Supabase Free Tier)
- **Authentication**: Supabase Auth + Mock Session Fallback
- **Telemetry & Maps**: OpenWeather API, MapLibre GL, OpenStreetMap (OSM)

---

## 📁 Repository Folder Structure

```
Ridermate-2.0/
├── .gitignore
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── architecture.md
│   ├── ai.md
│   ├── garage.md
│   ├── maps.md
│   ├── community.md
│   ├── safety.md
│   ├── testing.md
│   ├── release_notes.md
│   └── api_reference.md
├── backend/
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── db/
│   │   ├── models/
│   │   ├── schemas/
│   │   └── services/
│   └── requirements.txt
└── flutter/
    ├── assets/
    │   └── images/
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── constants/
    │   │   ├── errors/
    │   │   ├── router/
    │   │   ├── theme/
    │   │   └── widgets/
    │   └── features/
    │       ├── ai/
    │       ├── auth/
    │       ├── community/
    │       ├── garage/
    │       ├── home/
    │       ├── maps/
    │       ├── profile/
    │       ├── rides/
    │       ├── safety/
    │       └── weather/
    └── test/
        ├── ai_engine_test.dart
        ├── auth_profile_test.dart
        ├── community_platform_test.dart
        ├── garage_management_test.dart
        ├── maps_navigation_test.dart
        ├── ride_engine_test.dart
        ├── safety_engine_test.dart
        └── weather_service_test.dart
```

---

## ⚙️ Build & Local Installation

### Requirements
- **Flutter SDK**: `^3.11.5`
- **Java JDK**: OpenJDK 17 or JDK 21 (`JDK-21.0.12.8-hotspot`)
- **Android SDK**: API level 21+
- **ADB**: Android Debug Bridge

### Step-by-Step Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/rithwikkr0/Ridermate-2.0.git
   cd Ridermate-2.0/flutter
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Static Analyzer**:
   ```bash
   flutter analyze
   ```

4. **Run Unit & Integration Test Suite**:
   ```bash
   flutter test
   ```

5. **Build Production Release APK**:
   ```bash
   $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.12.8-hotspot"
   flutter build apk --release
   ```

6. **Install onto Physical Device**:
   ```bash
   adb install -g -r build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 📌 Project Status & Roadmap

- [x] **v1.0.0-alpha**: Complete 32+ Glassmorphic screens, MultiProvider state wiring across all 9 features, Live OpenWeather API integration, unit test suite (28/28 PASS), clean release APK (50.6 MB).
- [ ] **v1.1.0-beta**: Real-time Firebase Cloud Messaging (FCM) push notifications integration.
- [ ] **v1.2.0**: SQLite local offline database sync for Memories & Ride Journal entries.
- [ ] **v2.0.0**: Supabase live cloud database synchronization & real-time squad telemetry socket streaming.

---

## 📄 License
This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer & Contact
- **Lead Architect & Developer**: RiderMate Development Team
- **GitHub**: [https://github.com/rithwikkr0/Ridermate-2.0](https://github.com/rithwikkr0/Ridermate-2.0)

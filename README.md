# RiderMate 2.0 — Production Mobility Platform

![RiderMate Logo](flutter/assets/images/ridermate_icon.png)

[![Flutter](https://img.shields.io/badge/Flutter-3.11.5-02569B?logo=flutter)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-v2.1.0-FF6B00)](#versioning)
[![Website](https://img.shields.io/badge/Website-Azure%20Static%20Web%20Apps-0078D4?logo=microsoftazure)](https://green-coast-00868c100.7.azurestaticapps.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#license)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)](#verification)
[![Test Suite](https://img.shields.io/badge/Tests-193%2F193%20Passed-success)](#testing)

---

## 🌐 Official Marketing & Download Website
- **Live Portal:** [https://green-coast-00868c100.7.azurestaticapps.net](https://green-coast-00868c100.7.azurestaticapps.net)
- **Direct APK Download:** [https://green-coast-00868c100.7.azurestaticapps.net/downloads/RiderMate-2.0.apk](https://green-coast-00868c100.7.azurestaticapps.net/downloads/RiderMate-2.0.apk)
- **Privacy Policy:** [https://green-coast-00868c100.7.azurestaticapps.net/privacy](https://green-coast-00868c100.7.azurestaticapps.net/privacy)
- **Data Safety Declaration:** [https://green-coast-00868c100.7.azurestaticapps.net/data-safety](https://green-coast-00868c100.7.azurestaticapps.net/data-safety)
- **Referral Squad Hub:** [https://green-coast-00868c100.7.azurestaticapps.net/join](https://green-coast-00868c100.7.azurestaticapps.net/join)
- **Developer Handoff Docs:** [`docs/website.md`](docs/website.md)

---

## 📌 Project Overview
**RiderMate 2.0** is an Android-first, production-grade smart mobility application designed for motorcyclists and cyclists. It provides high-precision ride telemetry, AI voice coaching, automated crash detection with SOS emergency broadcast, garage fuel & maintenance tracking, OpenWeather telemetry, and a rider community platform.

Built with a dark glassmorphic design system using **Circuit Orange (`#FF6B00`)** theme tokens, RiderMate 2.0 operates with a zero-cost architecture utilizing a 4-tier decoupled pattern with seamless offline mock-to-live backend failovers.

---

## 🔥 Key Feature Modules

| Feature Module | Description | State |
| :--- | :--- | :--- |
| **⚡ Google Account Auto-Fill** | 1-tap Google account details retrieval into form fields with full freedom to edit and customize name, email, phone, and password before saving. | **Live & Connected** |
| **🏍️ 50+ Motorcycle Intelligence** | Comprehensive Indian motorcycle catalogue across 11 brands, flexible Indian RTO plate lookup (supporting 1-4 trailing digits like `KA04EL274` and `BH` series), and brand/model selector chips with exact CC badges. | **Live & Connected** |
| **☀️ Live Weather Engine** | Real-time OpenWeather API integration, wind & humidity metrics, hourly forecasts, and automated Ride Suitability Score calculation (0-100%). | **Live Telemetry** |
| **🏎️ Ride Engine** | High-precision Haversine distance telemetry, speed monitoring, elevation tracking, calories burned, and GPX/PDF export. | **Connected** |
| **🤖 AI Copilot** | Natural language riding assistant, pulsing voice orb, pre-ride readiness scoring, and defensive coaching insights. | **Connected** |
| **🚨 SOS Emergency Engine** | Automated crash detection heuristics, accelerometer vector analysis, emergency contact alerts, and 5-second countdown safety system. | **Connected** |
| **🗺️ Maps & Navigation** | Dynamic Dark Matter maps, OpenStreetMap integration, route options (Fastest/Scenic/Mountain), saved routes, and heatmap explorer. | **Connected** |
| **👥 Community Platform** | Rider social feed, squad club management, member rosters, group chat, and weekly rankings leaderboards. | **Connected** |
| **🔧 Garage & Challan Vault** | Motorcycle profiles, fuel log tracker, mileage calculator (km/L), maintenance log records, automated service reminders, and traffic challan vault. | **Connected** |
| **👤 Auth, Profile & Gamification** | MultiProvider user session management, profile stats overview, XP leveling (Novice to Legend), and achievement badges. | **Connected** |

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
- **Backend API**: FastAPI (Python 3.12/3.13) with JWT security & rate limiting
- **Database**: SQLite (v11 schema offline-first) / PostgreSQL (Azure / Cloud)
- **Cloud Storage**: Azure Blob Storage (`azure-storage-blob`) with signed SAS URLs
- **Telemetry & Maps**: Open-Meteo API, OpenStreetMap (OSM), OSRM routing

---

## 📁 Repository Folder Structure

```
Ridermate-2.0/
├── .gitignore
├── README.md
├── CHANGELOG.md
├── docs/
│   ├── ai_engine.md
│   ├── api_reference.md
│   ├── architecture.md
│   ├── authentication.md
│   ├── backend.md
│   ├── community_platform.md
│   ├── garage_management.md
│   ├── maps_navigation.md
│   ├── performance.md
│   ├── release_checklist.md
│   ├── release_notes.md
│   ├── ride_engine.md
│   ├── safety_engine.md
│   ├── security.md
│   └── testing.md
├── backend/
│   ├── Dockerfile
│   ├── main.py
│   ├── requirements.txt
│   ├── alembic/
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── db/
│   │   ├── models/
│   │   └── schemas/
│   └── tests/
└── flutter/
    ├── pubspec.yaml
    ├── assets/
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   ├── features/
    │   └── providers/
    └── test/
```

> 💡 **Design Reference**: UI design screens, specs, and HTML prototypes are archived in the [`design-reference` branch](../../tree/design-reference).

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
- [x] **v2.0.0**: Azure Cloud Sync, SQLite v11 schema with Gamification & Challan management, real AI Safety Coach integration, and dark glassmorphic UI overhaul.
- [x] **v2.1.0**: Google Account Auto-fill with post-fill editing, 50+ Indian motorcycle catalogue with flexible RTO plate lookup, cinematic AI onboarding visuals, website 3D model & 19.5:9 smartphone frame showcase, and verified 70.1 MB release APK.
- [ ] **v2.2.0**: Real-time Firebase Cloud Messaging (FCM) push notifications integration.
- [ ] **v3.0.0**: Multi-rider mesh convoy socket streaming & MapLibre offline vector tile packs.

---

## 📄 License
This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer & Contact
- **Lead Architect & Developer**: RiderMate Development Team
- **GitHub**: [https://github.com/rithwikkr0/Ridermate-2.0](https://github.com/rithwikkr0/Ridermate-2.0)

# RiderMate 2.0 — Backend Architecture & Integration Guide

> **Stack**: FastAPI + PostgreSQL (Supabase Free) + JWT Auth + Docker  
> **Status**: Architecture Complete — Ready for Supabase Integration

---

## 1. Architecture Diagram

```
Flutter App (Android)
      |
      | HTTPS / REST
      ↓
FastAPI Backend (Python 3.12)
      |
      ├── /api/v1/auth       ← JWT Issue + Supabase Auth
      ├── /api/v1/profile    ← User Profile CRUD
      ├── /api/v1/rides      ← Ride Engine Data
      ├── /api/v1/vehicles   ← Garage Management
      ├── /api/v1/safety     ← SOS + Crash Events
      └── /api/v1/community  ← Clubs, Feed, Leaderboard
              |
              ↓
      Supabase PostgreSQL (Free 500MB)
      Supabase Auth (Free 50K MAU)
      Supabase Storage (Free 1GB)
      Supabase Realtime (WebSocket Channels)
```

---

## 2. Database Schema (see `alembic/V1__initial_schema.sql`)

### Core Tables
| Table | Purpose |
|---|---|
| `users` | Rider identity, XP, level |
| `vehicles` | Garage — all registered bikes |
| `rides` | Ride sessions with telemetry summary |
| `ride_points` | Raw GPS coordinates per ride |
| `fuel_records` | Fuel log & mileage calculation |
| `maintenance_records` | Workshop service history |
| `safety_events` | Crashes, SOS triggers, overspeeds |
| `emergency_contacts` | Priority contacts per rider |
| `ride_clubs` | Squad system |
| `posts` | Social feed ride posts |
| `ai_conversations` | AI chat message history |

---

## 3. Migration Strategy (Replace Mock → Live)

Modules are migrated **one at a time** without touching the Flutter UI:

1. ✅ Auth → Replace `MockAuthService` with `SupabaseAuthService`
2. ⏳ Profile → Replace `MockUserRepository` with `SupabaseProfileRepository`
3. ⏳ Garage → Replace `MockGarageRepository` with `SupabaseGarageRepository`
4. ⏳ Rides → Replace `MockRideRepository` with `SupabaseRideRepository`
5. ⏳ Safety → Replace `MockCrashDetectionEngine` with real accelerometer + Supabase
6. ⏳ Community → Replace `MockCommunityRepository` with Supabase Realtime
7. ⏳ AI → Replace `MockAiProvider` with Gemini 2.5 Flash API

---

## 4. Security

- **JWT**: HS256 signed access token (30 min) + refresh token (7 days)
- **Row Level Security**: Enabled on all tables. Riders can only access their own data.
- **Password Hashing**: bcrypt via passlib
- **CORS**: Configurable via `.env`
- **Secrets**: Never commit `.env` to git

---

## 5. Deployment Options (All Free Tier)

| Platform | Free RAM | Free Disk | Free Bandwidth |
|---|---|---|---|
| Railway | 512 MB | 1 GB | 100 GB/month |
| Render | 512 MB | — | — |
| Google Cloud Run | 256 MB | — | 2M requests/month |

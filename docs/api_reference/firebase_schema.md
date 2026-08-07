# RiderMate 2.0 — Firebase & Realtime Database API Schema

> **Document Type**: Backend Integration Specification  
> **Source**: Mined from legacy `project_b2/firebase.ts` & `project_b1/services/storageService.ts`

---

## 1. Firebase Service Architecture

The backend infrastructure for RiderMate 2.0 is structured around four Firebase core services:

```
Firebase Project (ridermate-prod)
├── Authentication (Email/Password, Google Sign-In)
├── Cloud Firestore (Profiles, Rides History, Media Metadata)
├── Realtime Database (Live Telemetry, Group Location Sharing, SOS Alerts)
└── Cloud Storage (Ride Photos, Audio Voice Notes, Avatar Images)
```

---

## 2. Firestore Collections Schema

### Collection: `users/{userId}`
```json
{
  "name": "John Rider",
  "username": "@johnrider",
  "email": "john@ridermate.com",
  "city": "Mumbai",
  "vehicleType": "KTM Duke 390",
  "weight": 70,
  "level": "Elite Rider",
  "xp": 8450,
  "xpToNext": 10000,
  "memberSince": "2024-01-15"
}
```

### Collection: `users/{userId}/rides/{rideId}`
```json
{
  "id": "ride-101",
  "startTime": 1723000000000,
  "endTime": 1723003600000,
  "distanceKm": 42.5,
  "durationMinutes": 60,
  "avgSpeed": 28.2,
  "maxSpeed": 72.0,
  "elevationGain": 320,
  "calories": 450,
  "overspeedEvents": 2,
  "safetyScore": 92,
  "points": 210,
  "path": [
    { "latitude": 19.076, "longitude": 72.8777, "timestamp": 1723000000000, "speed": 25.0 }
  ]
}
```

### Collection: `users/{userId}/memories/{memoryId}`
```json
{
  "id": "mem-201",
  "note": "Sunset coastal highway ride",
  "latitude": 18.922,
  "longitude": 72.834,
  "timestamp": 1723002000000,
  "privacy": "Public",
  "imageUrl": "https://storage.googleapis.com/ridermate-prod/memories/mem-201.jpg"
}
```

---

## 3. Realtime Database Schema (Live Telemetry & Safety)

### Path: `/live_sessions/{sessionId}`
```json
{
  "riderId": "user-001",
  "currentLat": 19.0760,
  "currentLng": 72.8777,
  "currentSpeedKmh": 42.5,
  "heading": 180,
  "lastUpdateTimestamp": 1723003550000,
  "isSosActive": false,
  "crashDetected": false
}
```

### Path: `/squad_telemetry/{squadId}/{riderId}`
```json
{
  "name": "Priya S.",
  "lat": 19.0810,
  "lng": 72.8820,
  "distanceFromLeaderKm": 0.4,
  "batteryPercent": 88
}
```

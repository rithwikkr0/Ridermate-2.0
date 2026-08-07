# RiderMate 2.0 — Ride Engine Architecture & Data Flow

> **Document Type**: Technical Architecture & Engine Specification  
> **Target Framework**: Flutter 3.41 / Dart 3.11  
> **Status**: Verified & Unit Tested

---

## 1. System Architecture Diagram

```
+-----------------------------------------------------------------------+
|                            RiderMate 2.0 UI                           |
|      (Live Ride Tracking, Ride Summary, Performance HUD Screens)      |
+-----------------------------------^-----------------------------------+
                                    | State Stream (60 FPS)
+-----------------------------------+-----------------------------------+
|                           RideController                              |
|           (startRide(), pauseRide(), resumeRide(), stopRide())        |
+-----------------^-----------------------------------^-----------------+
                  |                                   |
                  | Stream                            | Persistence
+-----------------+-------------------+   +-----------+-----------------+
|        LiveRideSimulator            |   |       RideRepository        |
|  (1-sec Telemetry Polyline Stream)  |   |    (100 Sample Rides Cache) |
+-----------------^-------------------+   +-----------------------------+
                  |
+-----------------+-----------------------------------------------------+
|                        StatisticsEngine                               |
|   (Avg Speed, Max Speed, Calories, Fuel Saved, CO2 Saved, Ride Score) |
+-----------------------------------------------------------------------+
```

---

## 2. Telemetry & Route Data Flow

1. **Telemetry Ingestion**: `LiveRideSimulator` emits a 1-second periodic tick stream of `LiveRideState` containing updated coordinates (`RoutePoint`), current speed in `km/h`, elapsed duration, and ETA.
2. **Realtime Analytics**: `StatisticsEngine` processes the polyline trajectory points and calculates:
   - Moving time vs. Stopped time.
   - Calories burned: `(distanceKm * 25 + durationMinutes * 4)`.
   - CO₂ saved vs. car: `distanceKm * 0.082 kg`.
   - Safety Score: Base 100 with penalties for overspeed events.
3. **Export Layer**: `MockRideExportService` converts completed rides to PDF bytes, GPX XML, CSV spreadsheets, or JSON objects without third-party web services.

---

## 3. Unit Test Coverage

- `Haversine distance calculation`: Verified against Mumbai-Pune coordinate pair (~120 km).
- `Unit converters`: `m/s` to `km/h` and `km` to `miles`.
- `StatisticsEngine`: Calorie & environmental emission formula verification.
- `MockRideGenerator`: 100 sample ride generator validation.

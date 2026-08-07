# RiderMate 2.0 — Safety Engine Architecture & Incident Dispatch

> **Document Type**: Safety Architecture & Emergency System Specification  
> **Framework**: Mock Sensor Interfaces & Fall Detection Engine  
> **Status**: Verified & Unit Tested

---

## 1. System Architecture Diagram

```
+-------------------------------------------------------------------------+
|                        RiderMate 2.0 Safety UI                          |
|         (Safety Center, Red SOS Countdown Screen, Emergency Contacts)   |
+------------------------------------^------------------------------------+
                                     | Emergency Signal & Timeline Stream
+------------------------------------+------------------------------------+
|                           SosController                                 |
|            (triggerSos(), cancelSos(), resolveEmergency())              |
+-----------------^-----------------------------------^-------------------+
                  |                                   |
+-----------------+-------------------+   +-----------+-------------------+
|      MockCrashDetectionEngine       |   |   SafetyScoreCalculator           |
| (G-Force Telemetry & Impact Alerts) |   | (Speed, Night, Helmet Formula)    |
+-------------------------------------+   +-------------------------------+
                  |
+-----------------+-------------------------------------------------------+
|                       EmergencyTimeline Logger                          |
|    (Crash Log -> Countdown -> Mock Contact Dispatch -> Resolved Event)  |
+-------------------------------------------------------------------------+
```

---

## 2. Crash Detection & Threshold Specifications

- **Minor Fall**: `3.0G - 5.0G` impact threshold.
- **Medium Crash**: `5.0G - 7.5G` impact threshold.
- **Major Crash**: `>7.5G` impact threshold with automatic 5-second SOS countdown trigger.

---

## 3. Defensive Safety Score Calculation

Score formula starts at **100**:
- **Speeding (>80 km/h)**: -10 points.
- **Extreme Speeding (>100 km/h)**: -20 points.
- **Overspeed Event**: -4 points per event.
- **Harsh Braking Event**: -5 points per event.
- **Night Riding**: -5 points.
- **Unverified Helmet**: -15 points.

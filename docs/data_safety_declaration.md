# RiderMate 2.0 - Google Play Data Safety Declaration

**Application:** RiderMate 2.0  
**Package Name:** `com.ridermate.ridermate`  
**Target:** Google Play Console Data Safety Form

---

## 1. Overview Summary

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes** (TLS 1.3 / HTTPS) |
| Do you provide a way for users to request that their data be deleted? | **Yes** (In-app Account Deletion under Settings > Privacy & Security > Delete Account, and via email request to privacy@ridermate.app) |

---

## 2. Data Types & Disclosures Breakdown

### A. Location
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Approximate Location** | Yes | No | No | App functionality, Navigation, Weather forecasts | Required for core ride features |
| **Precise Location (GPS)** | Yes | Yes (Only with user-designated emergency contacts during active SOS) | No | Live ride recording, Turn-by-turn navigation, SOS crash alerting | Required for ride recording |

> **Background Location Notice:** Precise location is accessed in the background only while a ride recording session or emergency monitoring is active by the user.

---

### B. Personal Info
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Name / Full Name** | Yes | Yes (Visible to approved squad/friends) | No | Account management, Community profiles | Required |
| **Email Address** | Yes | No | No | Account management, Authentication, Security | Required |
| **User IDs** | Yes | No | No | Account management, Database identification | Required |
| **Phone Number** | Yes | No | No | Account recovery, Optional contact info | Optional |

---

### C. Photos and Videos
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Photos** | Yes | Yes (Only posts explicitly shared to community) | No | Profile avatar, Vehicle documents (RC/Insurance), Ride memory gallery | Optional |

---

### D. Audio Files
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Voice / Sound Recordings** | Yes | No | No | Voice note memories created explicitly by the user in the journal | Optional |

---

### E. Health & Fitness / Sensors & Motion
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Physical Activity / Sensor Data** | Yes | No | Yes (Processed on-device for crash detection) | SOS Crash Detection heuristics, High-g impact calculation | Optional |

---

### F. App Activity & Ride Telemetry
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Ride History & Speed Telemetry** | Yes | Yes (If shared to social feed) | No | Ride analytics, Safety scores, Mileage & fuel tracking | Required for ride features |
| **In-app Actions** | Yes | No | No | Analytics, Gamification XP awarding | Required |

---

### G. App Info and Performance
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Crash Logs & Diagnostics** | Yes | No | Yes | App stability & crash reporting | Required |

---

### H. Device or Other Identifiers
| Data Type | Collected? | Shared? | Ephemeral? | Purpose | Optional / Required |
|---|---|---|---|---|---|
| **Device Token** | Yes | No | No | Push notifications for emergency alerts, service reminders | Optional |

---

## 3. Security Practices
1. **Encryption in Transit:** All network requests to RiderMate Cloud are transmitted over secure HTTPS connections with TLS 1.3 encryption.
2. **Encryption at Rest:** Server database storage utilizes encrypted volumes (AES-256).
3. **Data Deletion:** Complete deletion of account records, profile credentials, vehicle data, and ride telemetry can be initiated in-app or requested via `privacy@ridermate.app`.
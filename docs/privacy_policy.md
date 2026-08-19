# RiderMate 2.0 - Privacy Policy

**Effective Date:** August 19, 2026  
**Last Updated:** August 19, 2026  
**Application ID:** `com.ridermate.ridermate`  
**Contact:** privacy@ridermate.app

---

## 1. Introduction
RiderMate 2.0 ("RiderMate", "we", "us", or "our") is committed to protecting the privacy and security of motorcycle riders and users of our mobile application and cloud services. This Privacy Policy explains what personal and device data we collect, how it is used, how it is stored, and your rights regarding your information.

---

## 2. Information We Collect

### A. Location Data (Foreground and Background)
- **Precise Location (GPS):** Collected while recording rides, providing turn-by-turn navigation, and running SOS emergency crash detection.
- **Background Location:** When a ride recording or emergency monitoring session is active, RiderMate collects location data even when the app is minimized or running in the background to ensure continuous route tracking, speed monitoring, and crash detection. Background location collection terminates immediately when you stop a ride or deactivate emergency tracking.

### B. Motion & Sensor Data (Accelerometer & Gyroscope)
- **Accelerometer Readings:** Used locally by the on-device safety engine to calculate g-force impacts and detect potential motorcycle crashes.
- **Activity & Motion:** Used to detect riding motion and trigger pre-ride briefings. Motion telemetry is processed on-device and is not shared with third-party advertising networks.

### C. Account & Personal Identification
- **User Profile:** Name, email address, username, phone number, bio, and avatar photo provided during registration and profile configuration.
- **Authentication:** Password hashes (using bcrypt) and secure JWT authentication tokens.

### D. Media & Storage (Photos & Audio)
- **Camera & Photos:** Used when uploading vehicle document photos (Registration Certificate, Insurance, PUC), profile photos, and ride memory moments.
- **Audio & Microphone:** Used exclusively when you explicitly record voice notes in the Ride Memories journal. Audio files are stored locally on your device and never recorded in the background.

### E. Garage & Vehicle Telemetry
- Vehicle brand, model, year, registration number, odometer readings, fuel logs, maintenance history, and traffic violation/challan tracking records.

---

## 3. How We Use Your Information
- **Ride Navigation & Telemetry:** Calculating distance, average/max speed, elevation, and generating ride maps.
- **Safety & Emergency SOS:** Detecting severe high-g impact events and broadcasting your live GPS location to your designated emergency contacts via SMS and emergency calls.
- **Community & Social Interaction:** Allowing you to join riding squads, participate in group rides, and share ride stories with approved friends.
- **Vehicle Intelligence:** Reminding you of upcoming insurance, PUC, and service maintenance deadlines.

---

## 4. Data Storage & Security
- **Local-First Architecture:** All telemetry, ride history, and garage records are stored primarily on your device in an encrypted SQLite database.
- **Cloud Synchronization:** When connected, data synchronized with RiderMate Cloud (Azure App Service and Azure Database for PostgreSQL) is transmitted using industry-standard TLS 1.3 encryption in transit and AES-256 encryption at rest.
- **No Third-Party Ad Selling:** We do NOT sell, rent, or monetize your personal data, location telemetry, or riding habits to third-party advertisers or data brokers.

---

## 5. Permissions Required & Justification
- `ACCESS_FINE_LOCATION` / `ACCESS_BACKGROUND_LOCATION`: Real-time ride tracking, speed telemetry, and emergency crash broadcast.
- `ACTIVITY_RECOGNITION` / `BODY_SENSORS`: Real-time g-force crash detection heuristics.
- `RECORD_AUDIO`: Creating voice note memories in the journal upon user action.
- `CAMERA` / `READ_MEDIA_IMAGES`: Attaching vehicle documents and memory photos.
- `POST_NOTIFICATIONS`: Alerting you of emergency events, upcoming maintenance, and friend activity.

---

## 6. Data Retention and Account Deletion
You maintain full control over your data:
- You may export your complete ride history at any time in GPX / JSON format.
- You can request complete and permanent deletion of your account and all associated cloud/telemetry data directly within the app under **Settings > Privacy & Security > Delete Account** or by contacting `support@ridermate.app`.

---

## 7. Contact Information
For privacy inquiries, data deletion requests, or questions regarding this policy:
- **Email:** `privacy@ridermate.app`
- **Support Portal:** `https://ridermate.app/support`
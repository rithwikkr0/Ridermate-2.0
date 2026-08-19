# RiderMate 2.0 — API & Service Reference

> **Stack**: FastAPI (Python 3.12/3.13) · SQLite Local Database (v11) / Azure PostgreSQL · Azure Blob Storage

---

## 1. Authentication Endpoints (`/api/v1/auth`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Register new user account with email, password, full name, phone | No |
| `POST` | `/api/v1/auth/login` | Authenticate with credentials and receive JWT access & refresh tokens | No |
| `POST` | `/api/v1/auth/refresh` | Exchange valid refresh token for a new access token | No |
| `GET` | `/api/v1/auth/me` | Fetch authenticated user profile and vehicle summary | Bearer JWT |

---

## 2. Community & Social Endpoints (`/api/v1/community`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/community/feed` | Retrieve paginated public and friend social feed | Bearer JWT |
| `POST` | `/api/v1/community/posts` | Create new post with caption, location, privacy (`public`/`private`/`friends`) | Bearer JWT |
| `POST` | `/api/v1/community/posts/{id}/like` | Atomically like a post | Bearer JWT |
| `DELETE` | `/api/v1/community/posts/{id}/like` | Atomically remove like from a post | Bearer JWT |
| `POST` | `/api/v1/community/posts/{id}/comments` | Add a comment to a post | Bearer JWT |
| `GET` | `/api/v1/community/posts/{id}/comments` | Retrieve comments for a post | Bearer JWT |
| `POST` | `/api/v1/community/squads` | Create a riding squad / club | Bearer JWT |
| `POST` | `/api/v1/community/squads/{id}/join` | Join a squad club | Bearer JWT |

---

## 3. Friends Endpoints (`/api/v1/friends`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/friends/` | List all confirmed friends | Bearer JWT |
| `POST` | `/api/v1/friends/request` | Send friend request by username or email | Bearer JWT |
| `POST` | `/api/v1/friends/{id}/accept` | Accept an incoming friend request | Bearer JWT |
| `POST` | `/api/v1/friends/{id}/reject` | Reject an incoming friend request | Bearer JWT |

---

## 4. Rides & Telemetry Sync (`/api/v1/rides`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/rides/` | List synchronized ride sessions | Bearer JWT |
| `POST` | `/api/v1/rides/sync` | Sync completed ride session, telemetry breadcrumbs, and safety metrics | Bearer JWT |

---

## 5. Media & Azure Storage (`/api/v1/media`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/v1/media/upload` | Upload ride photos, avatar, or memory media | Bearer JWT |
| `GET` | `/api/v1/media/sas-url` | Generate short-lived signed SAS URL for controlled blob access | Bearer JWT |

---

## 6. Safety & AI Analysis (`/api/v1/safety` / `/api/safety`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/safety/analyze` | AI safety assessment of aggregated speed, duration, and overspeed metrics | Bearer JWT |
| `POST` | `/api/v1/safety/sos` | Broadcast emergency SOS alert with live location | Bearer JWT |

---

## 7. Health Check

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` or `/api/health` | Service health status verification |

---

## 8. External Free APIs (No Paid Keys Required)

- **Weather**: Open-Meteo (`https://api.open-meteo.com/v1/forecast`)
- **Map Tiles**: OpenStreetMap / CartoDB Dark (`https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png`)
- **Routing**: OSRM Free Routing API (`https://router.project-osrm.org`)

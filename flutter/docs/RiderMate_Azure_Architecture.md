# RiderMate 2.0 — Azure Architecture & Integration Plan

## 1. Executive Summary & Architectural Role

RiderMate 2.0 uses **Microsoft Azure** exclusively as a cost-optimized, serverless cloud processing and API proxy layer. Azure is **not** used as a real-time GPS telemetry engine or hard application dependency.

- **Offline-First Core**: All real-time telemetry (GPS tracking, Haversine distance, speed calculation, overspeed detection, and safety scoring) is executed locally on the device using SQLite (`ridermate.db`).
- **Serverless Cloud Layer**: Azure Functions provide optional cloud processing (serverless ride safety analysis, AI coaching proxy, and sync endpoints).
- **Cost Protection**: Utilizes Azure Functions consumption / serverless tier within free monthly allowances, ensuring zero baseline compute cost when idle.

```text
               ANDROID DEVICE (RiderMate 2.0)
                           │
                 Flutter Mobile Client
                           │
             ┌─────────────┴─────────────┐
             ↓                           ↓
      SQLite Database            AzureApiClient
     (ridermate.db)          (http.Client Proxy)
     [Offline-First]                     │
             │                    HTTPS / TLS 1.3
             │                           │
             │                           ↓
             │                  Azure Function App
             │                 (func-ridermate-api)
             │                           │
             │                 ┌─────────┴─────────┐
             │                 ↓                   ↓
             │         GET /api/health    POST /api/safety/analyze
             │                 │                   │
             └─ Sync & Cache ──┴───────────────────┘
```

---

## 2. Flutter Integration & API Abstraction Layer

The application interacts with Azure via a dedicated, decoupled client: `AzureApiClient` (`lib/core/network/azure_api_client.dart`).

### Environment Configuration
- Endpoints are driven by `EnvConfig` (`lib/core/config/env_config.dart`) and build-time `--dart-define` constants:
  - `AZURE_API_BASE_URL`: Base HTTPS URL of the Azure Function App.
  - `AZURE_FUNCTION_KEY`: Optional function-level authorization key.
- **Development Fallback**: `http://10.0.2.2:7071/api` (Android Emulator to local Azure Functions Core Tools host).
- **Production Endpoint**: `https://func-ridermate-api.azurewebsites.net/api`.

---

## 3. Implemented API Endpoints & Contracts

### A. Health Endpoint: `GET /api/health`
- **Purpose**: Low-overhead server health check.
- **Authentication**: Anonymous.
- **Response**:
```json
{
  "status": "ok",
  "service": "ridermate-api",
  "version": "1.0.0"
}
```

### B. Safety Analysis Endpoint: `POST /api/safety/analyze`
- **Purpose**: Serverless evaluation of completed ride telemetry.
- **Authentication**: Bearer Token (`Firebase Auth ID Token`) / `x-functions-key`.
- **Request Body**:
```json
{
  "rideId": "ride-1723730000000",
  "distanceKm": 42.6,
  "durationMinutes": 45,
  "maxSpeedKmh": 82.5,
  "averageSpeedKmh": 48.0,
  "safetyEvents": [
    {
      "eventType": "overspeed",
      "speedKmh": 82.5,
      "timestamp": 1723730120000
    }
  ]
}
```
- **Response Body**:
```json
{
  "riskLevel": "low",
  "safetyAssessment": "Safe riding behavior with controlled urban speeds.",
  "tips": [
    "Maintain safe following distance in wet weather conditions."
  ]
}
```

---

## 4. Security & Privacy Safeguards

1. **No API Keys in Client**: Azure Function App settings (`AZURE_FUNCTION_KEY` / backend secrets) protect downstream AI or third-party credentials.
2. **Minimal Data Payload**: Telemetry payloads exclude raw GPS coordinate streams and user personal identification. Only aggregated ride metrics (distance, avg speed, event counts) are sent for analysis.
3. **CORS Restrictions**: Configured strictly for authorized app origins. Wildcard `*` is prohibited in production settings.
4. **Token Validation**: Cloud Function endpoints validate Firebase Auth ID Tokens prior to executing processing logic.

---

## 5. Offline Fallback & Resiliency

If Azure Functions are unreachable due to network offline states or server errors:
1. `AzureApiClient` catches `SocketException`, `TimeoutException`, and HTTP errors cleanly without throwing unhandled exceptions.
2. Returns typed `Result.failure(NetworkError(...))`.
3. RiderMate 2.0 falls back to local SQLite analysis (`StatisticsEngine` & local safety score engine).
4. The user experience remains 100% functional.

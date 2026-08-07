# RiderMate 2.0 — Authentication & Profile Management Architecture

> **Document Type**: Authentication Architecture & User Session Specification  
> **Target Provider**: Supabase Auth (Future Integration)  
> **Status**: Verified & Unit Tested with Local Mock Session Persistence

---

## 1. System Architecture Diagram

```
+-------------------------------------------------------------------------+
|                  RiderMate 2.0 Auth & Profile UI                        |
|   (Login, Register, OTP, Edit Profile, Vehicles, Emergency Contacts)    |
+------------------------------------^------------------------------------+
                                     | Auth State & User Signal
+------------------------------------+------------------------------------+
|                         AuthController & ProfileController              |
|        (login(), logout(), loadProfile(), addVehicle(), addContact())   |
+-----------------^-----------------------------------^-------------------+
                  |                                   |
+-----------------+-------------------+   +-----------+-------------------+
|         MockSessionService          |   |       MockUserRepository         |
|  (Local Access & Refresh Token)     |   |   (Vehicles, Contacts, Prefs)   |
+-------------------------------------+   +-------------------------------+
```

---

## 2. Session Lifecycle & Persistence

1. **Local Token Cache**: Upon successful login, `MockSessionService` stores an access token (`mock_jwt_access_token_12345`), refresh token, and `userId` in `MockStorageService`.
2. **Auto-Login Check**: On app launch, `SessionService.getAccessToken()` is inspected to restore `AuthStatus.loggedIn` without requiring user re-entry.

---

## 3. Vehicle & Emergency Contacts Management

- **Vehicles**: Track brand, model, registration number (`MH-02-EQ-4589`), CC capacity, and service due dates.
- **Emergency Contacts**: Stores order-indexed contact cards (`Ramesh Rider`, Father, `+91 98765 43210`) linked to the SOS countdown service.

# RiderMate 2.0 — Community & Social Platform Architecture

> **Document Type**: Community Architecture & Realtime Social Specification  
> **Status**: Verified & Unit Tested with Mock Repository Pipeline  
> **Pluggable Realtime Target**: WebSockets / Supabase Realtime Channels

---

## 1. System Architecture Diagram

```
+-------------------------------------------------------------------------+
|                      RiderMate 2.0 Community UI                         |
|      (Social Feed, Friends List, Squad Clubs, Leaderboards, Chat)       |
+------------------------------------^------------------------------------+
                                     | Data Signal & Notification Stream
+------------------------------------+------------------------------------+
|                         CommunityController                             |
|               (loadCommunityOverview(), joinClub(), joinChallenge())    |
+-----------------^-----------------------------------^-------------------+
                  |                                   |
+-----------------+-------------------+   +-----------+-------------------+
|       FriendManagerService          |   |        ClubManagerService         |
|  (Friends List, Requests & Block)   |   |   (Squads, Roster & Stats)        |
+-----------------^-------------------+   +-------------------------------+
                  |
+-----------------+-------------------------------------------------------+
|                    MockCommunityRepository Engine                       |
|   (Leaderboard Ranks, Challenge Engine & Community Notifications)       |
+-------------------------------------------------------------------------+
```

---

## 2. Pluggable Realtime WebSocket Strategy

1. **Group Chat & Live Telemetry**: Live group ride coordinates and chat messages are abstracted behind `CommunityRepository`.
2. **Future WebSocket Integration**: Replacing `MockCommunityRepository` with a WebSocket channel stream (`wss://api.ridermate.app/ws/community`) requires zero UI changes!

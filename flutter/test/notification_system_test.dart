import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/core/notifications/models/app_notification.dart';
import 'package:ridermate/core/notifications/models/notification_preferences.dart';
import 'package:ridermate/core/notifications/models/notification_type.dart';
import 'package:ridermate/core/notifications/repositories/notification_repository.dart';
import 'package:ridermate/core/notifications/services/notification_service.dart';
import 'package:ridermate/core/notifications/controllers/notification_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared test helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _recreateNotificationTables() async {
  final db = await DatabaseService.instance.database;
  await db.execute('DROP TABLE IF EXISTS notifications');
  await db.execute('DROP TABLE IF EXISTS notification_preferences');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS notifications (
      id         TEXT PRIMARY KEY,
      user_id    TEXT NOT NULL,
      type       TEXT NOT NULL,
      title      TEXT NOT NULL,
      body       TEXT NOT NULL,
      created_at TEXT NOT NULL,
      read_at    TEXT,
      route      TEXT,
      entity_id  TEXT,
      priority   TEXT NOT NULL DEFAULT 'normal',
      payload    TEXT,
      image_url  TEXT,
      expires_at TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS notification_preferences (
      user_id             TEXT PRIMARY KEY,
      emergency_enabled   INTEGER NOT NULL DEFAULT 1,
      safety_enabled      INTEGER NOT NULL DEFAULT 1,
      ride_enabled        INTEGER NOT NULL DEFAULT 1,
      social_enabled      INTEGER NOT NULL DEFAULT 1,
      ai_enabled          INTEGER NOT NULL DEFAULT 1,
      maintenance_enabled INTEGER NOT NULL DEFAULT 1,
      achievement_enabled INTEGER NOT NULL DEFAULT 1,
      system_enabled      INTEGER NOT NULL DEFAULT 1,
      sound_enabled       INTEGER NOT NULL DEFAULT 1,
      vibration_enabled   INTEGER NOT NULL DEFAULT 1
    )
  ''');
}

AppNotification _makeNotif({
  required String id,
  required String userId,
  required NotificationType type,
  String title = 'Test',
  String body = 'Test body',
  String? route,
  String? entityId,
  NotificationPriority priority = NotificationPriority.normal,
}) {
  return AppNotification(
    id: id,
    userId: userId,
    type: type,
    title: title,
    body: body,
    createdAt: DateTime.now(),
    route: route,
    entityId: entityId,
    priority: priority,
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({'user_id': 'user_A', 'user_name': 'Test Rider'});
  });

  // ── GROUP 1: Models & Serialization ─────────────────────────────────────
  group('1. Notification Models & Serialization', () {
    test('AppNotification toMap/fromMap round-trip preserves all fields', () {
      final notif = AppNotification(
        id: 'notif_101',
        userId: 'user_A',
        type: NotificationType.safety,
        title: 'Overspeed Warning',
        body: 'Speed exceeded 80 km/h in urban zone',
        createdAt: DateTime(2026, 8, 10, 14, 30),
        route: '/safety',
        entityId: 'ride_99',
        priority: NotificationPriority.high,
        payload: {'speed': 84.5, 'zone': 'City Center'},
      );

      final map = notif.toMap();
      expect(map['id'], 'notif_101');
      expect(map['type'], 'safety');
      expect(map['priority'], 'high');

      final decoded = AppNotification.fromMap(map);
      expect(decoded.id, 'notif_101');
      expect(decoded.type, NotificationType.safety);
      expect(decoded.title, 'Overspeed Warning');
      expect(decoded.priority, NotificationPriority.high);
      expect(decoded.payload?['speed'], 84.5);
      expect(decoded.isRead, false);
    });

    test('AppNotification.copyWith sets readAt preserving all other fields', () {
      final now = DateTime(2026, 8, 10, 10, 0);
      final notif = _makeNotif(id: 'n1', userId: 'u1', type: NotificationType.ride);
      final read = notif.copyWith(readAt: now);
      expect(read.readAt, now);
      expect(read.id, 'n1');
      expect(read.isRead, true);
    });

    test('NotificationPriority.fromString handles all values and unknown fallback', () {
      expect(NotificationPriority.fromString('emergency'), NotificationPriority.emergency);
      expect(NotificationPriority.fromString('high'), NotificationPriority.high);
      expect(NotificationPriority.fromString('normal'), NotificationPriority.normal);
      expect(NotificationPriority.fromString('low'), NotificationPriority.low);
      expect(NotificationPriority.fromString('unknown'), NotificationPriority.normal);
    });

    test('NotificationType channel IDs are unique and correctly prefixed', () {
      final channelIds = NotificationType.values.map((t) => t.channelId).toList();
      expect(channelIds.toSet().length, NotificationType.values.length,
          reason: 'All channel IDs must be unique');
      for (final id in channelIds) {
        expect(id.startsWith('ridermate_'), true);
      }
    });

    test('NotificationPreferences category toggles and emergency lock', () {
      const prefs = NotificationPreferences(
        userId: 'user_A',
        safetyEnabled: false,
        rideEnabled: true,
      );
      expect(prefs.isCategoryEnabled(NotificationType.emergency), true);
      expect(prefs.isCategoryEnabled(NotificationType.safety), false);
      expect(prefs.isCategoryEnabled(NotificationType.ride), true);

      final updated = prefs.copyWith(safetyEnabled: true);
      expect(updated.safetyEnabled, true);
      expect(updated.isCategoryEnabled(NotificationType.safety), true);
    });
  });

  // ── GROUP 2: SQLite Repository ───────────────────────────────────────────
  group('2. SqliteNotificationRepository — CRUD & User Isolation', () {
    late SqliteNotificationRepository repo;

    setUp(() async {
      await _recreateNotificationTables();
      repo = SqliteNotificationRepository();
    });

    test('Save, fetch, and strict user isolation', () async {
      final n1 = _makeNotif(id: 'n1', userId: 'user_A', type: NotificationType.ride, title: 'Ride Started');
      final n2 = _makeNotif(id: 'n2', userId: 'user_B', type: NotificationType.ai, title: 'AI Insight');

      await repo.saveNotification(n1);
      await repo.saveNotification(n2);

      final forA = await repo.getNotifications(userId: 'user_A');
      expect(forA.dataOrNull?.length, 1);
      expect(forA.dataOrNull?.first.title, 'Ride Started');

      final forB = await repo.getNotifications(userId: 'user_B');
      expect(forB.dataOrNull?.length, 1);
      expect(forB.dataOrNull?.first.title, 'AI Insight');
    });

    test('Unread count increments and decrements correctly', () async {
      await repo.saveNotification(_makeNotif(id: 'n1', userId: 'user_A', type: NotificationType.ride));
      await repo.saveNotification(_makeNotif(id: 'n2', userId: 'user_A', type: NotificationType.safety));

      final count = await repo.getUnreadCount(userId: 'user_A');
      expect(count.dataOrNull, 2);

      await repo.markAsRead(id: 'n1', userId: 'user_A');
      final after = await repo.getUnreadCount(userId: 'user_A');
      expect(after.dataOrNull, 1);
    });

    test('markAllAsRead sets all to read and count becomes 0', () async {
      await repo.saveNotification(_makeNotif(id: 'a1', userId: 'user_A', type: NotificationType.ride));
      await repo.saveNotification(_makeNotif(id: 'a2', userId: 'user_A', type: NotificationType.safety));

      await repo.markAllAsRead(userId: 'user_A');
      final count = await repo.getUnreadCount(userId: 'user_A');
      expect(count.dataOrNull, 0);
    });

    test('delete removes only target notification', () async {
      await repo.saveNotification(_makeNotif(id: 'n1', userId: 'user_A', type: NotificationType.ride));
      await repo.saveNotification(_makeNotif(id: 'n2', userId: 'user_A', type: NotificationType.safety));

      await repo.deleteNotification(id: 'n1', userId: 'user_A');
      final remaining = await repo.getNotifications(userId: 'user_A');
      expect(remaining.dataOrNull?.length, 1);
      expect(remaining.dataOrNull?.first.id, 'n2');
    });

    test('clearAll removes all notifications for user only', () async {
      await repo.saveNotification(_makeNotif(id: 'a1', userId: 'user_A', type: NotificationType.ride));
      await repo.saveNotification(_makeNotif(id: 'b1', userId: 'user_B', type: NotificationType.ride));

      await repo.clearAllNotifications(userId: 'user_A');
      final forA = await repo.getNotifications(userId: 'user_A');
      expect(forA.dataOrNull?.isEmpty, true);

      final forB = await repo.getNotifications(userId: 'user_B');
      expect(forB.dataOrNull?.length, 1);
    });

    test('type filter returns only matching type', () async {
      await repo.saveNotification(_makeNotif(id: 'r1', userId: 'user_A', type: NotificationType.ride));
      await repo.saveNotification(_makeNotif(id: 's1', userId: 'user_A', type: NotificationType.safety));
      await repo.saveNotification(_makeNotif(id: 's2', userId: 'user_A', type: NotificationType.safety));

      final safety = await repo.getNotifications(userId: 'user_A', filterType: NotificationType.safety);
      expect(safety.dataOrNull?.length, 2);
      expect(safety.dataOrNull?.every((n) => n.type == NotificationType.safety), true);
    });
  });

  // ── GROUP 3: SQLite Preferences ──────────────────────────────────────────
  group('3. SqliteNotificationRepository — Preferences', () {
    late SqliteNotificationRepository repo;

    setUp(() async {
      await _recreateNotificationTables();
      repo = SqliteNotificationRepository();
    });

    test('Save and retrieve preferences with category overrides', () async {
      const prefs = NotificationPreferences(
        userId: 'user_A',
        safetyEnabled: false,
        soundEnabled: true,
        vibrationEnabled: false,
      );
      await repo.savePreferences(prefs);
      final fetched = await repo.getPreferences(userId: 'user_A');
      expect(fetched.dataOrNull?.safetyEnabled, false);
      expect(fetched.dataOrNull?.soundEnabled, true);
      expect(fetched.dataOrNull?.vibrationEnabled, false);
    });

    test('getPreferences creates defaults when row absent', () async {
      final prefs = await repo.getPreferences(userId: 'brand_new_user');
      expect(prefs.isSuccess, true);
      expect(prefs.dataOrNull?.userId, 'brand_new_user');
      expect(prefs.dataOrNull?.safetyEnabled, true);
      expect(prefs.dataOrNull?.emergencyEnabled, true);
    });

    test('Preferences survive replace (UPSERT) correctly', () async {
      const p1 = NotificationPreferences(userId: 'user_A', aiEnabled: false);
      const p2 = NotificationPreferences(userId: 'user_A', aiEnabled: true, soundEnabled: false);

      await repo.savePreferences(p1);
      await repo.savePreferences(p2); // replaces

      final result = await repo.getPreferences(userId: 'user_A');
      expect(result.dataOrNull?.aiEnabled, true);
      expect(result.dataOrNull?.soundEnabled, false);
    });
  });

  // ── GROUP 4: NotificationService Throttling & Facade ─────────────────────
  group('4. NotificationService — Throttling & Emergency', () {
    setUp(() async {
      await _recreateNotificationTables();
    });

    test('Throttle suppresses duplicate within cooldown window', () async {
      final first = await NotificationService.instance.notify(
        title: 'Overspeed',
        body: 'Speed > 80 km/h',
        type: NotificationType.safety,
        throttleCooldown: const Duration(seconds: 30),
        userId: 'user_A',
      );
      expect(first.dataOrNull, isNotNull);

      // Immediate duplicate — should be suppressed
      final second = await NotificationService.instance.notify(
        title: 'Overspeed',
        body: 'Speed > 80 km/h',
        type: NotificationType.safety,
        throttleCooldown: const Duration(seconds: 30),
        userId: 'user_A',
      );
      expect(second.dataOrNull, isNull);
    });

    test('Different entityId is not throttled by same type', () async {
      final first = await NotificationService.instance.notify(
        title: 'Speed Warning',
        body: 'Ride A overspeed',
        type: NotificationType.safety,
        entityId: 'ride_1',
        throttleCooldown: const Duration(seconds: 30),
        userId: 'user_A',
      );
      expect(first.dataOrNull, isNotNull);

      // Different entityId — NOT throttled
      final second = await NotificationService.instance.notify(
        title: 'Speed Warning',
        body: 'Ride B overspeed',
        type: NotificationType.safety,
        entityId: 'ride_2',
        throttleCooldown: const Duration(seconds: 30),
        userId: 'user_A',
      );
      expect(second.dataOrNull, isNotNull);
    });

    test('Emergency bypasses category preference and is never suppressed', () async {
      final result = await NotificationService.instance.notifyEmergency(
        title: 'SOS Active',
        body: 'Rider emergency active',
        userId: 'user_A',
      );
      expect(result.isSuccess, true);
      expect(result.dataOrNull?.type, NotificationType.emergency);
      expect(result.dataOrNull?.route, '/safety/tracking');
      expect(result.dataOrNull?.priority, NotificationPriority.emergency);
    });

    test('Category disabled suppresses non-emergency notification', () async {
      final repo = SqliteNotificationRepository();
      await repo.savePreferences(const NotificationPreferences(
        userId: 'user_A',
        rideEnabled: false,
      ));

      final result = await NotificationService.instance.notifyRideEvent(
        title: 'Ride Started',
        body: 'Solo ride',
        rideId: 'r1',
        userId: 'user_A',
      );
      // Should be suppressed (null data, still success result)
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isNull);
    });
  });

  // ── GROUP 5: Integration — Routes & Deep Links ───────────────────────────
  group('5. Notification Routes — Deep Link Validation', () {
    setUp(() async {
      await _recreateNotificationTables();
      // Clear singleton throttle cache so Group 4 cooldowns don't bleed into route tests
      NotificationService.instance.clearThrottleCache();
    });

    test('notifyRideEvent (active) has route /rides/live', () async {
      final result = await NotificationService.instance.notifyRideEvent(
        title: 'Ride Started',
        body: 'Solo ride',
        rideId: 'ride_x',
        isCompleted: false,
        userId: 'user_A',
      );
      expect(result.dataOrNull?.route, '/rides/live');
    });

    test('notifyRideEvent (completed) has route /rides/summary', () async {
      final result = await NotificationService.instance.notifyRideEvent(
        title: 'Ride Done',
        body: '10 km done',
        rideId: 'ride_y',
        isCompleted: true,
        userId: 'user_A',
      );
      expect(result.dataOrNull?.route, '/rides/summary');
    });

    test('notifyEmergency always routes to /safety/tracking', () async {
      final result = await NotificationService.instance.notifyEmergency(
        title: 'SOS',
        body: 'Emergency',
        userId: 'user_A',
      );
      expect(result.dataOrNull?.route, '/safety/tracking');
    });

    test('notifySafetyWarning routes to /safety', () async {
      final result = await NotificationService.instance.notifySafetyWarning(
        title: 'Overspeed',
        body: '85 km/h',
        userId: 'user_A',
      );
      expect(result.dataOrNull?.route, '/safety');
    });

    test('notifyMemory routes to /memories/detail with entityId', () async {
      final result = await NotificationService.instance.notifyMemory(
        title: 'New Memory',
        body: 'Memory saved',
        memoryId: 'mem_001',
        userId: 'user_A',
      );
      expect(result.dataOrNull?.route, '/memories/detail');
      expect(result.dataOrNull?.entityId, 'mem_001');
    });

    test('notifyMaintenance routes to /garage', () async {
      final result = await NotificationService.instance.notifyMaintenance(
        title: 'Service Due',
        body: 'Your bike needs servicing',
        userId: 'user_A',
      );
      expect(result.dataOrNull?.route, '/garage');
      expect(result.dataOrNull?.type, NotificationType.maintenance);
    });

    test('notifyAchievement routes to /achievements', () async {
      final result = await NotificationService.instance.notifyAchievement(
        title: '1000 km Badge',
        body: 'You earned a badge',
        achievementId: 'badge_1000km',
        userId: 'user_A',
      );
      expect(result.dataOrNull?.route, '/achievements');
      expect(result.dataOrNull?.entityId, 'badge_1000km');
    });
  });

  // ── GROUP 6: NotificationController State Machine ────────────────────────
  group('6. NotificationController — State, Filter, Mark All Read', () {
    test('Controller loads, marks all read, filters by type', () async {
      await _recreateNotificationTables();
      final controller = NotificationController();
      await controller.loadNotifications();

      await controller.markAllAsRead();
      expect(controller.unreadCount, 0);

      controller.setFilter(NotificationType.safety);
      expect(controller.selectedFilter, NotificationType.safety);

      controller.setUnreadOnlyFilter(true);
      expect(controller.unreadOnlyFilter, true);
      expect(controller.selectedFilter, isNull);

      controller.dispose();
    });

    test('refreshForUser reloads notifications for new user', () async {
      await _recreateNotificationTables();
      final repo = SqliteNotificationRepository();
      await repo.saveNotification(_makeNotif(id: 'n1', userId: 'user_X', type: NotificationType.ride));
      await repo.saveNotification(_makeNotif(id: 'n2', userId: 'user_Y', type: NotificationType.safety));

      final controller = NotificationController();
      await controller.refreshForUser('user_X');
      expect(controller.notifications.every((n) => n.userId == 'user_X'), true);

      await controller.refreshForUser('user_Y');
      expect(controller.notifications.every((n) => n.userId == 'user_Y'), true);

      controller.dispose();
    });
  });

  // ── GROUP 7: Offline Persistence ─────────────────────────────────────────
  group('7. Offline Persistence — Survives Session', () {
    test('Notification survives DB re-open (same in-memory instance)', () async {
      await _recreateNotificationTables();
      final repo = SqliteNotificationRepository();

      final n = _makeNotif(
        id: 'persist_test',
        userId: 'user_A',
        type: NotificationType.achievement,
        title: 'Badge Earned',
        route: '/achievements',
        entityId: 'badge_100km',
        priority: NotificationPriority.high,
      );
      await repo.saveNotification(n);

      // Re-query simulates re-opening the same DB connection
      final fetched = await repo.getNotifications(userId: 'user_A');
      expect(fetched.dataOrNull?.any((x) => x.id == 'persist_test'), true);
      final found = fetched.dataOrNull!.firstWhere((x) => x.id == 'persist_test');
      expect(found.title, 'Badge Earned');
      expect(found.route, '/achievements');
      expect(found.entityId, 'badge_100km');
      expect(found.priority, NotificationPriority.high);
    });

    test('Preferences persist correctly across re-queries', () async {
      await _recreateNotificationTables();
      final repo = SqliteNotificationRepository();

      const prefs = NotificationPreferences(
        userId: 'user_A',
        maintenanceEnabled: false,
        vibrationEnabled: false,
        soundEnabled: true,
      );
      await repo.savePreferences(prefs);

      final fetched = await repo.getPreferences(userId: 'user_A');
      expect(fetched.dataOrNull?.maintenanceEnabled, false);
      expect(fetched.dataOrNull?.vibrationEnabled, false);
      expect(fetched.dataOrNull?.soundEnabled, true);
    });
  });
}

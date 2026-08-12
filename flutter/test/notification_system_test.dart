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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({'user_id': 'user_A', 'user_name': 'Test Rider'});
  });

  group('1. Notification Models & Serialization Tests', () {
    test('AppNotification toMap and fromMap round-trip preserves all fields', () {
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

    test('NotificationPreferences category toggles and emergency lock check', () {
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

  group('2. SqliteNotificationRepository User-Isolated Database Tests', () {
    late SqliteNotificationRepository repository;

    setUp(() async {
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
      repository = SqliteNotificationRepository();
    });

    test('Create, retrieve, mark read, delete with strict user isolation', () async {
      final n1 = AppNotification(
        id: 'n1',
        userId: 'user_A',
        type: NotificationType.ride,
        title: 'Ride Started',
        body: 'Solo ride initiated',
        createdAt: DateTime.now(),
      );

      final n2 = AppNotification(
        id: 'n2',
        userId: 'user_B',
        type: NotificationType.ai,
        title: 'AI Insight',
        body: 'Smooth cornering detected',
        createdAt: DateTime.now(),
      );

      final save1 = await repository.saveNotification(n1);
      expect(save1.isSuccess, true);
      final save2 = await repository.saveNotification(n2);
      expect(save2.isSuccess, true);

      // Verify user A only sees user A notifications
      final userANotifs = await repository.getNotifications(userId: 'user_A');
      expect(userANotifs.isSuccess, true);
      expect(userANotifs.dataOrNull?.length, 1);
      expect(userANotifs.dataOrNull?.first.title, 'Ride Started');

      // Verify user B only sees user B notifications
      final userBNotifs = await repository.getNotifications(userId: 'user_B');
      expect(userBNotifs.isSuccess, true);
      expect(userBNotifs.dataOrNull?.length, 1);
      expect(userBNotifs.dataOrNull?.first.title, 'AI Insight');

      // Unread count
      final countA = await repository.getUnreadCount(userId: 'user_A');
      expect(countA.dataOrNull, 1);

      // Mark read
      final markRes = await repository.markAsRead(id: 'n1', userId: 'user_A');
      expect(markRes.dataOrNull, true);

      final countAAfter = await repository.getUnreadCount(userId: 'user_A');
      expect(countAAfter.dataOrNull, 0);

      // Delete notification
      final delRes = await repository.deleteNotification(id: 'n1', userId: 'user_A');
      expect(delRes.dataOrNull, true);

      final userAEmpty = await repository.getNotifications(userId: 'user_A');
      expect(userAEmpty.dataOrNull?.isEmpty, true);
    });

    test('Save and retrieve NotificationPreferences', () async {
      const prefs = NotificationPreferences(
        userId: 'user_A',
        safetyEnabled: false,
        soundEnabled: true,
      );

      final saveRes = await repository.savePreferences(prefs);
      expect(saveRes.isSuccess, true);

      final fetchRes = await repository.getPreferences(userId: 'user_A');
      expect(fetchRes.isSuccess, true);
      expect(fetchRes.dataOrNull?.safetyEnabled, false);
      expect(fetchRes.dataOrNull?.soundEnabled, true);
    });
  });

  group('3. NotificationService Facade & Throttling Tests', () {
    late SqliteNotificationRepository repository;

    setUp(() async {
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
      repository = SqliteNotificationRepository();
    });

    test('Notification Throttling suppresses duplicate alerts within cooldown', () async {
      final notif1 = await NotificationService.instance.notify(
        title: 'Overspeed',
        body: 'Speed > 80 km/h',
        type: NotificationType.safety,
        throttleCooldown: const Duration(seconds: 10),
        userId: 'user_A',
      );
      expect(notif1.dataOrNull, isNotNull);

      // Immediate second call should be throttled (returns null)
      final notif2 = await NotificationService.instance.notify(
        title: 'Overspeed',
        body: 'Speed > 80 km/h',
        type: NotificationType.safety,
        throttleCooldown: const Duration(seconds: 10),
        userId: 'user_A',
      );
      expect(notif2.dataOrNull, isNull);
    });

    test('Emergency alerts bypass category suppression and lock ON', () async {
      final notif = await NotificationService.instance.notifyEmergency(
        title: 'SOS Active',
        body: 'Rider emergency active',
      );
      expect(notif.isSuccess, true);
      expect(notif.dataOrNull?.type, NotificationType.emergency);
      expect(notif.dataOrNull?.route, '/safety/tracking');
    });
  });

  group('4. NotificationController State Machine Tests', () {
    test('NotificationController state, filter, mark all read', () async {
      final controller = NotificationController();
      await controller.loadNotifications();
      
      // Mark all read to test clear unread count
      await controller.markAllAsRead();
      expect(controller.unreadCount, 0);

      controller.setFilter(NotificationType.safety);
      expect(controller.selectedFilter, NotificationType.safety);

      controller.setUnreadOnlyFilter(true);
      expect(controller.unreadOnlyFilter, true);
      expect(controller.selectedFilter, isNull);

      controller.dispose();
    });
  });
}

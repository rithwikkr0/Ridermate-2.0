import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/core/sync/offline_sync_engine.dart';
import 'package:ridermate/core/services/live_location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Offline Sync & Live Location Unit Tests', () {
    late Database db;

    setUp(() async {
      db = await DatabaseService.instance.database;
      await db.execute('DROP TABLE IF EXISTS offline_sync_queue');
      await db.execute('DROP TABLE IF EXISTS live_location_sessions');

      await db.execute('''
        CREATE TABLE offline_sync_queue (
          id           TEXT PRIMARY KEY,
          user_id      TEXT NOT NULL,
          action_type  TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          status       TEXT NOT NULL DEFAULT 'pending',
          created_at   TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE live_location_sessions (
          id            TEXT PRIMARY KEY,
          user_id       TEXT NOT NULL,
          session_token TEXT NOT NULL UNIQUE,
          expires_at    TEXT NOT NULL,
          created_at    TEXT NOT NULL,
          stopped_at    TEXT,
          is_active     INTEGER NOT NULL DEFAULT 1
        )
      ''');
    });

    test('OfflineSyncEngine queues actions and updates pending count', () async {
      final engine = OfflineSyncEngine(dbService: DatabaseService.instance);

      final queueRes = await engine.queueAction(
        userId: 'user_123',
        actionType: 'post_create',
        payload: {'caption': 'Epic ride to Nandi Hills'},
      );

      expect(queueRes.isSuccess, isTrue);
      final count = await engine.refreshPendingCount();
      expect(count, equals(1));
    });

    test('LiveLocationService starts and stops sharing sessions', () async {
      final liveService = LiveLocationService(dbService: DatabaseService.instance);

      final startRes = await liveService.startSharing(
        userId: 'user_123',
        duration: const Duration(minutes: 15),
      );

      expect(startRes.isSuccess, isTrue);
      expect(liveService.isSharing, isTrue);
      expect(liveService.shareableUrl, contains('https://ridermate.app/live/'));

      final stopRes = await liveService.stopSharing();
      expect(stopRes.isSuccess, isTrue);
      expect(liveService.isSharing, isFalse);
    });
  });
}

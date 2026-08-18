import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ridermate/core/network/azure_api_client.dart';
import 'package:ridermate/core/sync/offline_sync_engine.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/core/config/env_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('AzureApiClient Production Tests', () {
    test('checkHealth returns success when 200 OK', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/health')) {
          return http.Response(
            jsonEncode({'status': 'healthy', 'service': 'RiderMate 2.0 API'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = AzureApiClient(
        client: mockClient,
        config: const EnvConfig(
          environment: Environment.dev,
          apiBaseUrl: 'http://mock.test/api',
          azureApiBaseUrl: 'http://mock.test/api',
          mapTileServerUrl: 'http://mock.test',
        ),
      );

      final result = await client.checkHealth();
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?['status'], equals('healthy'));
    });

    test('createPost sends x-idempotency-key and payload correctly', () async {
      String? capturedIdemKey;
      Map<String, dynamic>? capturedBody;

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/community/posts')) {
          capturedIdemKey = request.headers['x-idempotency-key'];
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'id': 'post_cloud_123',
              'caption': capturedBody?['caption'],
              'type': capturedBody?['type'],
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = AzureApiClient(
        client: mockClient,
        config: const EnvConfig(
          environment: Environment.dev,
          apiBaseUrl: 'http://mock.test/api',
          azureApiBaseUrl: 'http://mock.test/api',
          mapTileServerUrl: 'http://mock.test',
        ),
      );

      final result = await client.createPost(
        type: 'text',
        caption: 'Morning highway cruise!',
        authToken: 'jwt_mock_token',
        idempotencyKey: 'idem_key_unique_999',
      );

      expect(result.isSuccess, isTrue);
      expect(capturedIdemKey, equals('idem_key_unique_999'));
      expect(capturedBody?['caption'], equals('Morning highway cruise!'));
    });
  });

  group('OfflineSyncEngine Integration Tests', () {
    late Database db;
    late DatabaseService dbService;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE offline_sync_queue (
              id               TEXT PRIMARY KEY,
              user_id          TEXT NOT NULL,
              action_type      TEXT NOT NULL,
              payload_json     TEXT NOT NULL,
              status           TEXT NOT NULL DEFAULT 'pending',
              created_at       TEXT NOT NULL,
              idempotency_key  TEXT NOT NULL DEFAULT '',
              retry_count      INTEGER NOT NULL DEFAULT 0,
              last_attempt_at  TEXT NOT NULL DEFAULT '',
              error_message    TEXT NOT NULL DEFAULT ''
            )
          ''');
        },
      );
      dbService = DatabaseService.forTesting(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('queues mutation and flushes to mock Azure API with idempotency key', () async {
      bool apiCalled = false;
      String? sentIdemKey;

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/community/posts')) {
          apiCalled = true;
          sentIdemKey = request.headers['x-idempotency-key'];
          return http.Response(
            jsonEncode({'id': 'post_cloud_555'}),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = AzureApiClient(
        client: mockClient,
        config: const EnvConfig(
          environment: Environment.dev,
          apiBaseUrl: 'http://mock.test/api',
          azureApiBaseUrl: 'http://mock.test/api',
          mapTileServerUrl: 'http://mock.test',
        ),
      );

      final syncEngine = OfflineSyncEngine(
        apiClient: apiClient,
        dbService: dbService,
      );

      // 1. Queue offline action
      final queueRes = await syncEngine.queueAction(
        userId: 'user_001',
        actionType: 'create_post',
        payload: {'type': 'text', 'caption': 'Offline post!'},
        idempotencyKey: 'idem_custom_post_001',
      );
      expect(queueRes.isSuccess, isTrue);
      expect(syncEngine.pendingCount, equals(1));

      // 2. Flush queue
      final flushRes = await syncEngine.flushQueue(authToken: 'test_token');
      expect(flushRes.isSuccess, isTrue);
      expect(flushRes.dataOrNull, equals(1));
      expect(apiCalled, isTrue);
      expect(sentIdemKey, equals('idem_custom_post_001'));
      expect(syncEngine.pendingCount, equals(0));

      // 3. Verify SQLite record is marked as synced
      final rows = await db.query('offline_sync_queue');
      expect(rows.length, equals(1));
      expect(rows[0]['status'], equals('synced'));
    });

    test('increments retry count on network failure without deleting record', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiClient = AzureApiClient(
        client: mockClient,
        config: const EnvConfig(
          environment: Environment.dev,
          apiBaseUrl: 'http://mock.test/api',
          azureApiBaseUrl: 'http://mock.test/api',
          mapTileServerUrl: 'http://mock.test',
        ),
      );

      final syncEngine = OfflineSyncEngine(
        apiClient: apiClient,
        dbService: dbService,
      );

      // Queue action
      await syncEngine.queueAction(
        userId: 'user_002',
        actionType: 'like_post',
        payload: {'post_id': 'post_100'},
      );

      // Flush queue -> should fail gracefully
      final flushRes = await syncEngine.flushQueue(authToken: 'test_token');
      expect(flushRes.isSuccess, isTrue);
      expect(flushRes.dataOrNull, equals(0)); // 0 items synced

      // Verify SQLite record is marked as failed with retry_count = 1
      final rows = await db.query('offline_sync_queue');
      expect(rows.length, equals(1));
      expect(rows[0]['status'], equals('failed'));
      expect(rows[0]['retry_count'], equals(1));
    });
  });
}

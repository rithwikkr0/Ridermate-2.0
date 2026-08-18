import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/core/gamification/sqlite_gamification_repository.dart';

void main() {
  late SqliteGamificationRepository repository;
  late Database mockDb;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Using an in-memory database for testing
    mockDb = await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(
      version: 11,
      onCreate: (db, version) async {
        // Mock user table
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            username TEXT,
            full_name TEXT,
            xp INTEGER DEFAULT 0,
            rider_level TEXT DEFAULT 'Novice'
          )
        ''');
        
        await db.insert('users', {
          'id': 'test_user_1',
          'username': 'testuser',
          'full_name': 'Test User',
          'xp': 0,
        });

        // Add Gamification tables manually since we're using raw db creation for testing
        await db.execute('''
          CREATE TABLE xp_events (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            event_type TEXT,
            xp_amount INTEGER,
            reference_id TEXT,
            created_at TEXT,
            UNIQUE(user_id, event_type, reference_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE achievements (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            type TEXT,
            title TEXT,
            description TEXT,
            xp_reward INTEGER,
            icon TEXT,
            unlocked_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE challenges (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            type TEXT,
            target_value REAL,
            xp_reward INTEGER,
            start_date TEXT,
            end_date TEXT,
            is_active INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE user_challenges (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            challenge_id TEXT,
            progress REAL DEFAULT 0.0,
            status TEXT DEFAULT 'active',
            started_at TEXT,
            completed_at TEXT,
            UNIQUE(user_id, challenge_id)
          )
        ''');
      }
    ));
    
    // Inject the mock db directly if possible, or use a custom dbService.
    repository = SqliteGamificationRepository(dbService: _MockDatabaseService(mockDb));
  });

  test('XP awarding works and calculates correct level', () async {
    await repository.awardXP('test_user_1', 'TEST_EVENT', 500, 'ref_1');
    
    final xpResult = await repository.getUserXP('test_user_1');
    expect(xpResult.isSuccess, isTrue);
    expect(xpResult.dataOrNull, 500);
    
    final levelResult = await repository.getUserLevel('test_user_1');
    expect(levelResult.isSuccess, isTrue);
    expect(levelResult.dataOrNull, 'Explorer'); // 500 XP is Explorer
  });

  test('Double-award prevention works', () async {
    final res1 = await repository.awardXP('test_user_1', 'RIDE_EVENT_2', 100, 'ride_2');
    expect(res1.isSuccess, isTrue);
    expect(res1.dataOrNull, isTrue);

    final res2 = await repository.awardXP('test_user_1', 'RIDE_EVENT_2', 100, 'ride_2');
    expect(res2.isSuccess, isTrue);
    expect(res2.dataOrNull, isFalse); // Should be false because of UNIQUE constraint

    final xpResult = await repository.getUserXP('test_user_1');
    expect(xpResult.dataOrNull, 600); // 500 from first test + 100 from this test
  });

  test('Challenge progress updates correctly', () async {
    await mockDb.insert('challenges', {
      'id': 'chal_1',
      'title': 'Test Challenge',
      'description': 'Test',
      'type': 'rides',
      'target_value': 3.0,
      'xp_reward': 200,
      'start_date': DateTime.now().toIso8601String(),
      'end_date': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      'is_active': 1,
    });

    final res1 = await repository.updateChallengeProgress('test_user_1', 'chal_1', 1.0);
    expect(res1.isSuccess, isTrue);
    expect(res1.dataOrNull, isFalse); // Not completed yet

    final res2 = await repository.updateChallengeProgress('test_user_1', 'chal_1', 3.0);
    expect(res2.isSuccess, isTrue);
    expect(res2.dataOrNull, isTrue); // Completed!
  });
}

class _MockDatabaseService implements DatabaseService {
  final Database _db;
  _MockDatabaseService(this._db);
  
  @override
  Future<Database> get database async => _db;
  
  // Ignore other overrides for the mock
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/features/community/repositories/sqlite_friend_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
  });

  group('Friends & Community System Tests', () {
    late SqliteFriendRepository repo;

    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('DROP TABLE IF EXISTS friendships');
      await db.execute('DROP TABLE IF EXISTS friend_requests');
      await db.execute('DROP TABLE IF EXISTS users');

      await db.execute('''
        CREATE TABLE users (
          id         TEXT PRIMARY KEY,
          email      TEXT NOT NULL,
          username   TEXT NOT NULL,
          full_name  TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE friendships (
          id         TEXT PRIMARY KEY,
          user_id    TEXT NOT NULL,
          friend_id  TEXT NOT NULL,
          status     TEXT NOT NULL DEFAULT 'accepted',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE friend_requests (
          id          TEXT PRIMARY KEY,
          sender_id   TEXT NOT NULL,
          receiver_id TEXT NOT NULL,
          status      TEXT NOT NULL DEFAULT 'pending',
          created_at  TEXT NOT NULL
        )
      ''');

      // Populate dummy users
      final now = DateTime.now().toIso8601String();
      await db.insert('users', {'id': 'user_A', 'email': 'a@test.com', 'username': 'alex_r', 'full_name': 'Alex Rivera', 'created_at': now});
      await db.insert('users', {'id': 'user_B', 'email': 'b@test.com', 'username': 'sarah_c', 'full_name': 'Sarah Chen', 'created_at': now});
      await db.insert('users', {'id': 'user_C', 'email': 'c@test.com', 'username': 'rahul_k', 'full_name': 'Rahul Kumar', 'created_at': now});

      repo = SqliteFriendRepository();
    });

    test('1. Send friend request creates pending request for receiver', () async {
      final sendRes = await repo.sendFriendRequest(senderId: 'user_A', receiverId: 'user_B');
      expect(sendRes.isSuccess, true);

      final reqs = (await repo.getPendingRequests(userId: 'user_B')).dataOrNull!;
      expect(reqs.length, 1);
      expect(reqs.first.senderId, 'user_A');
      expect(reqs.first.senderName, 'Alex Rivera');
    });

    test('2. Accept friend request creates bidirectional accepted friendship', () async {
      await repo.sendFriendRequest(senderId: 'user_A', receiverId: 'user_B');
      final reqs = (await repo.getPendingRequests(userId: 'user_B')).dataOrNull!;
      final reqId = reqs.first.id;

      final acceptRes = await repo.acceptFriendRequest(requestId: reqId, userId: 'user_B');
      expect(acceptRes.isSuccess, true);

      final friendsA = (await repo.getFriends(userId: 'user_A')).dataOrNull!;
      final friendsB = (await repo.getFriends(userId: 'user_B')).dataOrNull!;

      expect(friendsA.length, 1);
      expect(friendsA.first.friendId, 'user_B');
      expect(friendsA.first.fullName, 'Sarah Chen');

      expect(friendsB.length, 1);
      expect(friendsB.first.friendId, 'user_A');
      expect(friendsB.first.fullName, 'Alex Rivera');
    });

    test('3. Search users excludes current user and filters by term', () async {
      final searchRes = await repo.searchUsers(query: 'rahul', currentUserId: 'user_A');
      expect(searchRes.isSuccess, true);
      expect(searchRes.dataOrNull?.length, 1);
      expect(searchRes.dataOrNull?.first['username'], 'rahul_k');

      final searchSelf = await repo.searchUsers(query: 'alex', currentUserId: 'user_A');
      expect(searchSelf.dataOrNull?.isEmpty, true);
    });

    test('4. Remove friend cleans up friendship record', () async {
      await repo.sendFriendRequest(senderId: 'user_A', receiverId: 'user_B');
      final reqs = (await repo.getPendingRequests(userId: 'user_B')).dataOrNull!;
      await repo.acceptFriendRequest(requestId: reqs.first.id, userId: 'user_B');

      final remRes = await repo.removeFriend(userId: 'user_A', friendId: 'user_B');
      expect(remRes.isSuccess, true);

      final friendsA = (await repo.getFriends(userId: 'user_A')).dataOrNull!;
      expect(friendsA.isEmpty, true);
    });
  });
}

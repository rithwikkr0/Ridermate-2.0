import 'package:sqflite/sqflite.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../../../core/services/database_service.dart';
import '../models/squad_model.dart';

abstract class SquadRepository {
  Future<Result<SquadModel>> createSquad(SquadModel squad, {required String creatorId});
  Future<Result<List<SquadModel>>> getSquads({required String currentUserId});
  Future<Result<SquadModel?>> getSquadById(String squadId, {required String currentUserId});
  Future<Result<bool>> joinSquad({required String squadId, required String userId, String? inviteCode});
  Future<Result<bool>> leaveSquad({required String squadId, required String userId});
  Future<Result<List<SquadMemberModel>>> getSquadMembers(String squadId);
  Future<Result<GroupRideModel>> createGroupRide(GroupRideModel ride);
  Future<Result<List<GroupRideModel>>> getGroupRides({String? squadId, required String currentUserId});
  Future<Result<bool>> joinGroupRide({required String groupRideId, required String userId});
  Future<Result<bool>> leaveGroupRide({required String groupRideId, required String userId});
  Future<Result<bool>> updateGroupRideLocation({
    required String groupRideId,
    required String userId,
    required double lat,
    required double lng,
    required bool isSharing,
  });
}

/// RiderMate 2.0 — Production-Grade SQLite Squad & Group Ride Repository
class SqliteSquadRepository implements SquadRepository {
  final DatabaseService _dbService;

  SqliteSquadRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db async => await _dbService.database;

  @override
  Future<Result<SquadModel>> createSquad(SquadModel squad, {required String creatorId}) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        await txn.insert('squads', squad.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

        // Add creator as owner member
        final memberId = 'sm_${DateTime.now().millisecondsSinceEpoch}_$creatorId';
        await txn.insert('squad_members', {
          'id': memberId,
          'squad_id': squad.id,
          'user_id': creatorId,
          'role': 'owner',
          'joined_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        return Result.success(squad.copyWith(isMember: true, role: 'owner'));
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to create squad: $e'));
    }
  }

  @override
  Future<Result<List<SquadModel>>> getSquads({required String currentUserId}) async {
    try {
      final db = await _db;
      final squadRows = await db.query('squads', orderBy: 'member_count DESC');

      final List<SquadModel> squads = [];
      for (final row in squadRows) {
        final squadId = row['id'] as String;
        final memRows = await db.query(
          'squad_members',
          where: 'squad_id = ? AND user_id = ?',
          whereArgs: [squadId, currentUserId],
          limit: 1,
        );

        final isMember = memRows.isNotEmpty;
        final role = isMember ? (memRows.first['role'] as String? ?? 'member') : 'none';

        squads.add(SquadModel.fromMap(row, isMember: isMember, role: role));
      }

      return Result.success(squads);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch squads: $e'));
    }
  }

  @override
  Future<Result<SquadModel?>> getSquadById(String squadId, {required String currentUserId}) async {
    try {
      final db = await _db;
      final rows = await db.query('squads', where: 'id = ?', whereArgs: [squadId], limit: 1);
      if (rows.isEmpty) return Result.success(null);

      final memRows = await db.query(
        'squad_members',
        where: 'squad_id = ? AND user_id = ?',
        whereArgs: [squadId, currentUserId],
        limit: 1,
      );

      final isMember = memRows.isNotEmpty;
      final role = isMember ? (memRows.first['role'] as String? ?? 'member') : 'none';

      return Result.success(SquadModel.fromMap(rows.first, isMember: isMember, role: role));
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch squad: $e'));
    }
  }

  @override
  Future<Result<bool>> joinSquad({
    required String squadId,
    required String userId,
    String? inviteCode,
  }) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        final squadRows = await txn.query('squads', where: 'id = ?', whereArgs: [squadId], limit: 1);
        if (squadRows.isEmpty) return Result.failure(ValidationError('Squad does not exist'));

        final squad = squadRows.first;
        final isPrivate = (squad['is_private'] == 1 || squad['is_private'] == true);
        if (isPrivate && (inviteCode == null || inviteCode.trim() != squad['invite_code'])) {
          return Result.failure(const ValidationError('Invalid squad invite code'));
        }

        final memberId = 'sm_${DateTime.now().millisecondsSinceEpoch}_$userId';
        await txn.insert('squad_members', {
          'id': memberId,
          'squad_id': squadId,
          'user_id': userId,
          'role': 'member',
          'joined_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        // Update member count
        final count = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM squad_members WHERE squad_id = ?',
          [squadId],
        )) ?? 1;

        await txn.update('squads', {'member_count': count}, where: 'id = ?', whereArgs: [squadId]);
        return Result.success(true);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to join squad: $e'));
    }
  }

  @override
  Future<Result<bool>> leaveSquad({required String squadId, required String userId}) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        await txn.delete(
          'squad_members',
          where: 'squad_id = ? AND user_id = ?',
          whereArgs: [squadId, userId],
        );

        final count = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM squad_members WHERE squad_id = ?',
          [squadId],
        )) ?? 0;

        await txn.update('squads', {'member_count': count}, where: 'id = ?', whereArgs: [squadId]);
        return Result.success(true);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to leave squad: $e'));
    }
  }

  @override
  Future<Result<List<SquadMemberModel>>> getSquadMembers(String squadId) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'squad_members',
        where: 'squad_id = ?',
        whereArgs: [squadId],
        orderBy: 'role ASC, joined_at ASC',
      );

      final List<SquadMemberModel> members = [];
      for (final r in rows) {
        final uid = r['user_id'] as String;
        final uRows = await db.query('users', where: 'id = ?', whereArgs: [uid], limit: 1);
        final userMap = uRows.isNotEmpty ? uRows.first : null;
        members.add(SquadMemberModel.fromMap(r, userMap: userMap));
      }

      return Result.success(members);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch squad members: $e'));
    }
  }

  @override
  Future<Result<GroupRideModel>> createGroupRide(GroupRideModel ride) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        await txn.insert('group_rides', ride.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

        final memberId = 'grm_${DateTime.now().millisecondsSinceEpoch}_${ride.creatorId}';
        await txn.insert('group_ride_members', {
          'id': memberId,
          'group_ride_id': ride.id,
          'user_id': ride.creatorId,
          'status': 'joined',
          'is_sharing_location': 1,
          'last_updated': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        return Result.success(ride);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to create group ride: $e'));
    }
  }

  @override
  Future<Result<List<GroupRideModel>>> getGroupRides({
    String? squadId,
    required String currentUserId,
  }) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> rows;
      if (squadId != null && squadId.isNotEmpty) {
        rows = await db.query(
          'group_rides',
          where: 'squad_id = ?',
          whereArgs: [squadId],
          orderBy: 'start_time ASC',
        );
      } else {
        rows = await db.query('group_rides', orderBy: 'start_time ASC');
      }

      final List<GroupRideModel> rides = [];
      for (final r in rows) {
        final rideId = r['id'] as String;
        final creatorId = r['creator_id'] as String;

        // Fetch creator name
        final uRows = await db.query('users', where: 'id = ?', whereArgs: [creatorId], limit: 1);
        final creatorName = uRows.isNotEmpty
            ? (uRows.first['full_name'] as String? ?? uRows.first['username'] as String? ?? 'Leader')
            : 'Leader';

        // Count members
        final memberCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM group_ride_members WHERE group_ride_id = ? AND status = ?',
          [rideId, 'joined'],
        )) ?? 1;

        // Check if current user is member
        final myMemberRows = await db.query(
          'group_ride_members',
          where: 'group_ride_id = ? AND user_id = ?',
          whereArgs: [rideId, currentUserId],
          limit: 1,
        );

        final isJoined = myMemberRows.isNotEmpty && myMemberRows.first['status'] == 'joined';
        final isSharing = isJoined && (myMemberRows.first['is_sharing_location'] == 1);

        rides.add(GroupRideModel.fromMap(
          r,
          creatorName: creatorName,
          memberCount: memberCount,
          isJoined: isJoined,
          isSharingLocation: isSharing,
        ));
      }

      return Result.success(rides);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch group rides: $e'));
    }
  }

  @override
  Future<Result<bool>> joinGroupRide({required String groupRideId, required String userId}) async {
    try {
      final db = await _db;
      final memberId = 'grm_${DateTime.now().millisecondsSinceEpoch}_$userId';
      await db.insert('group_ride_members', {
        'id': memberId,
        'group_ride_id': groupRideId,
        'user_id': userId,
        'status': 'joined',
        'is_sharing_location': 0,
        'last_updated': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to join group ride: $e'));
    }
  }

  @override
  Future<Result<bool>> leaveGroupRide({required String groupRideId, required String userId}) async {
    try {
      final db = await _db;
      await db.delete(
        'group_ride_members',
        where: 'group_ride_id = ? AND user_id = ?',
        whereArgs: [groupRideId, userId],
      );
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to leave group ride: $e'));
    }
  }

  @override
  Future<Result<bool>> updateGroupRideLocation({
    required String groupRideId,
    required String userId,
    required double lat,
    required double lng,
    required bool isSharing,
  }) async {
    try {
      final db = await _db;
      await db.update(
        'group_ride_members',
        {
          'is_sharing_location': isSharing ? 1 : 0,
          'last_latitude': lat,
          'last_longitude': lng,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'group_ride_id = ? AND user_id = ?',
        whereArgs: [groupRideId, userId],
      );
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to update group ride location: $e'));
    }
  }
}

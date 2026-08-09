import 'package:sqflite/sqflite.dart';

import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/database_service.dart';
import '../models/ride_engine_model.dart';
import '../models/route_model.dart';
import 'ride_repository.dart';

/// Real SQLite-backed ride repository.
/// Uses the shared [DatabaseService] singleton (ridermate.db).
/// Tables are managed by [DatabaseService._onCreate] / [_onUpgrade].
class SqliteRideRepository implements RideRepository {
  Future<Database> get _db async => DatabaseService.instance.database;

  @override
  Future<Result<RideEngineModel>> save(RideEngineModel ride) async {
    try {
      final db = await _db;
      await db.transaction((txn) async {
        await txn.insert(
          'rides',
          {
            'id': ride.id,
            'title': ride.title,
            'vehicle': ride.vehicle,
            'start_time': ride.startTime.millisecondsSinceEpoch,
            'end_time': ride.endTime?.millisecondsSinceEpoch,
            'duration_seconds': ride.duration.inSeconds,
            'distance_km': ride.distanceKm,
            'average_speed': ride.averageSpeedKmh,
            'max_speed': ride.maxSpeedKmh,
            'elevation': ride.elevationMeters,
            'calories': ride.caloriesBurned,
            'weather': ride.weather,
            'ride_score': ride.rideScore,
            'status': ride.status.name,
            'ride_mode': ride.rideMode,
            'user_id': ride.userId,
            'origin': ride.origin,
            'destination': ride.destination,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Delete any existing points for this ride first
        await txn.delete('ride_points', where: 'ride_id = ?', whereArgs: [ride.id]);

        // Batch-insert all GPS points
        final batch = txn.batch();
        for (var i = 0; i < ride.routePoints.length; i++) {
          final p = ride.routePoints[i];
          batch.insert('ride_points', {
            'ride_id': ride.id,
            'point_index': i,
            'latitude': p.latitude,
            'longitude': p.longitude,
            'speed': p.speedKmh,
            'timestamp': p.timestamp,
            'elevation': p.elevationMeters,
            'heading': p.headingDegrees,
            'accuracy': p.accuracyMeters,
          });
        }
        await batch.commit(noResult: true);
      });
      return Result.success(ride);
    } catch (e) {
      return Result.failure(StorageError('Unable to save ride: $e'));
    }
  }

  Future<RideEngineModel> _hydrate(Map<String, Object?> row) async {
    final db = await _db;
    final pointRows = await db.query(
      'ride_points',
      where: 'ride_id = ?',
      whereArgs: [row['id']],
      orderBy: 'point_index',
    );
    final points = pointRows
        .map(
          (p) => RoutePoint(
            latitude: (p['latitude'] as num).toDouble(),
            longitude: (p['longitude'] as num).toDouble(),
            speedKmh: (p['speed'] as num).toDouble(),
            timestamp: p['timestamp'] as int,
            elevationMeters: (p['elevation'] as num).toDouble(),
            headingDegrees: (p['heading'] as num).toDouble(),
            accuracyMeters: (p['accuracy'] as num).toDouble(),
          ),
        )
        .toList();

    // Parse RideStatus — handle old data gracefully
    RideStatus status;
    try {
      final rawStatus = row['status'] as String? ?? 'completed';
      // Map legacy 'running' → 'active' for backwards compat
      final normalised = rawStatus == 'running' ? 'active' : rawStatus;
      status = RideStatus.values.byName(normalised);
    } catch (_) {
      status = RideStatus.completed;
    }

    return RideEngineModel(
      id: row['id'] as String,
      userId: row['user_id'] as String? ?? '',
      title: row['title'] as String,
      rideMode: row['ride_mode'] as String? ?? 'solo',
      origin: row['origin'] as String? ?? '',
      destination: row['destination'] as String? ?? '',
      vehicle: row['vehicle'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(row['start_time'] as int),
      endTime: row['end_time'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row['end_time'] as int),
      duration: Duration(seconds: row['duration_seconds'] as int),
      distanceKm: (row['distance_km'] as num).toDouble(),
      averageSpeedKmh: (row['average_speed'] as num).toDouble(),
      maxSpeedKmh: (row['max_speed'] as num).toDouble(),
      elevationMeters: (row['elevation'] as num).toDouble(),
      caloriesBurned: row['calories'] as int,
      weather: row['weather'] as String,
      routePoints: points,
      rideScore: row['ride_score'] as int,
      status: status,
    );
  }

  @override
  Future<Result<List<RideEngineModel>>> getAll() async {
    try {
      final db = await _db;
      final rows = await db.query('rides', orderBy: 'start_time DESC');
      final rides = await Future.wait(rows.map(_hydrate));
      return Result.success(rides);
    } catch (e) {
      return Result.failure(StorageError('Unable to load rides: $e'));
    }
  }

  @override
  Future<Result<RideEngineModel?>> getById(String id) async {
    try {
      final db = await _db;
      final rows = await db.query('rides', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) return Result.success(null);
      return Result.success(await _hydrate(rows.first));
    } catch (e) {
      return Result.failure(StorageError('Unable to load ride: $e'));
    }
  }

  @override
  Future<Result<bool>> delete(String id) async {
    try {
      final db = await _db;
      await db.transaction((txn) async {
        await txn.delete('ride_points', where: 'ride_id = ?', whereArgs: [id]);
        await txn.delete('rides', where: 'id = ?', whereArgs: [id]);
      });
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Unable to delete ride: $e'));
    }
  }

  @override
  Future<Result<List<RideEngineModel>>> getHistory({
    String? query,
    String? filter,
    int page = 1,
    int pageSize = 20,
  }) =>
      getAll();

  Future<void> clearRides() async {
    final db = await _db;
    await db.delete('ride_points');
    await db.delete('rides');
  }
}

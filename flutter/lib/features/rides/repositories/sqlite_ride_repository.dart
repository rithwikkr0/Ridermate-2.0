import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../models/ride_engine_model.dart';
import '../models/route_model.dart';
import 'ride_repository.dart';

class SqliteRideRepository implements RideRepository {
  Database? _database;

  Future<Database> get _db async => _database ??= await openDatabase(
        join(await getDatabasesPath(), 'ridermate.db'), version: 1,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE rides (id TEXT PRIMARY KEY, title TEXT, vehicle TEXT, start_time INTEGER, end_time INTEGER, duration_seconds INTEGER, distance_km REAL, average_speed REAL, max_speed REAL, elevation REAL, calories INTEGER, weather TEXT, ride_score INTEGER, status TEXT)');
          await db.execute('CREATE TABLE ride_points (ride_id TEXT, point_index INTEGER, latitude REAL, longitude REAL, speed REAL, timestamp INTEGER, elevation REAL, heading REAL, accuracy REAL, PRIMARY KEY (ride_id, point_index))');
        },
      );

  @override
  Future<Result<RideEngineModel>> save(RideEngineModel ride) async {
    try {
      final db = await _db;
      await db.transaction((txn) async {
        await txn.insert('rides', {'id': ride.id, 'title': ride.title, 'vehicle': ride.vehicle, 'start_time': ride.startTime.millisecondsSinceEpoch, 'end_time': ride.endTime?.millisecondsSinceEpoch, 'duration_seconds': ride.duration.inSeconds, 'distance_km': ride.distanceKm, 'average_speed': ride.averageSpeedKmh, 'max_speed': ride.maxSpeedKmh, 'elevation': ride.elevationMeters, 'calories': ride.caloriesBurned, 'weather': ride.weather, 'ride_score': ride.rideScore, 'status': ride.status.name}, conflictAlgorithm: ConflictAlgorithm.replace);
        await txn.delete('ride_points', where: 'ride_id = ?', whereArgs: [ride.id]);
        final batch = txn.batch();
        for (var i = 0; i < ride.routePoints.length; i++) {
          final p = ride.routePoints[i];
          batch.insert('ride_points', {'ride_id': ride.id, 'point_index': i, 'latitude': p.latitude, 'longitude': p.longitude, 'speed': p.speedKmh, 'timestamp': p.timestamp, 'elevation': p.elevationMeters, 'heading': p.headingDegrees, 'accuracy': p.accuracyMeters});
        }
        await batch.commit(noResult: true);
      });
      return Result.success(ride);
    } catch (e) { return Result.failure(StorageError('Unable to save ride: $e')); }
  }

  Future<RideEngineModel> _hydrate(Map<String, Object?> row) async {
    final points = await (await _db).query('ride_points', where: 'ride_id = ?', whereArgs: [row['id']], orderBy: 'point_index').then((rows) => rows.map((p) => RoutePoint(latitude: p['latitude'] as double, longitude: p['longitude'] as double, speedKmh: p['speed'] as double, timestamp: p['timestamp'] as int, elevationMeters: p['elevation'] as double, headingDegrees: p['heading'] as double, accuracyMeters: p['accuracy'] as double)).toList());
    return RideEngineModel(id: row['id'] as String, title: row['title'] as String, vehicle: row['vehicle'] as String, startTime: DateTime.fromMillisecondsSinceEpoch(row['start_time'] as int), endTime: row['end_time'] == null ? null : DateTime.fromMillisecondsSinceEpoch(row['end_time'] as int), duration: Duration(seconds: row['duration_seconds'] as int), distanceKm: row['distance_km'] as double, averageSpeedKmh: row['average_speed'] as double, maxSpeedKmh: row['max_speed'] as double, elevationMeters: row['elevation'] as double, caloriesBurned: row['calories'] as int, weather: row['weather'] as String, routePoints: points, rideScore: row['ride_score'] as int, status: RideStatus.values.byName(row['status'] as String));
  }
  @override Future<Result<List<RideEngineModel>>> getAll() async { try { final rows = await (await _db).query('rides', orderBy: 'start_time DESC'); return Result.success(await Future.wait(rows.map(_hydrate))); } catch(e) { return Result.failure(StorageError('Unable to load rides: $e')); } }
  @override Future<Result<RideEngineModel?>> getById(String id) async { final rows=await (await _db).query('rides',where:'id = ?',whereArgs:[id]); return Result.success(rows.isEmpty ? null : await _hydrate(rows.first)); }
  @override Future<Result<bool>> delete(String id) async { try { final db=await _db; await db.transaction((t) async {await t.delete('ride_points',where:'ride_id = ?',whereArgs:[id]); await t.delete('rides',where:'id = ?',whereArgs:[id]);}); return Result.success(true); } catch(e){return Result.failure(StorageError('Unable to delete ride: $e'));} }
  @override Future<Result<List<RideEngineModel>>> getHistory({String? query, String? filter, int page=1, int pageSize=20}) => getAll();
  Future<void> clearRides() async { final db=await _db; await db.delete('ride_points'); await db.delete('rides'); }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../errors/result.dart';
import '../errors/app_error.dart';
import 'database_service.dart';

/// RiderMate 2.0 — Live Location Sharing Service
/// Manages time-limited (15/30/60 mins or duration of ride) sharing sessions.
/// Sessions are saved in SQLite `live_location_sessions` table.
class LiveLocationService extends ChangeNotifier {
  static final LiveLocationService instance = LiveLocationService._internal();
  factory LiveLocationService({DatabaseService? dbService}) =>
      LiveLocationService._internal(dbService: dbService);

  LiveLocationService._internal({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  final DatabaseService _dbService;

  bool _isSharing = false;
  String? _activeSessionToken;
  DateTime? _expiresAt;
  Timer? _expirationTimer;

  bool get isSharing => _isSharing;
  String? get activeSessionToken => _activeSessionToken;
  DateTime? get expiresAt => _expiresAt;

  /// Generates a live shareable URL token for emergency contacts or group riders.
  String get shareableUrl {
    if (_activeSessionToken == null) return '';
    return 'https://ridermate.app/live/$_activeSessionToken';
  }

  /// Starts a new live location sharing session.
  Future<Result<String>> startSharing({
    required String userId,
    Duration duration = const Duration(minutes: 30),
  }) async {
    try {
      final db = await _dbService.database;
      final sessionToken = 'live_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode.abs() & 0xFFFF}';
      final now = DateTime.now();
      final expiry = now.add(duration);

      final id = 'sess_${now.millisecondsSinceEpoch}';

      await db.insert('live_location_sessions', {
        'id': id,
        'user_id': userId,
        'session_token': sessionToken,
        'expires_at': expiry.toIso8601String(),
        'created_at': now.toIso8601String(),
        'is_active': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      _isSharing = true;
      _activeSessionToken = sessionToken;
      _expiresAt = expiry;

      _expirationTimer?.cancel();
      _expirationTimer = Timer(duration, () {
        stopSharing();
      });

      notifyListeners();
      return Result.success(sessionToken);
    } catch (e) {
      return Result.failure(StorageError('Failed to start live location session: $e'));
    }
  }

  /// Stops the current active live location sharing session.
  Future<Result<bool>> stopSharing() async {
    _expirationTimer?.cancel();
    _expirationTimer = null;

    if (_activeSessionToken == null) {
      _isSharing = false;
      notifyListeners();
      return Result.success(true);
    }

    try {
      final db = await _dbService.database;
      final now = DateTime.now().toIso8601String();

      await db.update(
        'live_location_sessions',
        {
          'is_active': 0,
          'stopped_at': now,
        },
        where: 'session_token = ?',
        whereArgs: [_activeSessionToken],
      );

      _isSharing = false;
      _activeSessionToken = null;
      _expiresAt = null;
      notifyListeners();
      return Result.success(true);
    } catch (e) {
      _isSharing = false;
      _activeSessionToken = null;
      notifyListeners();
      return Result.failure(StorageError('Failed to stop live location session: $e'));
    }
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    super.dispose();
  }
}

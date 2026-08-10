import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../models/sos_event_model.dart';
import '../repositories/emergency_repository.dart';

/// RiderMate 2.0 — Offline-First Emergency Firebase Cloud Sync Service
/// Uses HTTP REST layer for sync to ensure ₹0 overhead and offline resilience.
class EmergencySyncService {
  final EmergencyRepository _repository;
  final http.Client _httpClient;
  final String _firebaseRestEndpoint;

  EmergencySyncService({
    required EmergencyRepository repository,
    http.Client? httpClient,
    String? firebaseRestEndpoint,
  })  : _repository = repository,
        _httpClient = httpClient ?? http.Client(),
        _firebaseRestEndpoint = firebaseRestEndpoint ??
            'https://ridermate-2.firebaseio.com/sos_events';

  /// Syncs an individual SOS event to Cloud REST endpoint if online.
  Future<Result<bool>> syncSosEvent(SosEventModel event) async {
    try {
      final url = Uri.parse('$_firebaseRestEndpoint/${event.userId}/${event.id}.json');
      final response = await _httpClient.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toMap()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Result.success(true);
      } else {
        return Result.failure(NetworkError('Cloud sync failed with status ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(NetworkError('Cloud sync failed: $e'));
    }
  }

  /// Attempts batch sync of all pending SOS events for [userId].
  Future<Result<int>> syncPendingEvents({required String userId}) async {
    final eventsRes = await _repository.getSosEvents(userId: userId);
    if (!eventsRes.isSuccess || eventsRes.data == null) return Result.success(0);

    int syncedCount = 0;
    for (final event in eventsRes.data!) {
      final syncRes = await syncSosEvent(event);
      if (syncRes.isSuccess && syncRes.data == true) {
        syncedCount++;
      }
    }
    return Result.success(syncedCount);
  }
}

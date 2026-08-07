import 'dart:async';
import '../errors/result.dart';

enum SyncState { idle, syncing, offline, error }

class PendingRequest {
  final String id;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const PendingRequest({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
  });
}

/// RiderMate 2.0 — Offline-First Request Queue & Sync Manager
class OfflineSyncManager {
  final List<PendingRequest> _queue = [];
  bool isOnline = true;
  SyncState state = SyncState.idle;

  List<PendingRequest> get pendingRequests => List.unmodifiable(_queue);

  void enqueueRequest(String endpoint, String method, Map<String, dynamic> payload) {
    _queue.add(PendingRequest(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}-${_queue.length}',
      endpoint: endpoint,
      method: method,
      payload: payload,
      createdAt: DateTime.now(),
    ));
  }

  Future<Result<int>> processQueue() async {
    if (!isOnline || _queue.isEmpty) {
      return Result.success(0);
    }

    state = SyncState.syncing;
    int syncedCount = 0;

    final List<PendingRequest> toProcess = List.from(_queue);
    for (final req in toProcess) {
      await Future.delayed(const Duration(milliseconds: 100));
      _queue.remove(req);
      syncedCount++;
    }

    state = SyncState.idle;
    return Result.success(syncedCount);
  }

  void clearQueue() => _queue.clear();
}

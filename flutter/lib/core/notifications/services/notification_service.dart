import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../errors/result.dart';
import '../../services/shared_preferences_storage_service.dart';
import '../models/app_notification.dart';
import '../models/notification_preferences.dart';
import '../models/notification_type.dart';
import '../repositories/notification_repository.dart';
import 'local_notification_service.dart';

/// RiderMate 2.0 — Central Unified Notification Platform API Service
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal()
      : _repository = SqliteNotificationRepository(),
        _localService = LocalNotificationService(),
        _storageService = SharedPreferencesStorageService();

  final NotificationRepository _repository;
  final LocalNotificationService _localService;
  final SharedPreferencesStorageService _storageService;

  // Throttling / deduplication cooldown timers map (key: string key, value: DateTime lastTriggered)
  final Map<String, DateTime> _cooldowns = {};

  final StreamController<AppNotification> _notificationStreamController =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get notificationStream => _notificationStreamController.stream;

  /// Initializes the centralized notification platform.
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    await _localService.initialize(onNotificationTap: onNotificationTap);
  }

  Future<String> _getUserId() async {
    try {
      return (await _storageService.getString('user_id')) ?? 'user_guest';
    } catch (_) {
      return 'user_guest';
    }
  }

  /// Central API method to dispatch any notification in RiderMate 2.0.
  Future<Result<AppNotification?>> notify({
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? route,
    String? entityId,
    Map<String, dynamic>? payload,
    String? imageUrl,
    Duration? throttleCooldown,
    String? userId,
  }) async {
    final uid = userId ?? await _getUserId();

    // 1. Throttling / Deduplication Check
    final throttleKey = '${uid}_${type.name}_${entityId ?? title}';
    if (throttleCooldown != null && _cooldowns.containsKey(throttleKey)) {
      final lastTime = _cooldowns[throttleKey]!;
      if (DateTime.now().difference(lastTime) < throttleCooldown) {
        // Throttled / suppressed duplicate
        return Result.success(null);
      }
    }

    // 2. Preferences Check
    final prefsRes = await _repository.getPreferences(userId: uid);
    final prefs = prefsRes.dataOrNull ?? NotificationPreferences(userId: uid);

    if (!prefs.isCategoryEnabled(type)) {
      // Category disabled by user in settings
      return Result.success(null);
    }

    // 3. Create Canonical AppNotification Record
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${title.hashCode & 0xFFFF}',
      userId: uid,
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      route: route,
      entityId: entityId,
      priority: priority,
      payload: payload,
      imageUrl: imageUrl,
    );

    // 4. Save to Local SQLite History
    await _repository.saveNotification(notification);

    // 5. Display Android Local System Notification
    await _localService.showNotification(
      notification,
      playSound: prefs.soundEnabled,
      vibrate: prefs.vibrationEnabled,
    );

    // 6. Record Throttle Timestamp
    if (throttleCooldown != null) {
      _cooldowns[throttleKey] = DateTime.now();
    }

    // 7. Emit to Reactive Broadcast Stream
    _notificationStreamController.add(notification);

    return Result.success(notification);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Feature Integration Helpers
  // ───────────────────────────────────────────────────────────────────────────

  /// Emergency SOS Alert
  Future<Result<AppNotification?>> notifyEmergency({
    required String title,
    required String body,
    String? rideId,
    Map<String, dynamic>? payload,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.emergency,
      priority: NotificationPriority.emergency,
      route: '/safety/tracking',
      entityId: rideId,
      payload: payload,
    );
  }

  /// Safety Overspeed / Warning Alert (throttled by default to 30s)
  Future<Result<AppNotification?>> notifySafetyWarning({
    required String title,
    required String body,
    String? rideId,
    Duration cooldown = const Duration(seconds: 30),
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.safety,
      priority: NotificationPriority.high,
      route: '/safety',
      entityId: rideId,
      throttleCooldown: cooldown,
    );
  }

  /// Ride Start / Completion Alert
  Future<Result<AppNotification?>> notifyRideEvent({
    required String title,
    required String body,
    required String rideId,
    bool isCompleted = false,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.ride,
      priority: NotificationPriority.normal,
      route: isCompleted ? '/rides/summary' : '/rides/live',
      entityId: rideId,
    );
  }

  /// AI Copilot Insight Alert
  Future<Result<AppNotification?>> notifyAiInsight({
    required String title,
    required String body,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.ai,
      priority: NotificationPriority.normal,
      route: '/coach/hub',
    );
  }

  /// Achievement Unlocked Alert
  Future<Result<AppNotification?>> notifyAchievement({
    required String title,
    required String body,
    String? achievementId,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.achievement,
      priority: NotificationPriority.high,
      route: '/achievements',
      entityId: achievementId,
    );
  }
}

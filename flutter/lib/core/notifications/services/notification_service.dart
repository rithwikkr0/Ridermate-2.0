import 'dart:async';
import '../../errors/result.dart';
import '../../services/shared_preferences_storage_service.dart';
import '../models/app_notification.dart';
import '../models/notification_preferences.dart';
import '../models/notification_type.dart';
import '../repositories/notification_repository.dart';
import 'local_notification_service.dart';

/// RiderMate 2.0 — Central Unified Notification Platform API Service
///
/// Architecture:
///   Application Event
///       ↓
///   NotificationService.notify()
///       ↓
///   Throttle / Deduplication Check
///       ↓
///   NotificationPreferences Check (category enabled?)
///       ↓
///   SQLite persistence (SqliteNotificationRepository)
///       ↓
///   LocalNotificationService → Android system tray
///       ↓
///   Broadcast stream → NotificationController (UI refresh)
///
/// Local notifications work fully offline.
/// Cloud push (FCM) is NOT CONFIGURED — see PushNotificationService.
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

  // In-memory throttle map: throttleKey → lastTriggeredAt
  // Cleared on app restart (intentional — avoids stale cooldowns across sessions)
  final Map<String, DateTime> _cooldowns = {};

  /// Clears the in-memory throttle cache.
  ///
  /// For use in tests only — ensures throttle state doesn't leak between test groups
  /// when running against a singleton service instance.
  // ignore: invalid_annotation_target
  void clearThrottleCache() => _cooldowns.clear();

  final StreamController<AppNotification> _notificationStreamController =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get notificationStream =>
      _notificationStreamController.stream;

  /// Initializes the centralized notification platform.
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    await _localService.initialize(onNotificationTap: onNotificationTap);
  }

  /// Returns the authenticated user ID from SharedPreferences.
  /// Falls back to 'user_guest' only if not yet authenticated.
  Future<String> _getUserId() async {
    try {
      final uid = await _storageService.getString('user_id');
      return (uid != null && uid.isNotEmpty) ? uid : 'user_guest';
    } catch (_) {
      return 'user_guest';
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Core dispatch API
  // ───────────────────────────────────────────────────────────────────────────

  /// Central API method to dispatch any notification in RiderMate 2.0.
  ///
  /// [userId] — pass the authenticated user's ID explicitly when available.
  ///   Falls back to SharedPreferences lookup if not supplied.
  /// [throttleCooldown] — if set, duplicate notifications with the same
  ///   type + entityId (or title) are suppressed within the cooldown window.
  ///   Emergency notifications should never be throttled — do not pass a cooldown.
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
    final uid = (userId != null && userId.isNotEmpty)
        ? userId
        : await _getUserId();

    // 1. In-memory throttle / deduplication check
    // Key: uid_type_entityId (or title hash if no entityId)
    final throttleKey = '${uid}_${type.name}_${entityId ?? title.hashCode}';
    if (throttleCooldown != null && _cooldowns.containsKey(throttleKey)) {
      final lastTime = _cooldowns[throttleKey]!;
      if (DateTime.now().difference(lastTime) < throttleCooldown) {
        // Suppressed — within cooldown window
        return Result.success(null);
      }
    }

    // 2. DB-level deduplication — suppress if same type+entityId seen in last hour.
    //    Prevents duplicate entries after app restarts (complements in-memory throttle).
    if (entityId != null && entityId.isNotEmpty && type != NotificationType.emergency) {
      final isDup = await _repository.isDuplicate(
        userId: uid,
        type: type.name,
        entityId: entityId,
        window: throttleCooldown ?? const Duration(hours: 1),
      );
      if (isDup) return Result.success(null);
    }

    // 3. Preferences Check — emergency always bypasses
    NotificationPreferences prefs = NotificationPreferences(userId: uid);
    if (type != NotificationType.emergency) {
      final prefsRes = await _repository.getPreferences(userId: uid);
      prefs = prefsRes.dataOrNull ?? NotificationPreferences(userId: uid);
      if (!prefs.isCategoryEnabled(type)) {
        return Result.success(null); // Category disabled by user
      }
    }

    // 4. Create canonical notification record
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${(title.hashCode ^ type.hashCode) & 0xFFFF}',
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

    // 5. Persist to SQLite (always — even during quiet hours)
    await _repository.saveNotification(notification);

    // 6. Reload prefs for sound/vibration (already loaded above for non-emergency)
    if (type == NotificationType.emergency) {
      final prefsRes = await _repository.getPreferences(userId: uid);
      prefs = prefsRes.dataOrNull ?? NotificationPreferences(userId: uid);
    }

    // 7. Quiet hours check — emergency always bypasses quiet hours.
    //    Notification is stored in DB above but OS tray push is skipped.
    final inQuietHours = type != NotificationType.emergency && prefs.isInQuietHours();
    if (!inQuietHours) {
      await _localService.showNotification(
        notification,
        playSound: prefs.soundEnabled,
        vibrate: prefs.vibrationEnabled,
      );
    }

    // 8. Record throttle timestamp
    if (throttleCooldown != null) {
      _cooldowns[throttleKey] = DateTime.now();
    }

    // 9. Broadcast to reactive UI stream
    if (!_notificationStreamController.isClosed) {
      _notificationStreamController.add(notification);
    }

    return Result.success(notification);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Feature Integration Helpers
  // ───────────────────────────────────────────────────────────────────────────

  /// Emergency SOS Alert — bypasses category preferences and throttling.
  /// Always delivers to Android system tray regardless of user settings.
  Future<Result<AppNotification?>> notifyEmergency({
    required String title,
    required String body,
    String? rideId,
    String? userId,
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
      userId: userId,
      // Emergency: NO throttle
    );
  }

  /// Safety warning — overspeed, harsh braking, hazard alert.
  ///
  /// Throttled by [cooldown] (default 30 seconds) to prevent notification spam
  /// during sustained overspeed events. Emergency escalation bypasses this.
  ///
  /// Cooldown rationale: 30 seconds allows the rider to see and acknowledge
  /// the warning without being flooded by repeated alerts at the same speed.
  Future<Result<AppNotification?>> notifySafetyWarning({
    required String title,
    required String body,
    String? rideId,
    String? userId,
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
      userId: userId,
    );
  }

  /// Ride lifecycle notification — start, pause, completion, interrupt.
  ///
  /// [isCompleted] switches deep-link to ride summary screen.
  /// [rideId] is required to enable deep linking to the specific ride.
  Future<Result<AppNotification?>> notifyRideEvent({
    required String title,
    required String body,
    required String rideId,
    bool isCompleted = false,
    String? userId,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.ride,
      priority: NotificationPriority.normal,
      route: isCompleted ? '/rides/summary' : '/rides/live',
      entityId: rideId,
      userId: userId,
    );
  }

  /// Memory created notification.
  ///
  /// Deep-links to the memory detail screen.
  Future<Result<AppNotification?>> notifyMemory({
    required String title,
    required String body,
    required String memoryId,
    String? userId,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.ride, // Memories use ride channel (ride-adjacent)
      priority: NotificationPriority.normal,
      route: '/memories/detail',
      entityId: memoryId,
      userId: userId,
    );
  }

  /// Maintenance reminder — service due, insurance, PUC expiry.
  ///
  /// Throttled to 24 hours to avoid repeated reminders on the same day.
  Future<Result<AppNotification?>> notifyMaintenance({
    required String title,
    required String body,
    String? vehicleId,
    String? userId,
    Duration cooldown = const Duration(hours: 24),
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.maintenance,
      priority: NotificationPriority.normal,
      route: '/garage',
      entityId: vehicleId,
      throttleCooldown: cooldown,
      userId: userId,
    );
  }

  /// AI Copilot insight — weekly report ready, post-ride analysis available.
  ///
  /// NOTE: AI module is currently mock. This helper is ready for when
  /// Gemini integration is added in Phase C.
  Future<Result<AppNotification?>> notifyAiInsight({
    required String title,
    required String body,
    String? userId,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.ai,
      priority: NotificationPriority.normal,
      route: '/coach/hub',
      userId: userId,
    );
  }

  /// Achievement unlocked notification.
  Future<Result<AppNotification?>> notifyAchievement({
    required String title,
    required String body,
    String? achievementId,
    String? userId,
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.achievement,
      priority: NotificationPriority.high,
      route: '/achievements',
      entityId: achievementId,
      userId: userId,
    );
  }

  /// Social notification — friend accepted, post liked, post commented.
  ///
  /// [actorName] is the display name of the user who performed the action.
  /// [postId] / [requestId] is stored as entityId for deduplication.
  /// Throttled to 5 minutes to avoid spam from rapid-fire likes.
  Future<Result<AppNotification?>> notifySocial({
    required String title,
    required String body,
    String? entityId,
    String? userId,
    Duration cooldown = const Duration(minutes: 5),
  }) async {
    return notify(
      title: title,
      body: body,
      type: NotificationType.social,
      priority: NotificationPriority.normal,
      route: '/social',
      entityId: entityId,
      throttleCooldown: cooldown,
      userId: userId,
    );
  }

  /// Disposes the notification stream.
  void dispose() {
    _notificationStreamController.close();
  }
}

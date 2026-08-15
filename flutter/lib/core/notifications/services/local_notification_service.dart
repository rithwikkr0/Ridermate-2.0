import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import '../models/notification_type.dart';

typedef NotificationTapCallback = void Function(String? route, Map<String, dynamic>? payload);

/// Key used to store a pending cold-start notification tap route
/// so that the router can navigate after full app initialization.
const String _kPendingTapRouteKey = 'pending_notification_route';

/// Top-level background notification response handler.
/// Must be a top-level function (not a method) — required by flutter_local_notifications.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) async {
  if (response.payload != null && response.payload!.isNotEmpty) {
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final route = data['route'] as String?;
      if (route != null && route.isNotEmpty) {
        // Store the pending route — router is not yet available in background isolate.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kPendingTapRouteKey, route);
      }
    } catch (_) {
      // Malformed payload — ignore
    }
  }
}

/// RiderMate 2.0 — Android Local Notifications Service
///
/// Manages all Android system tray notifications via flutter_local_notifications.
/// Supports:
///  - 8 notification channels (Emergency, Safety, Ride, Social, AI, Maintenance,
///    Achievement, System)
///  - Foreground, background, and terminated-app tap handling
///  - Deep-link route stored in SharedPreferences for cold-start navigation
///  - Per-notification sound and vibration respecting user preferences
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  NotificationTapCallback? _onNotificationTap;

  /// Initializes FlutterLocalNotifications with Android channels.
  ///
  /// [onNotificationTap] is called when the user taps a notification while
  /// the app is in the foreground or resumed from background.
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    if (_isInitialized) return;
    _onNotificationTap = onNotificationTap;

    // Use the dedicated monochrome notification icon for Android 5.0+ tray
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _plugin.initialize(
        initSettings,
        // Foreground / resumed-from-background tap
        onDidReceiveNotificationResponse: _handleTapResponse,
        // Terminated-app tap (top-level function required)
        onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
      );

      await _createNotificationChannels();
      _isInitialized = true;
    } catch (_) {
      // Platform binding unavailable (e.g. headless unit testing)
    }
  }

  /// Processes a tap notification response — parses route and payload,
  /// stores pending route in SharedPreferences for cold-start safety.
  void _handleTapResponse(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final route = data['route'] as String?;
      final payloadMap = data['payload'] as Map<String, dynamic>?;
      _onNotificationTap?.call(route, payloadMap);
    } catch (_) {
      _onNotificationTap?.call(null, null);
    }
  }

  /// Returns the pending cold-start route (stored by background handler)
  /// and clears it so it is only consumed once.
  static Future<String?> consumePendingTapRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final route = prefs.getString(_kPendingTapRouteKey);
      if (route != null) {
        await prefs.remove(_kPendingTapRouteKey);
      }
      return route;
    } catch (_) {
      return null;
    }
  }

  /// Registers all 8 Android notification channels.
  /// Emergency uses max importance; Safety uses high; System uses low.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    for (final type in NotificationType.values) {
      Importance importance = Importance.defaultImportance;

      if (type == NotificationType.emergency) {
        importance = Importance.max;
      } else if (type == NotificationType.safety) {
        importance = Importance.high;
      } else if (type == NotificationType.system) {
        importance = Importance.low;
      }

      final channel = AndroidNotificationChannel(
        type.channelId,
        type.channelName,
        description: 'RiderMate 2.0 ${type.displayName} notifications',
        importance: importance,
        enableVibration: true,
        playSound: true,
      );

      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Displays a local Android system notification from an [AppNotification].
  ///
  /// [playSound] and [vibrate] are controlled by user preferences.
  Future<void> showNotification(
    AppNotification notification, {
    bool playSound = true,
    bool vibrate = true,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final int notifId = notification.id.hashCode & 0x7FFFFFFF;

      Importance importance;
      Priority priority;

      switch (notification.priority) {
        case NotificationPriority.emergency:
          importance = Importance.max;
          priority = Priority.max;
          break;
        case NotificationPriority.high:
          importance = Importance.high;
          priority = Priority.high;
          break;
        case NotificationPriority.low:
          importance = Importance.low;
          priority = Priority.low;
          break;
        case NotificationPriority.normal:
          importance = Importance.defaultImportance;
          priority = Priority.defaultPriority;
          break;
      }

      final androidDetails = AndroidNotificationDetails(
        notification.type.channelId,
        notification.type.channelName,
        channelDescription: 'RiderMate 2.0 ${notification.type.displayName} notifications',
        importance: importance,
        priority: priority,
        playSound: playSound,
        enableVibration: vibrate,
        // Correct monochrome icon for Android notification shade
        icon: '@drawable/ic_notification',
        // Large icon fallback uses app icon
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        // Auto-cancels on tap
        autoCancel: true,
        // Show timestamp in notification
        when: notification.createdAt.millisecondsSinceEpoch,
        showWhen: true,
      );

      final details = NotificationDetails(android: androidDetails);

      final payloadStr = jsonEncode({
        'id': notification.id,
        'route': notification.route,
        'type': notification.type.name,
        'entity_id': notification.entityId,
        'payload': notification.payload,
      });

      await _plugin.show(
        notifId,
        notification.title,
        notification.body,
        details,
        payload: payloadStr,
      );
    } catch (_) {
      // Platform channel or plugin binding unavailable (e.g. headless unit testing)
    }
  }

  /// Cancels a specific active notification by its integer ID.
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  /// Cancels all active notifications.
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// Checks if app was launched by a notification tap.
  /// Returns the launch notification details, or null if launched normally.
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    try {
      return await _plugin.getNotificationAppLaunchDetails();
    } catch (_) {
      return null;
    }
  }
}

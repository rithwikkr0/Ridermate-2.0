import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/app_notification.dart';
import '../models/notification_type.dart';

typedef NotificationTapCallback = void Function(String? route, Map<String, dynamic>? payload);

/// RiderMate 2.0 — Android Local Notifications Service
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  NotificationTapCallback? _onNotificationTap;

  /// Initializes FlutterLocalNotifications with Android channels.
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    if (_isInitialized) return;
    _onNotificationTap = onNotificationTap;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              final route = data['route'] as String?;
              final payloadMap = data['payload'] as Map<String, dynamic>?;
              _onNotificationTap?.call(route, payloadMap);
            } catch (_) {
              _onNotificationTap?.call(null, null);
            }
          }
        },
      );

      await _createNotificationChannels();
      _isInitialized = true;
    } catch (_) {
      // Platform binding unavailable (e.g. headless unit testing)
    }
  }

  /// Registers all 8 Android notification channels.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      for (final type in NotificationType.values) {
        Importance importance = Importance.defaultImportance;
        Priority priority = Priority.defaultPriority;

        if (type == NotificationType.emergency) {
          importance = Importance.max;
          priority = Priority.high;
        } else if (type == NotificationType.safety) {
          importance = Importance.high;
          priority = Priority.high;
        } else if (type == NotificationType.system) {
          importance = Importance.low;
          priority = Priority.low;
        }

        final channel = AndroidNotificationChannel(
          type.channelId,
          type.channelName,
          description: 'Channel for ${type.displayName} notifications in RiderMate 2.0',
          importance: importance,
          enableVibration: true,
          playSound: true,
        );

        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  /// Displays a local Android system notification.
  Future<void> showNotification(AppNotification notification, {bool playSound = true, bool vibrate = true}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final int notifId = notification.id.hashCode & 0x7FFFFFFF;

      Importance importance = Importance.defaultImportance;
      Priority priority = Priority.defaultPriority;

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
        channelDescription: 'RiderMate ${notification.type.displayName} Notifications',
        importance: importance,
        priority: priority,
        playSound: playSound,
        enableVibration: vibrate,
        icon: '@mipmap/ic_launcher',
      );

      final details = NotificationDetails(android: androidDetails);

      final payloadStr = jsonEncode({
        'id': notification.id,
        'route': notification.route,
        'type': notification.type.name,
        'entity_id': notification.entityId,
        'payload': notification.payload,
      });

      await _notificationsPlugin.show(
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

  /// Cancels an active local notification by ID.
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancels all active notifications.
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}

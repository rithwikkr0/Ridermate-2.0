export '../notifications/services/notification_service.dart';
export '../notifications/models/notification_type.dart';
export '../notifications/models/app_notification.dart';
export '../notifications/models/notification_preferences.dart';

import '../notifications/models/app_notification.dart';
import '../notifications/models/notification_type.dart';
import '../notifications/services/local_notification_service.dart';

abstract class LegacyNotificationService {
  Future<void> showNotification({required int id, required String title, required String body});
  Future<void> cancelNotification(int id);
}

/// Real hardware notification service backed by LocalNotificationService
class DeviceNotificationService implements LegacyNotificationService {
  final LocalNotificationService _service;

  DeviceNotificationService({LocalNotificationService? service})
      : _service = service ?? LocalNotificationService();

  @override
  Future<void> showNotification({required int id, required String title, required String body}) async {
    final notification = AppNotification(
      id: id.toString(),
      userId: 'system',
      type: NotificationType.system,
      title: title,
      body: body,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
    );
    await _service.showNotification(notification);
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _service.cancelNotification(id);
  }
}

class MockNotificationService implements LegacyNotificationService {
  @override
  Future<void> showNotification({required int id, required String title, required String body}) async {}

  @override
  Future<void> cancelNotification(int id) async {}
}

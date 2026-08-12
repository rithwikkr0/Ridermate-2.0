export '../notifications/services/notification_service.dart';
export '../notifications/models/notification_type.dart';
export '../notifications/models/app_notification.dart';
export '../notifications/models/notification_preferences.dart';

abstract class LegacyNotificationService {
  Future<void> showNotification({required int id, required String title, required String body});
  Future<void> cancelNotification(int id);
}

class MockNotificationService implements LegacyNotificationService {
  @override
  Future<void> showNotification({required int id, required String title, required String body}) async {}

  @override
  Future<void> cancelNotification(int id) async {}
}

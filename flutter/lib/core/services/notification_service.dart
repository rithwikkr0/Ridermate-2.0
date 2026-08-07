abstract class NotificationService {
  Future<void> showNotification({required int id, required String title, required String body});
  Future<void> cancelNotification(int id);
}

class MockNotificationService implements NotificationService {
  @override
  Future<void> showNotification({required int id, required String title, required String body}) async {
    // Mock notification output
  }

  @override
  Future<void> cancelNotification(int id) async {
    // Mock cancellation
  }
}

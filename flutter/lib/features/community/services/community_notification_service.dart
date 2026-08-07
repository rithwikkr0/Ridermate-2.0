import '../../../core/constants/mock_data.dart';

abstract class CommunityNotificationService {
  Future<List<NotificationModel>> getNotifications();
}

class MockCommunityNotificationService implements CommunityNotificationService {
  @override
  Future<List<NotificationModel>> getNotifications() async {
    return MockData.notifications;
  }
}

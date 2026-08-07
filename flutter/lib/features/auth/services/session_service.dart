import '../../../core/services/storage_service.dart';

abstract class SessionService {
  Future<void> saveSession({required String accessToken, required String refreshToken, required String userId});
  Future<String?> getAccessToken();
  Future<String?> getUserId();
  Future<void> clearSession();
}

class MockSessionService implements SessionService {
  final StorageService storage;

  MockSessionService(this.storage);

  @override
  Future<void> saveSession({required String accessToken, required String refreshToken, required String userId}) async {
    await storage.setString('access_token', accessToken);
    await storage.setString('refresh_token', refreshToken);
    await storage.setString('user_id', userId);
  }

  @override
  Future<String?> getAccessToken() async => storage.getString('access_token');

  @override
  Future<String?> getUserId() async => storage.getString('user_id');

  @override
  Future<void> clearSession() async {
    await storage.remove('access_token');
    await storage.remove('refresh_token');
    await storage.remove('user_id');
  }
}

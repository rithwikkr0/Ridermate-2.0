import '../../../core/services/storage_service.dart';
import 'session_service.dart';

/// Real session service backed by persistent StorageService.
/// Session (access token, user ID) survives app restarts.
/// Replaces MockSessionService.
class SharedPreferencesSessionService implements SessionService {
  final StorageService storage;

  const SharedPreferencesSessionService(this.storage);

  static const _keyAccessToken = 'session_access_token';
  static const _keyRefreshToken = 'session_refresh_token';
  static const _keyUserId = 'session_user_id';

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await storage.setString(_keyAccessToken, accessToken);
    await storage.setString(_keyRefreshToken, refreshToken);
    await storage.setString(_keyUserId, userId);
  }

  @override
  Future<String?> getAccessToken() async =>
      storage.getString(_keyAccessToken);

  @override
  Future<String?> getUserId() async => storage.getString(_keyUserId);

  @override
  Future<void> clearSession() async {
    await storage.remove(_keyAccessToken);
    await storage.remove(_keyRefreshToken);
    await storage.remove(_keyUserId);
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/// Real persistent key-value storage backed by SharedPreferences.
/// Data survives app restarts. Replaces MockStorageService.
class SharedPreferencesStorageService implements StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}

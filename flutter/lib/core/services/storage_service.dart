abstract class StorageService {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
  Future<void> clear();
}

class MockStorageService implements StorageService {
  final Map<String, dynamic> _memoryStore = {};

  @override
  Future<String?> getString(String key) async => _memoryStore[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    _memoryStore[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => _memoryStore[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    _memoryStore[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _memoryStore.remove(key);
  }

  @override
  Future<void> clear() async {
    _memoryStore.clear();
  }
}

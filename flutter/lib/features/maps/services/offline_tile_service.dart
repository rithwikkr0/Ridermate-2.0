abstract class OfflineTileService {
  Future<void> downloadRegion({required String regionName, required double minLat, required double minLng, required double maxLat, required double maxLng});
  Future<int> getCachedStorageBytes();
  Future<void> clearTileCache();
}

class MockOfflineTileService implements OfflineTileService {
  int _mockBytes = 450 * 1024 * 1024; // 450 MB

  @override
  Future<void> downloadRegion({required String regionName, required double minLat, required double minLng, required double maxLat, required double maxLng}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockBytes += 120 * 1024 * 1024;
  }

  @override
  Future<int> getCachedStorageBytes() async => _mockBytes;

  @override
  Future<void> clearTileCache() async {
    _mockBytes = 0;
  }
}

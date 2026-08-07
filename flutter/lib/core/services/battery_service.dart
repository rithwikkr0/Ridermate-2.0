abstract class BatteryService {
  Future<int> getBatteryLevel();
  Future<bool> isCharging();
}

class MockBatteryService implements BatteryService {
  @override
  Future<int> getBatteryLevel() async => 88;

  @override
  Future<bool> isCharging() async => false;
}

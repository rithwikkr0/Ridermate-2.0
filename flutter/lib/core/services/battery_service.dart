import 'package:battery_plus/battery_plus.dart';

abstract class BatteryService {
  Future<int> getBatteryLevel();
  Future<bool> isCharging();
}

/// Real hardware battery service backed by battery_plus.
class DeviceBatteryService implements BatteryService {
  final Battery _battery;

  DeviceBatteryService({Battery? battery}) : _battery = battery ?? Battery();

  @override
  Future<int> getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (_) {
      return 100; // Fallback safe default
    }
  }

  @override
  Future<bool> isCharging() async {
    try {
      final state = await _battery.batteryState;
      return state == BatteryState.charging || state == BatteryState.full;
    } catch (_) {
      return false;
    }
  }
}

/// Fallback / offline mock battery service
class MockBatteryService implements BatteryService {
  @override
  Future<int> getBatteryLevel() async => 88;

  @override
  Future<bool> isCharging() async => false;
}

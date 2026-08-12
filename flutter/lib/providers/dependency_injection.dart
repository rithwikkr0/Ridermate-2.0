import '../core/services/logger_service.dart';
import '../core/services/network_service.dart';
import '../core/services/shared_preferences_storage_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/battery_service.dart';

/// RiderMate 2.0 — Central Service Dependency Injection Container
/// Singleton accessors for infrastructure services.
class DI {
  static final LoggerService logger = AppLoggerService();
  static final NetworkService network = MockNetworkService();
  static final SharedPreferencesStorageService storage =
      SharedPreferencesStorageService();
  static final PermissionService permissions = AndroidPermissionService();
  static final LocationService location = const DeviceLocationService();
  static final LegacyNotificationService notification = MockNotificationService();
  static final BatteryService battery = MockBatteryService();
}

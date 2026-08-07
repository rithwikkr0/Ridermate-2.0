import '../core/services/logger_service.dart';
import '../core/services/network_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/battery_service.dart';

/// RiderMate 2.0 — Central Service Dependency Injection Container
class DI {
  static final LoggerService logger = AppLoggerService();
  static final NetworkService network = MockNetworkService();
  static final StorageService storage = MockStorageService();
  static final PermissionService permissions = MockPermissionService();
  static final LocationService location = MockLocationService();
  static final NotificationService notification = MockNotificationService();
  static final BatteryService battery = MockBatteryService();
}

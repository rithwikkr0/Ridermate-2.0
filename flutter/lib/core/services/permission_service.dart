import 'package:permission_handler/permission_handler.dart' as platform;

enum AppPermission { location, notification, activityRecognition, camera }

enum PermissionStatus { granted, denied, permanentlyDenied }

abstract class PermissionService {
  Future<PermissionStatus> getStatus(AppPermission permission);
  Future<PermissionStatus> request(AppPermission permission);
}

class MockPermissionService implements PermissionService {
  final Map<AppPermission, PermissionStatus> _mockStatuses = {
    AppPermission.location: PermissionStatus.granted,
    AppPermission.notification: PermissionStatus.granted,
    AppPermission.activityRecognition: PermissionStatus.granted,
    AppPermission.camera: PermissionStatus.granted,
  };

  @override
  Future<PermissionStatus> getStatus(AppPermission permission) async {
    return _mockStatuses[permission] ?? PermissionStatus.granted;
  }

  @override
  Future<PermissionStatus> request(AppPermission permission) async {
    _mockStatuses[permission] = PermissionStatus.granted;
    return PermissionStatus.granted;
  }
}

/// Android permission bridge used by production services.  Background location
/// is intentionally requested only after foreground location has been granted.
class AndroidPermissionService implements PermissionService {
  platform.Permission _platformPermission(AppPermission permission) {
    return switch (permission) {
      AppPermission.location => platform.Permission.location,
      AppPermission.notification => platform.Permission.notification,
      AppPermission.activityRecognition => platform.Permission.activityRecognition,
      AppPermission.camera => platform.Permission.camera,
    };
  }

  PermissionStatus _map(platform.PermissionStatus status) {
    if (status.isGranted || status.isLimited) return PermissionStatus.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return PermissionStatus.permanentlyDenied;
    }
    return PermissionStatus.denied;
  }

  @override
  Future<PermissionStatus> getStatus(AppPermission permission) async {
    return _map(await _platformPermission(permission).status);
  }

  @override
  Future<PermissionStatus> request(AppPermission permission) async {
    final result = await _platformPermission(permission).request();
    return _map(result);
  }

  Future<PermissionStatus> requestBackgroundLocation() async {
    final foreground = await request(AppPermission.location);
    if (foreground != PermissionStatus.granted) return foreground;
    return _map(await platform.Permission.locationAlways.request());
  }
}

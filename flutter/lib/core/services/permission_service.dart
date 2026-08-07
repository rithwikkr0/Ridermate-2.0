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

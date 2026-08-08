import 'package:geolocator/geolocator.dart';
import '../models/ride_point_model.dart';
import '../errors/result.dart';
import '../errors/app_error.dart';

abstract class LocationService {
  Future<Result<RidePointModel>> getCurrentLocation();
  Stream<RidePointModel> getLocationStream();
}

class MockLocationService implements LocationService {
  @override
  Future<Result<RidePointModel>> getCurrentLocation() async {
    return Result.success(
      RidePointModel(
        latitude: 19.0760,
        longitude: 72.8777,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        speed: 42.5,
      ),
    );
  }

  @override
  Stream<RidePointModel> getLocationStream() async* {
    double lat = 19.0760;
    double lng = 72.8777;
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      lat += 0.0001;
      lng += 0.0001;
      yield RidePointModel(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        speed: 45.0,
      );
    }
  }
}

/// Real device location source. It does not invent a position when location is
/// unavailable: callers receive a typed error and can show the proper state.
class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  Future<Result<void>> _ensureUsable() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return Result.failure(const LocationError('Location services are disabled.', code: 'location_disabled'));
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return Result.failure(const PermissionError('Location permission was denied.', code: 'location_denied'));
    }
    if (permission == LocationPermission.deniedForever) {
      return Result.failure(const PermissionError('Location permission is permanently denied. Enable it in Android settings.', code: 'location_denied_forever'));
    }
    return Result.success(null);
  }

  RidePointModel _toRidePoint(Position position) => RidePointModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp.millisecondsSinceEpoch,
        speed: position.speed < 0 ? 0 : position.speed * 3.6,
      );

  @override
  Future<Result<RidePointModel>> getCurrentLocation() async {
    final status = await _ensureUsable();
    if (status.isFailure) return Result.failure(status.errorOrNull!);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
      );
      return Result.success(_toRidePoint(position));
    } catch (error) {
      return Result.failure(LocationError('Could not obtain the current location: $error', code: 'location_unavailable'));
    }
  }

  @override
  Stream<RidePointModel> getLocationStream() async* {
    final status = await _ensureUsable();
    if (status.isFailure) {
      throw status.errorOrNull!;
    }
    yield* Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'RiderMate ride tracking is active',
          notificationText: 'Recording your ride location.',
          enableWakeLock: true,
        ),
      ),
    ).map(_toRidePoint);
  }
}

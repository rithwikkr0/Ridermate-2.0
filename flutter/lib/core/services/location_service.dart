import 'dart:async';
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
        heading: 180.0,
        accuracy: 5.0,
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
        heading: 185.0,
        accuracy: 4.5,
      );
    }
  }
}

/// Real device location source. Uses the hardware GPS sensor on Android via Geolocator.
/// Never invents fake coordinates: returns typed errors when location or permissions are unavailable.
class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  /// Checks if location service (GPS) is enabled on the device.
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks current location permission state without triggering a prompt.
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission from the OS.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<Result<void>> _ensureUsable() async {
    if (!await isGpsEnabled()) {
      return Result.failure(
        const LocationError(
          'Location services (GPS) are disabled on your device.',
          code: 'location_disabled',
        ),
      );
    }

    var permission = await checkPermissionStatus();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return Result.failure(
        const PermissionError(
          'Location permission was denied.',
          code: 'location_denied',
        ),
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return Result.failure(
        const PermissionError(
          'Location permission is permanently denied. Please enable it in Android Settings.',
          code: 'location_denied_forever',
        ),
      );
    }

    return Result.success(null);
  }

  RidePointModel _toRidePoint(Position position) {
    final rawSpeed = position.speed;
    final speedKmh = rawSpeed < 0 ? 0.0 : (rawSpeed * 3.6);
    final rawHeading = position.heading;
    final headingDeg = rawHeading < 0 ? 0.0 : rawHeading;
    final rawAccuracy = position.accuracy;
    final accuracyM = rawAccuracy < 0 ? 0.0 : rawAccuracy;

    return RidePointModel(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp.millisecondsSinceEpoch,
      speed: speedKmh,
      heading: headingDeg,
      accuracy: accuracyM,
    );
  }

  @override
  Future<Result<RidePointModel>> getCurrentLocation() async {
    final status = await _ensureUsable();
    if (status.isFailure) return Result.failure(status.errorOrNull!);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final point = _toRidePoint(position);
      if (!point.isValid) {
        return Result.failure(
          const LocationError(
            'Received invalid location coordinates from sensor.',
            code: 'invalid_coordinates',
          ),
        );
      }
      return Result.success(point);
    } catch (error) {
      return Result.failure(
        LocationError(
          'Could not obtain location from device GPS: $error',
          code: 'location_unavailable',
        ),
      );
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
        distanceFilter: 2, // Update every 2 meters
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'RiderMate Live GPS Active',
          notificationText: 'Tracking real-time location via GPS.',
          enableWakeLock: true,
        ),
      ),
    ).map(_toRidePoint).where((point) => point.isValid);
  }
}

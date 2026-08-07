import '../models/ride_point_model.dart';
import '../errors/result.dart';

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

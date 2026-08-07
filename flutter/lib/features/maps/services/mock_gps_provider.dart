import 'dart:async';

class MockGpsPosition {
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double headingDegrees;

  const MockGpsPosition({
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.headingDegrees,
  });
}

/// RiderMate 2.0 — Mock GPS Provider (Simulates movement & heading)
class MockGpsProvider {
  Timer? _timer;
  double _lat = 19.0760;
  double _lng = 72.8777;
  double _heading = 45.0;

  final StreamController<MockGpsPosition> _controller = StreamController<MockGpsPosition>.broadcast();

  Stream<MockGpsPosition> get positionStream => _controller.stream;

  void startSimulating() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _lat += 0.0001;
      _lng += 0.0001;
      _heading = (_heading + 2.0) % 360.0;

      _controller.add(MockGpsPosition(
        latitude: _lat,
        longitude: _lng,
        speedKmh: 48.0 + (t.tick % 4),
        headingDegrees: _heading,
      ));
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

import 'dart:async';
import '../models/route_model.dart';

class LiveRideState {
  final double currentSpeedKmh;
  final double distanceKm;
  final Duration duration;
  final double headingDegrees;
  final String etaString;
  final List<RoutePoint> routePoints;

  const LiveRideState({
    required this.currentSpeedKmh,
    required this.distanceKm,
    required this.duration,
    required this.headingDegrees,
    required this.etaString,
    required this.routePoints,
  });
}

/// RiderMate 2.0 — Live Ride Simulator (Fake Coordinates Generator)
class LiveRideSimulator {
  Timer? _timer;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  double _distanceKm = 0.0;
  double _lat = 19.0760;
  double _lng = 72.8777;
  final List<RoutePoint> _points = [];

  final StreamController<LiveRideState> _controller = StreamController<LiveRideState>.broadcast();

  Stream<LiveRideState> get stream => _controller.stream;

  void start() {
    _isPaused = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isPaused) return;

      _elapsedSeconds++;
      _lat += 0.0001;
      _lng += 0.0001;
      _distanceKm += 0.012; // ~43 km/h rate

      final point = RoutePoint(
        latitude: _lat,
        longitude: _lng,
        speedKmh: 42.5 + (t.tick % 5),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        elevationMeters: 120.0 + (t.tick % 10),
      );
      _points.add(point);

      _controller.add(LiveRideState(
        currentSpeedKmh: point.speedKmh,
        distanceKm: double.parse(_distanceKm.toStringAsFixed(2)),
        duration: Duration(seconds: _elapsedSeconds),
        headingDegrees: 45.0,
        etaString: '18 min',
        routePoints: List.unmodifiable(_points),
      ));
    });
  }

  void pause() => _isPaused = true;
  void resume() => _isPaused = false;

  void stop() {
    _timer?.cancel();
    _isPaused = false;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

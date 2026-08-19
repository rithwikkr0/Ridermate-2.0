import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../models/safety_models.dart';

abstract class SensorDataStream {
  Stream<double> get gForceStream;
}

abstract class CrashDetectionEngine {
  Stream<CrashEvent> get crashStream;
  void startMonitoring();
  void stopMonitoring();
}

/// Real hardware crash detection engine reading accelerometer sensor stream
class DeviceCrashDetectionEngine implements CrashDetectionEngine {
  final StreamController<CrashEvent> _controller = StreamController<CrashEvent>.broadcast();
  StreamSubscription<UserAccelerometerEvent>? _sensorSub;
  DateTime? _lastCrashTime;

  @override
  Stream<CrashEvent> get crashStream => _controller.stream;

  @override
  void startMonitoring() {
    _sensorSub?.cancel();
    _sensorSub = userAccelerometerEventStream().listen((event) async {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      final gForce = magnitude / 9.80665;

      if (gForce >= 4.0) {
        final now = DateTime.now();
        if (_lastCrashTime != null && now.difference(_lastCrashTime!).inSeconds < 10) {
          return;
        }
        _lastCrashTime = now;

        double lat = 0.0;
        double lng = 0.0;
        try {
          final pos = await Geolocator.getLastKnownPosition();
          if (pos != null) {
            lat = pos.latitude;
            lng = pos.longitude;
          }
        } catch (_) {}

        final severity = gForce >= 7.0 ? CrashSeverity.majorCrash : CrashSeverity.minorFall;

        _controller.add(CrashEvent(
          id: 'crash-sensor-${now.millisecondsSinceEpoch}',
          timestamp: now,
          severity: severity,
          gForce: double.parse(gForce.toStringAsFixed(1)),
          latitude: lat,
          longitude: lng,
        ));
      }
    });
  }

  @override
  void stopMonitoring() {
    _sensorSub?.cancel();
    _sensorSub = null;
  }
}

class MockCrashDetectionEngine implements CrashDetectionEngine {
  Timer? _timer;
  final StreamController<CrashEvent> _controller = StreamController<CrashEvent>.broadcast();

  @override
  Stream<CrashEvent> get crashStream => _controller.stream;

  @override
  void startMonitoring() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (t) {
      if (t.tick % 4 == 0) {
        _controller.add(CrashEvent(
          id: 'crash-${t.tick}',
          timestamp: DateTime.now(),
          severity: CrashSeverity.minorFall,
          gForce: 3.8,
          latitude: 19.0760,
          longitude: 72.8777,
        ));
      }
    });
  }

  @override
  void stopMonitoring() {
    _timer?.cancel();
  }

  void simulateManualCrashTrigger(CrashSeverity severity) {
    _controller.add(CrashEvent(
      id: 'crash-manual-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      severity: severity,
      gForce: severity == CrashSeverity.majorCrash ? 8.5 : 4.2,
      latitude: 19.0760,
      longitude: 72.8777,
    ));
  }
}

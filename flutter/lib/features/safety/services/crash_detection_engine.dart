import 'dart:async';
import '../models/safety_models.dart';

abstract class SensorDataStream {
  Stream<double> get gForceStream;
}

abstract class CrashDetectionEngine {
  Stream<CrashEvent> get crashStream;
  void startMonitoring();
  void stopMonitoring();
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

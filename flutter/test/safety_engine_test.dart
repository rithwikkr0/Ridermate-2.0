import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/features/safety/services/safety_score_calculator.dart';
import 'package:ridermate/features/safety/controllers/sos_controller.dart';

void main() {
  group('Safety Engine Unit Tests', () {
    test('SafetyScoreCalculator computes scores accurately', () {
      final safeScore = SafetyScoreCalculator.calculate(
        maxSpeedKmh: 65.0,
        overspeedEvents: 0,
        harshBrakingEvents: 0,
        isNightRide: false,
        helmetVerified: true,
      );
      expect(safeScore, equals(100));

      final aggressiveScore = SafetyScoreCalculator.calculate(
        maxSpeedKmh: 110.0,
        overspeedEvents: 3,
        harshBrakingEvents: 2,
        isNightRide: true,
        helmetVerified: false,
      );
      expect(aggressiveScore, equals(38));
    });

    test('SosController manages countdown lifecycle', () async {
      final sosController = SosController();
      expect(sosController.sosState, equals(SosState.idle));

      sosController.triggerSos();
      expect(sosController.sosState, equals(SosState.countdown));

      sosController.cancelSos();
      expect(sosController.sosState, equals(SosState.cancelled));
      expect(sosController.timeline.events.length, equals(2));
    });
  });
}

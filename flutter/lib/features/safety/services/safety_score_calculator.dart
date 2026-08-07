/// RiderMate 2.0 — Safety Score Calculator
class SafetyScoreCalculator {
  static int calculate({
    required double maxSpeedKmh,
    required int overspeedEvents,
    required int harshBrakingEvents,
    required bool isNightRide,
    required bool helmetVerified,
  }) {
    int score = 100;

    if (maxSpeedKmh > 100) {
      score -= 20;
    } else if (maxSpeedKmh > 80) {
      score -= 10;
    }

    score -= (overspeedEvents * 4);
    score -= (harshBrakingEvents * 5);

    if (isNightRide) score -= 5;
    if (!helmetVerified) score -= 15;

    return score.clamp(0, 100);
  }
}

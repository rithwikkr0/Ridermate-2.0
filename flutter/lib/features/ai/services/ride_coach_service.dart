class CoachInsight {
  final String category;
  final String title;
  final String recommendation;

  const CoachInsight({required this.category, required this.title, required this.recommendation});
}

class RideCoachService {
  static List<CoachInsight> generateInsights({
    required double avgSpeedKmh,
    required int safetyScore,
    required double distanceKm,
  }) {
    final List<CoachInsight> insights = [];

    if (safetyScore >= 90) {
      insights.add(const CoachInsight(
        category: 'Defensive Riding',
        title: 'Masterful Smoothness',
        recommendation: 'Exceptional speed control and progressive braking throughout the route.',
      ));
    } else {
      insights.add(const CoachInsight(
        category: 'Safety Alert',
        title: 'Modulate Corner Speed',
        recommendation: 'Reduce entry speed into tight twisties to maintain safety buffer.',
      ));
    }

    insights.add(CoachInsight(
      category: 'Hydration & Recovery',
      title: 'Post-Ride Hydration',
      recommendation: 'Drink 500ml of electrolytes following this ${distanceKm.toStringAsFixed(1)}km session.',
    ));

    return insights;
  }
}

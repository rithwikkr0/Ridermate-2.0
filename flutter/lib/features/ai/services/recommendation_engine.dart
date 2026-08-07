class SmartRecommendation {
  final String title;
  final String category;
  final String description;

  const SmartRecommendation({required this.title, required this.category, required this.description});
}

class RecommendationEngine {
  static List<SmartRecommendation> getRecommendations() {
    return const [
      SmartRecommendation(
        title: 'Lonavala Ghats Sunrise Lap',
        category: 'Route Suggestion',
        description: 'Recommended for 6:00 AM departure — 42.5 km scenic twisties with 85% safety index.',
      ),
      SmartRecommendation(
        title: 'Chain Lube Service Due',
        category: 'Vehicle Maintenance',
        description: 'Completed 480 km since last lube. Recommended maintenance before long weekend ride.',
      ),
    ];
  }
}

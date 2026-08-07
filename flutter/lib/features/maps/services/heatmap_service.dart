class HeatmapPoint {
  final double latitude;
  final double longitude;
  final double intensity; // 0.0 to 1.0

  const HeatmapPoint({required this.latitude, required this.longitude, required this.intensity});
}

class HeatmapService {
  static List<HeatmapPoint> generateMockHeatmap() {
    return List.generate(50, (i) {
      return HeatmapPoint(
        latitude: 19.0760 + (i * 0.003),
        longitude: 72.8777 + (i * 0.003),
        intensity: 0.2 + ((i % 5) * 0.16),
      );
    });
  }
}

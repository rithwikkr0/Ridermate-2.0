import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/features/maps/models/map_theme.dart';
import 'package:ridermate/features/maps/services/route_planning_service.dart';
import 'package:ridermate/features/maps/services/mock_place_search_service.dart';
import 'package:ridermate/features/maps/services/heatmap_service.dart';

void main() {
  group('Maps & Navigation Unit Tests', () {
    test('MapConfig provides valid OSM tile URLs', () {
      expect(MapConfig.darkTileUrl, contains('cartodb'));
      expect(MapConfig.lightTileUrl, contains('openstreetmap'));
    });

    test('MockRoutePlanningService returns multiple route options', () async {
      final planner = MockRoutePlanningService();
      final routes = await planner.planRoutes(
        startLat: 19.0760,
        startLng: 72.8777,
        destLat: 18.9440,
        destLng: 72.8230,
      );
      expect(routes.length, equals(2));
      expect(routes.first.distanceKm, greaterThan(0.0));
    });

    test('MockPlaceSearchService searches places correctly', () async {
      final searchService = MockPlaceSearchService();
      final results = await searchService.searchPlaces('Marine');
      expect(results.length, equals(1));
      expect(results.first.title, contains('Marine Drive'));
    });

    test('HeatmapService generates mock heat points', () {
      final points = HeatmapService.generateMockHeatmap();
      expect(points.length, equals(50));
      expect(points.first.intensity, greaterThan(0.0));
    });
  });
}

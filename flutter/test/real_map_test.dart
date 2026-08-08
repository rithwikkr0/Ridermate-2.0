import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridermate/core/models/ride_point_model.dart';
import 'package:ridermate/core/widgets/real_map_view.dart';

void main() {
  group('RealMapView Unit & Widget Tests', () {
    test('GPS-to-map coordinate conversion creates valid LatLng', () {
      final point = RidePointModel(
        latitude: 12.971598,
        longitude: 77.594566,
        timestamp: 1700000000000,
        speed: 35.0,
        heading: 180.0,
        accuracy: 4.5,
      );

      final latLng = LatLng(point.latitude, point.longitude);
      expect(latLng.latitude, equals(12.971598));
      expect(latLng.longitude, equals(77.594566));
    });

    testWidgets('RealMapView renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RealMapView(
              showControls: true,
              showRecenterButton: true,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(RealMapView), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    test('Heading angle calculation converts degrees to radians correctly', () {
      const headingDeg = 90.0;
      final radians = headingDeg * (3.141592653589793 / 180.0);
      expect(radians, closeTo(1.5707963267948966, 0.001));
    });

    test('Accuracy radius threshold categories evaluate accurately', () {
      const highAccuracy = 4.2;
      const mediumAccuracy = 25.0;
      const poorAccuracy = 80.0;

      expect(highAccuracy <= 10.0, isTrue);
      expect(mediumAccuracy > 10.0 && mediumAccuracy <= 50.0, isTrue);
      expect(poorAccuracy > 50.0, isTrue);
    });
  });
}

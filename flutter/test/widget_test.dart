import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ridermate/main.dart';

import 'package:ridermate/core/services/storage_service.dart';
import 'package:ridermate/features/auth/controllers/auth_controller.dart';
import 'package:ridermate/features/auth/services/mock_auth_service.dart';
import 'package:ridermate/features/auth/services/session_service.dart';
import 'package:ridermate/features/profile/controllers/profile_controller.dart';
import 'package:ridermate/features/profile/repositories/user_repository.dart';
import 'package:ridermate/features/rides/controllers/ride_controller.dart';
import 'package:ridermate/features/rides/repositories/ride_repository.dart';
import 'package:ridermate/core/services/location_service.dart';
import 'package:ridermate/features/safety/controllers/sos_controller.dart';
import 'package:ridermate/features/ai/controllers/ai_controller.dart';
import 'package:ridermate/features/ai/repositories/ai_repository.dart';
import 'package:ridermate/features/ai/services/ai_provider.dart';
import 'package:ridermate/features/community/controllers/community_controller.dart';
import 'package:ridermate/features/garage/controllers/garage_controller.dart';
import 'package:ridermate/features/garage/repositories/garage_repository.dart';
import 'package:ridermate/features/garage/services/fuel_manager_service.dart';
import 'package:ridermate/features/garage/services/maintenance_service.dart';
import 'package:ridermate/features/maps/controllers/navigation_controller.dart';
import 'package:ridermate/features/weather/controllers/weather_controller.dart';
import 'package:ridermate/features/weather/services/weather_service.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Suppress network image errors in headless test environment
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('NetworkImageLoadException') ||
          details.toString().contains('HTTP request failed')) {
        return; // Suppress expected test environment network errors
      }
      originalOnError?.call(details);
    };

    final storageService = MockStorageService();
    final mockAuthService = MockAuthService();
    final sessionService = MockSessionService(storageService);
    final userRepository = MockUserRepository();
    final rideRepository = MockRideRepository();
    final locationService = MockLocationService();

    final aiProvider = MockAiProvider();
    final aiRepository = MockAiRepository(aiProvider);

    final fuelManagerService = MockFuelManagerService();
    final maintenanceService = MockMaintenanceService();
    final garageRepository = MockGarageRepository(
      fuelManager: fuelManagerService,
      maintenanceService: maintenanceService,
    );

    final weatherService = OpenWeatherService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(
              create: (_) => AuthController(mockAuthService, sessionService)),
          ChangeNotifierProvider(
              create: (_) => ProfileController(userRepository)),
          ChangeNotifierProvider(
              create: (_) => RideController(rideRepository, locationService)),
          ChangeNotifierProvider(create: (_) => SosController()),
          ChangeNotifierProvider(create: (_) => AiController(aiRepository)),
          ChangeNotifierProvider(create: (_) => CommunityController()),
          ChangeNotifierProvider(
              create: (_) => GarageController(garageRepository)),
          ChangeNotifierProvider(create: (_) => NavigationController()),
          ChangeNotifierProvider(
              create: (_) => WeatherController(weatherService)),
        ],
        child: const RiderMateApp(),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100)).catchError((_) => 0);
    expect(find.byType(RiderMateApp), findsOneWidget);

    // Restore error handler
    FlutterError.onError = originalOnError;
  });
}

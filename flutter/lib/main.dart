import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/errors/global_error_handler.dart';
import 'core/services/database_service.dart';
import 'core/services/shared_preferences_storage_service.dart';
import 'core/notifications/services/notification_service.dart';
import 'core/notifications/controllers/notification_controller.dart';

// Auth
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/services/sqlite_auth_service.dart';
import 'features/auth/services/shared_preferences_session_service.dart';

// Profile
import 'features/profile/controllers/profile_controller.dart';
import 'features/profile/repositories/sqlite_user_repository.dart';

// Rides — SqliteRideRepository is real; DeviceLocationService is real
import 'features/rides/controllers/ride_controller.dart';
import 'features/rides/repositories/sqlite_ride_repository.dart';
import 'core/services/location_service.dart';

// Memories — SqliteMemoryRepository is real
import 'features/memories/controllers/memory_controller.dart';
import 'features/memories/repositories/memory_repository.dart';

// Safety
import 'features/safety/controllers/sos_controller.dart';

// AI — still mock; will be replaced in Phase 13
import 'features/ai/controllers/ai_controller.dart';
import 'features/ai/repositories/ai_repository.dart';
import 'features/ai/services/ai_provider.dart';

// Community — still mock; will be replaced in Phase 14
import 'features/community/controllers/community_controller.dart';
import 'features/community/repositories/community_repository.dart';
import 'features/community/services/friend_manager_service.dart';
import 'features/community/services/club_manager_service.dart';
import 'features/community/services/challenge_engine_service.dart';
import 'features/community/services/leaderboard_service.dart';

// Garage — still mock; will be replaced in Phase 9
import 'features/garage/controllers/garage_controller.dart';
import 'features/garage/repositories/garage_repository.dart';
import 'features/garage/services/fuel_manager_service.dart';
import 'features/garage/services/maintenance_service.dart';

// Maps
import 'features/maps/controllers/navigation_controller.dart';

// Weather — real HTTP call; requires API key for live data
import 'features/weather/controllers/weather_controller.dart';
import 'features/weather/services/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalErrorHandler.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // ── Real persistent services ──────────────────────────────────────────────
  final storageService = SharedPreferencesStorageService();
  final databaseService = DatabaseService.instance;

  // Warm up the database on startup so first operations are fast
  await databaseService.database;

  // Initialize Android local notifications platform
  await NotificationService.instance.initialize(
    onNotificationTap: (route, payload) {
      if (route != null && route.isNotEmpty) {
        try {
          appRouter.push(route);
        } catch (_) {}
      }
    },
  );

  // ── Real auth + session ───────────────────────────────────────────────────
  final authService = SqliteAuthService(databaseService);
  final sessionService = SharedPreferencesSessionService(storageService);

  // ── Real ride tracking ────────────────────────────────────────────────────
  final rideRepository = SqliteRideRepository();
  final memoryRepository = SqliteMemoryRepository();
  const locationService = DeviceLocationService();

  // ── AI — mock until Phase 13 ──────────────────────────────────────────────
  final aiProvider = MockAiProvider();
  final aiRepository = MockAiRepository(aiProvider);

  // ── Community — mock until Phase 14 ──────────────────────────────────────
  final friendManager = MockFriendManagerService();
  final clubManager = MockClubManagerService();
  final challengeEngine = MockChallengeEngineService();
  final leaderboardService = MockLeaderboardService();
  final communityRepository = MockCommunityRepository(
    friendManager: friendManager,
    clubManager: clubManager,
    challengeEngine: challengeEngine,
    leaderboardService: leaderboardService,
  );

  // ── Garage — mock until Phase 9 ───────────────────────────────────────────
  final fuelManagerService = MockFuelManagerService();
  final maintenanceService = MockMaintenanceService();
  final garageRepository = MockGarageRepository(
    fuelManager: fuelManagerService,
    maintenanceService: maintenanceService,
  );

  // ── Weather — real HTTP; DEMO_KEY falls back to mock data ─────────────────
  final weatherService = OpenWeatherService();

  // ── ProfileController starts with an empty repository.
  // After login/session restore, AuthController updates it with the real
  // SqliteUserRepository for the authenticated user.
  // We create a temporary placeholder that points at a dummy userId;
  // it will be replaced via updateRepository() after auth.
  final profileController = ProfileController(
    SqliteUserRepository(databaseService, userId: ''),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(
          create: (_) => AuthController(
            authService,
            sessionService,
            databaseService: databaseService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => profileController),
        ChangeNotifierProvider(
            create: (_) => RideController(rideRepository, locationService)),
        ChangeNotifierProvider(create: (_) => SosController()),
        ChangeNotifierProvider(create: (_) => AiController(aiRepository)),
        ChangeNotifierProvider(
            create: (_) => CommunityController(communityRepository)),
        ChangeNotifierProvider(
            create: (_) => GarageController(garageRepository)),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(
            create: (_) => WeatherController(weatherService)),
        ChangeNotifierProvider(
            create: (_) => MemoryController(memoryRepository, locationService)),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: const RiderMateApp(),
    ),
  );
}

/// Theme state notifier
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setDark() {
    _mode = ThemeMode.dark;
    notifyListeners();
  }

  void setLight() {
    _mode = ThemeMode.light;
    notifyListeners();
  }

  void setSystem() {
    _mode = ThemeMode.system;
    notifyListeners();
  }
}

class RiderMateApp extends StatelessWidget {
  const RiderMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    return MaterialApp.router(
      title: 'RiderMate 2.0',
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}

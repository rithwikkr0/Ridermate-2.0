import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/errors/global_error_handler.dart';
import 'core/services/database_service.dart';
import 'core/services/shared_preferences_storage_service.dart';
import 'core/notifications/services/notification_service.dart';
import 'core/notifications/services/local_notification_service.dart';
import 'core/notifications/controllers/notification_controller.dart';
import 'core/gamification/sqlite_gamification_repository.dart';
import 'core/gamification/gamification_controller.dart';
import 'core/gamification/challenge_seeder.dart';
import 'core/sync/offline_sync_engine.dart';
import 'core/services/live_location_service.dart';

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

// Community — Production SQLite Social Architecture
import 'features/community/controllers/community_controller.dart';
import 'features/community/repositories/sqlite_post_repository.dart';
import 'features/community/repositories/sqlite_friend_repository.dart';
import 'features/community/repositories/sqlite_squad_repository.dart';

// Garage — Real SQLite Persistence
import 'features/garage/controllers/garage_controller.dart';
import 'features/garage/repositories/sqlite_garage_repository.dart';

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

  // Seed default challenges for gamification
  await ChallengeSeeder.seedDefaultChallenges();

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

  // Check if app was cold-started by a notification tap.
  // The background handler stores the route in SharedPreferences.
  // We schedule navigation after the first frame so the router is ready.
  final pendingRoute = await LocalNotificationService.consumePendingTapRoute();
  if (pendingRoute != null && pendingRoute.isNotEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        appRouter.push(pendingRoute);
      } catch (_) {}
    });
  }

  // ── Real auth + session ───────────────────────────────────────────────────
  final authService = SqliteAuthService(databaseService);
  final sessionService = SharedPreferencesSessionService(storageService);

  // ── Real ride tracking ────────────────────────────────────────────────────
  final rideRepository = SqliteRideRepository();
  final memoryRepository = SqliteMemoryRepository();
  const locationService = DeviceLocationService();
  final rideController = RideController(rideRepository, locationService);

  // ── Gamification ──────────────────────────────────────────────────────────
  final gamificationRepository = SqliteGamificationRepository(dbService: databaseService);
  final gamificationController = GamificationController(gamificationRepository);

  // ── AI — mock until Phase 13 ──────────────────────────────────────────────
  final aiProvider = MockAiProvider();
  final aiRepository = MockAiRepository(aiProvider);

  // ── Community — Real SQLite Persistence & Privacy ───────────────────────
  final postRepository = SqlitePostRepository(dbService: databaseService);
  final friendRepository = SqliteFriendRepository(dbService: databaseService);
  final squadRepository = SqliteSquadRepository(dbService: databaseService);
  final communityController = CommunityController(
    postRepo: postRepository,
    friendRepo: friendRepository,
    squadRepo: squadRepository,
    dbService: databaseService,
  );

  // ── Garage — Real SQLite Persistence ──────────────────────────────────────
  final garageRepository = SqliteGarageRepository(dbService: databaseService);
  final garageController = GarageController(garageRepository);

  // ── Weather — real HTTP; DEMO_KEY falls back to mock data ─────────────────
  final weatherService = OpenWeatherService();

  final profileController = ProfileController(
    SqliteUserRepository(databaseService, userId: ''),
  );

  // Build the NotificationController and SosController so we can pass them to AuthController.
  final notificationController = NotificationController();
  final sosController = SosController();
  final aiController = AiController(aiRepository);

  // Build AuthController with onUserChanged callback.
  // This keeps NotificationController, RideController, GarageController, SosController, and CommunityController in sync.
  final authController = AuthController(
    authService,
    sessionService,
    databaseService: databaseService,
    onUserChanged: (userId) {
      notificationController.refreshForUser(userId);
      rideController.setUserId(userId);
      garageController.refreshForUser(userId);
      sosController.refreshForUser(userId);
      communityController.refreshForUser(userId);
      gamificationController.setUserId(userId);
      aiController.refreshForUser(userId);
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => authController),
        ChangeNotifierProvider(create: (_) => profileController),
        ChangeNotifierProvider(create: (_) => rideController),
        ChangeNotifierProvider(create: (_) => sosController),
        ChangeNotifierProvider.value(value: aiController),
        ChangeNotifierProvider(create: (_) => communityController),
        ChangeNotifierProvider(create: (_) => garageController),
        ChangeNotifierProvider(create: (_) => gamificationController),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(
            create: (_) => WeatherController(weatherService)),
        ChangeNotifierProvider(create: (_) => MemoryController(memoryRepository, locationService)),
        ChangeNotifierProvider(create: (_) => notificationController),
        ChangeNotifierProvider(create: (_) => OfflineSyncEngine.instance),
        ChangeNotifierProvider(create: (_) => LiveLocationService.instance),
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

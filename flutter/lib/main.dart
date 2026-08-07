import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/errors/global_error_handler.dart';
import 'core/services/storage_service.dart';

// Controllers & Repositories
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/services/mock_auth_service.dart';
import 'features/auth/services/session_service.dart';

import 'features/profile/controllers/profile_controller.dart';
import 'features/profile/repositories/user_repository.dart';

import 'features/rides/controllers/ride_controller.dart';
import 'features/rides/repositories/ride_repository.dart';

import 'features/safety/controllers/sos_controller.dart';

import 'features/ai/controllers/ai_controller.dart';
import 'features/ai/repositories/ai_repository.dart';
import 'features/ai/services/ai_provider.dart';

import 'features/community/controllers/community_controller.dart';
import 'features/community/repositories/community_repository.dart';
import 'features/community/services/friend_manager_service.dart';
import 'features/community/services/club_manager_service.dart';
import 'features/community/services/challenge_engine_service.dart';
import 'features/community/services/leaderboard_service.dart';

import 'features/garage/controllers/garage_controller.dart';
import 'features/garage/repositories/garage_repository.dart';
import 'features/garage/services/fuel_manager_service.dart';
import 'features/garage/services/maintenance_service.dart';

import 'features/maps/controllers/navigation_controller.dart';

import 'features/weather/controllers/weather_controller.dart';
import 'features/weather/services/weather_service.dart';

void main() {
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

  // Singletons & Services
  final storageService = MockStorageService();
  final mockAuthService = MockAuthService();
  final sessionService = MockSessionService(storageService);
  final userRepository = MockUserRepository();
  final rideRepository = MockRideRepository();

  final aiProvider = MockAiProvider();
  final aiRepository = MockAiRepository(aiProvider);

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

  final fuelManagerService = MockFuelManagerService();
  final maintenanceService = MockMaintenanceService();
  final garageRepository = MockGarageRepository(
    fuelManager: fuelManagerService,
    maintenanceService: maintenanceService,
  );

  final weatherService = OpenWeatherService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthController(mockAuthService, sessionService)),
        ChangeNotifierProvider(create: (_) => ProfileController(userRepository)),
        ChangeNotifierProvider(create: (_) => RideController(rideRepository)),
        ChangeNotifierProvider(create: (_) => SosController()),
        ChangeNotifierProvider(create: (_) => AiController(aiRepository)),
        ChangeNotifierProvider(create: (_) => CommunityController(communityRepository)),
        ChangeNotifierProvider(create: (_) => GarageController(garageRepository)),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => WeatherController(weatherService)),
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

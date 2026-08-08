import 'dart:async';
import '../../../core/models/ride_point_model.dart';
import '../../../core/services/location_service.dart';
import '../../../providers/base_controller.dart';
import '../models/navigation_route_model.dart';
import '../models/turn_by_turn_instruction.dart';

/// RiderMate 2.0 — Navigation Controller
class NavigationController extends BaseController {
  final LocationService locationService;
  NavigationRouteModel? activeRoute;
  RidePointModel? currentPosition;
  TurnByTurnInstruction? currentInstruction;
  StreamSubscription<RidePointModel>? _locationSubscription;

  bool isNavigating = false;
  bool isPaused = false;
  bool isVoiceGuidanceEnabled = true;

  NavigationController({LocationService? locationService})
      : locationService = locationService ?? const DeviceLocationService();

  void startNavigation(NavigationRouteModel route) {
    activeRoute = route;
    isNavigating = true;
    isPaused = false;
    currentInstruction = const TurnByTurnInstruction(
      instructionText: 'Turn left onto Coastal Expressway in 200m',
      distanceMeters: 200,
      direction: TurnDirection.turnLeft,
      iconName: 'turn_left',
    );

    _locationSubscription?.cancel();
    _locationSubscription = locationService.getLocationStream().listen(
      (point) {
        currentPosition = point;
        notifyListeners();
      },
      onError: (error) {
        // Handle stream location errors gracefully
      },
    );

    setState(ViewState.success);
  }

  void pauseNavigation() {
    isPaused = true;
    notifyListeners();
  }

  void resumeNavigation() {
    isPaused = false;
    notifyListeners();
  }

  void stopNavigation() {
    isNavigating = false;
    isPaused = false;
    activeRoute = null;
    _locationSubscription?.cancel();
    notifyListeners();
  }

  void toggleVoiceGuidance() {
    isVoiceGuidanceEnabled = !isVoiceGuidanceEnabled;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

import '../../../providers/base_controller.dart';
import '../models/navigation_route_model.dart';
import '../models/turn_by_turn_instruction.dart';
import '../services/mock_gps_provider.dart';

/// RiderMate 2.0 — Navigation Controller
class NavigationController extends BaseController {
  final MockGpsProvider gpsProvider = MockGpsProvider();
  NavigationRouteModel? activeRoute;
  MockGpsPosition? currentPosition;
  TurnByTurnInstruction? currentInstruction;

  bool isNavigating = false;
  bool isPaused = false;
  bool isVoiceGuidanceEnabled = true;

  NavigationController() {
    gpsProvider.positionStream.listen((pos) {
      currentPosition = pos;
      notifyListeners();
    });
  }

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
    gpsProvider.startSimulating();
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
    gpsProvider.stop();
    notifyListeners();
  }

  void toggleVoiceGuidance() {
    isVoiceGuidanceEnabled = !isVoiceGuidanceEnabled;
    notifyListeners();
  }

  @override
  void dispose() {
    gpsProvider.dispose();
    super.dispose();
  }
}

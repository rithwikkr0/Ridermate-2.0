import '../../../providers/base_controller.dart';
import '../models/ride_engine_model.dart';
import '../repositories/ride_repository.dart';
import '../services/live_ride_simulator.dart';

/// RiderMate 2.0 — Ride Controller (Start, Pause, Resume, Stop, Save, Delete)
class RideController extends BaseController {
  final RideRepository repository;
  final LiveRideSimulator simulator = LiveRideSimulator();

  LiveRideState? currentLiveState;
  bool isTracking = false;
  bool isPaused = false;

  RideController(this.repository) {
    simulator.stream.listen((state) {
      currentLiveState = state;
      notifyListeners();
    });
  }

  void startRide() {
    isTracking = true;
    isPaused = false;
    simulator.start();
    setState(ViewState.success);
  }

  void pauseRide() {
    isPaused = true;
    simulator.pause();
    notifyListeners();
  }

  void resumeRide() {
    isPaused = false;
    simulator.resume();
    notifyListeners();
  }

  void stopRide() {
    isTracking = false;
    isPaused = false;
    simulator.stop();
    notifyListeners();
  }

  Future<void> saveRide(RideEngineModel ride) async {
    setState(ViewState.loading);
    await repository.save(ride);
    stopRide();
    setState(ViewState.success);
  }

  Future<void> deleteRide(String id) async {
    setState(ViewState.loading);
    await repository.delete(id);
    setState(ViewState.success);
  }

  @override
  void dispose() {
    simulator.dispose();
    super.dispose();
  }
}

import '../../../providers/base_controller.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/mock_auth_service.dart';
import '../models/vehicle_model.dart';
import '../repositories/user_repository.dart';

/// RiderMate 2.0 — Profile Controller
class ProfileController extends BaseController {
  final UserRepository repository;
  UserModel? currentUser;

  ProfileController(this.repository) {
    loadProfile();
  }

  UserModel get user => currentUser ?? MockAuthService.mockUser;

  Future<void> loadProfile() async {
    setState(ViewState.loading);
    final res = await repository.getCurrentUser();
    if (res.isSuccess) {
      currentUser = res.dataOrNull;
      setState(ViewState.success);
    } else {
      currentUser = MockAuthService.mockUser;
      setState(ViewState.error, error: res.errorOrNull);
    }
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    final res = await repository.addVehicle(vehicle);
    if (res.isSuccess) {
      await loadProfile();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final res = await repository.deleteVehicle(vehicleId);
    if (res.isSuccess) {
      await loadProfile();
    }
  }
}

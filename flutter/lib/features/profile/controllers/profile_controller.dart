import '../../../providers/base_controller.dart';
import '../../auth/models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/emergency_contact_model.dart';
import '../repositories/user_repository.dart';

/// RiderMate 2.0 — Profile Controller
/// Reads/writes the real user profile from the UserRepository.
/// No fallback to mock data — if there is no user, state is error.
class ProfileController extends BaseController {
  UserRepository? _repository;
  UserModel? currentUser;

  ProfileController(UserRepository repository) : _repository = repository {
    loadProfile();
  }

  /// Swap in a new repository (called after login when userId is known).
  void updateRepository(UserRepository repository) {
    _repository = repository;
    loadProfile();
  }

  UserModel? get user => currentUser;

  /// Returns the current user or a safe empty placeholder.
  /// Screens that should only be reached after login can use this safely.
  UserModel get userOrDefault => currentUser ?? _emptyUser;

  static final UserModel _emptyUser = UserModel(
    id: '',
    username: '',
    fullName: '',
    email: '',
    phone: '',
    profilePhotoUrl: '',
    bio: '',
    riderLevel: 'Novice',
    xp: 0,
    totalDistanceKm: 0,
    totalRides: 0,
    achievements: const [],
    emergencyContacts: const [],
    vehicles: const [],
    preferences: const UserPreferences(),
    createdAt: DateTime(2020),
    updatedAt: DateTime(2020),
  );

  Future<void> loadProfile() async {
    final repo = _repository;
    if (repo == null) {
      setState(ViewState.initial);
      return;
    }
    setState(ViewState.loading);
    final res = await repo.getCurrentUser();
    if (res.isSuccess) {
      currentUser = res.dataOrNull;
      setState(ViewState.success);
    } else {
      currentUser = null;
      setState(ViewState.error, error: res.errorOrNull);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    final repo = _repository;
    if (repo == null) return;
    setState(ViewState.loading);
    final res = await repo.updateProfile(updatedUser);
    if (res.isSuccess) {
      currentUser = res.dataOrNull;
      setState(ViewState.success);
    } else {
      setState(ViewState.error, error: res.errorOrNull);
    }
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    final repo = _repository;
    if (repo == null) return;
    final res = await repo.addVehicle(vehicle);
    if (res.isSuccess) {
      await loadProfile();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final repo = _repository;
    if (repo == null) return;
    final res = await repo.deleteVehicle(vehicleId);
    if (res.isSuccess) {
      await loadProfile();
    }
  }

  Future<void> addEmergencyContact(EmergencyContactModel contact) async {
    final repo = _repository;
    if (repo == null) return;
    final res = await repo.addEmergencyContact(contact);
    if (res.isSuccess) {
      await loadProfile();
    }
  }
}

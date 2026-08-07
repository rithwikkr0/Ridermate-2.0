import '../../../core/errors/result.dart';
import '../../auth/models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/emergency_contact_model.dart';
import '../../auth/services/mock_auth_service.dart';

abstract class UserRepository {
  Future<Result<UserModel>> getCurrentUser();
  Future<Result<UserModel>> updateProfile(UserModel updatedUser);
  Future<Result<List<VehicleModel>>> addVehicle(VehicleModel vehicle);
  Future<Result<List<VehicleModel>>> deleteVehicle(String vehicleId);
  Future<Result<List<EmergencyContactModel>>> addEmergencyContact(EmergencyContactModel contact);
}

class MockUserRepository implements UserRepository {
  UserModel _currentUser = MockAuthService.mockUser;

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    return Result.success(_currentUser);
  }

  @override
  Future<Result<UserModel>> updateProfile(UserModel updatedUser) async {
    _currentUser = updatedUser;
    return Result.success(_currentUser);
  }

  @override
  Future<Result<List<VehicleModel>>> addVehicle(VehicleModel vehicle) async {
    final updatedVehicles = [..._currentUser.vehicles, vehicle];
    _currentUser = UserModel(
      id: _currentUser.id,
      username: _currentUser.username,
      fullName: _currentUser.fullName,
      email: _currentUser.email,
      phone: _currentUser.phone,
      profilePhotoUrl: _currentUser.profilePhotoUrl,
      bio: _currentUser.bio,
      riderLevel: _currentUser.riderLevel,
      xp: _currentUser.xp,
      totalDistanceKm: _currentUser.totalDistanceKm,
      totalRides: _currentUser.totalRides,
      achievements: _currentUser.achievements,
      emergencyContacts: _currentUser.emergencyContacts,
      vehicles: updatedVehicles,
      preferences: _currentUser.preferences,
      createdAt: _currentUser.createdAt,
      updatedAt: DateTime.now(),
    );
    return Result.success(updatedVehicles);
  }

  @override
  Future<Result<List<VehicleModel>>> deleteVehicle(String vehicleId) async {
    final updatedVehicles = _currentUser.vehicles.where((v) => v.id != vehicleId).toList();
    _currentUser = UserModel(
      id: _currentUser.id,
      username: _currentUser.username,
      fullName: _currentUser.fullName,
      email: _currentUser.email,
      phone: _currentUser.phone,
      profilePhotoUrl: _currentUser.profilePhotoUrl,
      bio: _currentUser.bio,
      riderLevel: _currentUser.riderLevel,
      xp: _currentUser.xp,
      totalDistanceKm: _currentUser.totalDistanceKm,
      totalRides: _currentUser.totalRides,
      achievements: _currentUser.achievements,
      emergencyContacts: _currentUser.emergencyContacts,
      vehicles: updatedVehicles,
      preferences: _currentUser.preferences,
      createdAt: _currentUser.createdAt,
      updatedAt: DateTime.now(),
    );
    return Result.success(updatedVehicles);
  }

  @override
  Future<Result<List<EmergencyContactModel>>> addEmergencyContact(EmergencyContactModel contact) async {
    final updatedContacts = [..._currentUser.emergencyContacts, contact];
    _currentUser = UserModel(
      id: _currentUser.id,
      username: _currentUser.username,
      fullName: _currentUser.fullName,
      email: _currentUser.email,
      phone: _currentUser.phone,
      profilePhotoUrl: _currentUser.profilePhotoUrl,
      bio: _currentUser.bio,
      riderLevel: _currentUser.riderLevel,
      xp: _currentUser.xp,
      totalDistanceKm: _currentUser.totalDistanceKm,
      totalRides: _currentUser.totalRides,
      achievements: _currentUser.achievements,
      emergencyContacts: updatedContacts,
      vehicles: _currentUser.vehicles,
      preferences: _currentUser.preferences,
      createdAt: _currentUser.createdAt,
      updatedAt: DateTime.now(),
    );
    return Result.success(updatedContacts);
  }
}

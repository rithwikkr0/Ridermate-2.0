import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../models/user_model.dart';
import '../../profile/models/vehicle_model.dart';
import '../../profile/models/emergency_contact_model.dart';

abstract class AuthService {
  Future<Result<UserModel>> login(String email, String password);
  Future<Result<UserModel>> loginWithGoogle();
  Future<Result<UserModel>> register(String fullName, String email, String password, {String phone = '', String referralCode = ''});
  Future<Result<bool>> verifyOtp(String email, String otpCode);
  Future<Result<bool>> sendPhoneOtp(String phone);
  Future<Result<bool>> verifyPhoneOtp(String phone, String otpCode);
  Future<Result<bool>> sendPasswordReset(String email);
  Future<Result<void>> logout();
}

class MockAuthService implements AuthService {
  static final UserModel mockUser = UserModel(
    id: 'user-001',
    username: 'johnrider',
    fullName: 'John Rider',
    email: 'john@ridermate.app',
    phone: '+91 98765 43210',
    profilePhotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    bio: 'Avid touring rider & cornering enthusiast.',
    riderLevel: 'Elite Rider',
    xp: 8450,
    totalDistanceKm: 1248.0,
    totalRides: 42,
    achievements: const ['century_rider', 'dawn_patrol', 'iron_week'],
    emergencyContacts: [
      EmergencyContactModel(id: 'ec1', name: 'Ramesh Rider', relation: 'Father', phone: '+91 98765 43210', orderIndex: 0),
    ],
    vehicles: [
      VehicleModel(
        id: 'v1',
        brand: 'KTM',
        model: 'Duke 390',
        year: 2023,
        registrationNumber: 'MH-02-EQ-4589',
        fuelType: 'Petrol',
        engineCapacityCc: 373,
        color: 'Circuit Orange',
        serviceDueDate: DateTime.now().add(const Duration(days: 45)),
        isDefault: true,
      ),
    ],
    preferences: const UserPreferences(),
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    updatedAt: DateTime.now(),
  );

  @override
  Future<Result<UserModel>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.contains('error')) {
      return Result.failure(const NetworkError('Invalid credentials'));
    }
    return Result.success(mockUser);
  }

  @override
  Future<Result<UserModel>> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success(mockUser);
  }

  @override
  Future<Result<UserModel>> register(String fullName, String email, String password, {String phone = '', String referralCode = ''}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success(mockUser);
  }

  @override
  Future<Result<bool>> verifyOtp(String email, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (otpCode == '000000') return Result.failure(const ValidationError('Invalid OTP code'));
    return Result.success(true);
  }

  @override
  Future<Result<bool>> sendPhoneOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success(true);
  }

  @override
  Future<Result<bool>> verifyPhoneOtp(String phone, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (otpCode == '000000') return Result.failure(const ValidationError('Invalid OTP code'));
    return Result.success(true);
  }

  @override
  Future<Result<bool>> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success(true);
  }

  @override
  Future<Result<void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Result.success(null);
  }
}

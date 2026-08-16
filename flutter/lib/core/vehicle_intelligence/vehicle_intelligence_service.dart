import 'vehicle_registration_provider.dart';
import 'manual_vehicle_provider.dart';

// Service that tries provider lookup, falls back to null (user enters manually)
class VehicleIntelligenceService {
  final VehicleRegistrationProvider _provider;
  
  VehicleIntelligenceService({VehicleRegistrationProvider? provider})
    : _provider = provider ?? ManualVehicleProvider();
  
  Future<VehicleRegistrationData?> lookupVehicle(String regNumber) async {
    try {
      // Clean and normalize the registration number  
      final cleanReg = regNumber.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      return await _provider.lookupRegistration(cleanReg);
    } catch (e) {
      return null; // Fail gracefully, user enters manually
    }
  }
  
  // Validate Indian registration number format
  bool isValidIndianRegNumber(String reg) {
    // Format: XX00XX0000 or XX-00-XX-0000
    final pattern = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{4}$');
    return pattern.hasMatch(reg.toUpperCase().replaceAll(RegExp(r'[-\s]'), ''));
  }
}

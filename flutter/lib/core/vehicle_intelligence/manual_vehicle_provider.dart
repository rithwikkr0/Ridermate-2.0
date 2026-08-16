import 'vehicle_registration_provider.dart';

// ManualVehicleProvider — used when no API is available
// Returns null for all lookups, forcing user to enter manually
class ManualVehicleProvider implements VehicleRegistrationProvider {
  @override
  Future<VehicleRegistrationData?> lookupRegistration(String registrationNumber) async {
    // No API key configured — manual entry only
    return null;
  }
}

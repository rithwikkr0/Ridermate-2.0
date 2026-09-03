// Abstract provider for vehicle registration lookup
// In India, there's no free public API for RC data without government authorization.
// This provides a structured lookup with comprehensive motorcycle intelligence.
abstract class VehicleRegistrationProvider {
  Future<VehicleRegistrationData?> lookupRegistration(String registrationNumber);
}

class VehicleRegistrationData {
  final String registrationNumber;
  final String vehicleClass; 
  final String makerModel;
  final String fuelType;
  final String color;
  final int manufactureYear;
  final int engineCc;
  final String? insuranceExpiry;
  final String? pucExpiry;
  final String source;

  VehicleRegistrationData({
    required this.registrationNumber,
    required this.vehicleClass,
    required this.makerModel,
    required this.fuelType,
    required this.color,
    required this.manufactureYear,
    this.engineCc = 350,
    this.insuranceExpiry,
    this.pucExpiry,
    required this.source,
  });

  String get brand => makerModel.split(' ').first;
  String get modelName => makerModel.replaceFirst(brand, '').trim();
}

/// RiderMate 2.0 — Vehicle Model
class VehicleModel {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String registrationNumber;
  final String fuelType;
  final int engineCapacityCc;
  final String color;
  final DateTime serviceDueDate;
  final bool isDefault;

  const VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.registrationNumber,
    required this.fuelType,
    required this.engineCapacityCc,
    required this.color,
    required this.serviceDueDate,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'model': model,
        'year': year,
        'registrationNumber': registrationNumber,
        'fuelType': fuelType,
        'engineCapacityCc': engineCapacityCc,
        'color': color,
        'serviceDueDate': serviceDueDate.toIso8601String(),
        'isDefault': isDefault,
      };

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        registrationNumber: json['registrationNumber'] as String,
        fuelType: json['fuelType'] as String,
        engineCapacityCc: json['engineCapacityCc'] as int,
        color: json['color'] as String,
        serviceDueDate: DateTime.parse(json['serviceDueDate'] as String),
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

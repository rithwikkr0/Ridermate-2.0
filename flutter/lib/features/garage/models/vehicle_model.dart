import 'dart:convert';

/// RiderMate 2.0 — Production Vehicle Data Model
class VehicleModel {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final String variant;
  final int year;
  final String registrationNumber;
  final String fuelType;
  final int engineCc;
  final String color;
  final double odometerKm;
  final DateTime? purchaseDate;
  final DateTime? insuranceExpiry;
  final DateTime? pucExpiry;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final double lastServiceOdometer;
  final double serviceIntervalKm;
  final int serviceIntervalDays;
  final bool isDefault;
  final bool isPrimary;
  final List<Map<String, dynamic>> documents;
  final String notes;

  const VehicleModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    this.variant = '',
    required this.year,
    required this.registrationNumber,
    this.fuelType = 'Petrol',
    this.engineCc = 0,
    this.color = '',
    this.odometerKm = 0.0,
    this.purchaseDate,
    this.insuranceExpiry,
    this.pucExpiry,
    this.lastServiceDate,
    this.nextServiceDate,
    this.lastServiceOdometer = 0.0,
    this.serviceIntervalKm = 5000.0,
    this.serviceIntervalDays = 180,
    this.isDefault = false,
    this.isPrimary = false,
    this.documents = const [],
    this.notes = '',
  });

  /// Registration number with middle characters masked for privacy (e.g. KA01****34)
  String get maskedRegistrationNumber {
    final clean = registrationNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (clean.length <= 4) return clean;
    final prefix = clean.substring(0, 4);
    final suffix = clean.substring(clean.length - 2);
    return '$prefix****$suffix';
  }

  /// Real or inferred engine displacement in cc (never 0)
  int get displayEngineCc {
    if (engineCc > 0) return engineCc;
    final combined = '$brand $model'.toLowerCase();
    if (combined.contains('350')) return 349;
    if (combined.contains('himalayan') || combined.contains('450')) return 452;
    if (combined.contains('390')) return 373;
    if (combined.contains('650') || combined.contains('interceptor') || combined.contains('continental')) return 648;
    if (combined.contains('200') || combined.contains('ns200')) return 199;
    if (combined.contains('250')) return 248;
    if (combined.contains('150') || combined.contains('160') || combined.contains('mt-15') || combined.contains('r15')) return 155;
    return 350;
  }

  /// Calculates days remaining until insurance expires.
  int? get insuranceDaysRemaining {
    if (insuranceExpiry == null) return null;
    return insuranceExpiry!.difference(DateTime.now()).inDays;
  }

  /// Calculates days remaining until PUC expires.
  int? get pucDaysRemaining {
    if (pucExpiry == null) return null;
    return pucExpiry!.difference(DateTime.now()).inDays;
  }

  /// Calculates km remaining until next scheduled service due.
  double get serviceKmRemaining {
    final nextKm = lastServiceOdometer + serviceIntervalKm;
    final remaining = nextKm - odometerKm;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Calculates calculated next service date if not explicitly set.
  DateTime get calculatedNextServiceDate {
    if (nextServiceDate != null) return nextServiceDate!;
    final base = lastServiceDate ?? DateTime.now();
    return base.add(Duration(days: serviceIntervalDays));
  }

  bool get isInsuranceExpiringSoon =>
      insuranceDaysRemaining != null && insuranceDaysRemaining! <= 30 && insuranceDaysRemaining! >= 0;

  bool get isInsuranceExpired =>
      insuranceDaysRemaining != null && insuranceDaysRemaining! < 0;

  bool get isPucExpiringSoon =>
      pucDaysRemaining != null && pucDaysRemaining! <= 15 && pucDaysRemaining! >= 0;

  bool get isPucExpired =>
      pucDaysRemaining != null && pucDaysRemaining! < 0;

  bool get isServiceDue =>
      serviceKmRemaining <= 0 || DateTime.now().isAfter(calculatedNextServiceDate);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'variant': variant,
      'year': year,
      'registration_number': registrationNumber,
      'fuel_type': fuelType,
      'engine_cc': engineCc,
      'color': color,
      'odometer_km': odometerKm,
      'purchase_date': purchaseDate?.toIso8601String(),
      'insurance_expiry': insuranceExpiry?.toIso8601String(),
      'puc_expiry': pucExpiry?.toIso8601String(),
      'last_service_date': lastServiceDate?.toIso8601String(),
      'next_service_date': nextServiceDate?.toIso8601String(),
      'last_service_odometer': lastServiceOdometer,
      'service_interval_km': serviceIntervalKm,
      'service_interval_days': serviceIntervalDays,
      'is_default': isDefault ? 1 : 0,
      'is_primary': isPrimary ? 1 : 0,
      'documents_json': jsonEncode(documents),
      'notes': notes,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> parsedDocs = [];
    if (map['documents_json'] != null) {
      try {
        final decoded = jsonDecode(map['documents_json'] as String) as List;
        parsedDocs = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {}
    }
    
    return VehicleModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      model: map['model'] as String? ?? '',
      variant: map['variant'] as String? ?? '',
      year: (map['year'] as num? ?? 2024).toInt(),
      registrationNumber: map['registration_number'] as String? ?? '',
      fuelType: map['fuel_type'] as String? ?? 'Petrol',
      engineCc: (map['engine_cc'] as num? ?? 0).toInt(),
      color: map['color'] as String? ?? '',
      odometerKm: (map['odometer_km'] as num? ?? 0.0).toDouble(),
      purchaseDate: map['purchase_date'] != null ? DateTime.tryParse(map['purchase_date'] as String) : null,
      insuranceExpiry: map['insurance_expiry'] != null ? DateTime.tryParse(map['insurance_expiry'] as String) : null,
      pucExpiry: map['puc_expiry'] != null ? DateTime.tryParse(map['puc_expiry'] as String) : null,
      lastServiceDate: map['last_service_date'] != null ? DateTime.tryParse(map['last_service_date'] as String) : null,
      nextServiceDate: map['next_service_date'] != null ? DateTime.tryParse(map['next_service_date'] as String) : null,
      lastServiceOdometer: (map['last_service_odometer'] as num? ?? 0.0).toDouble(),
      serviceIntervalKm: (map['service_interval_km'] as num? ?? 5000.0).toDouble(),
      serviceIntervalDays: (map['service_interval_days'] as num? ?? 180).toInt(),
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      isPrimary: (map['is_primary'] as int? ?? 0) == 1,
      documents: parsedDocs,
      notes: map['notes'] as String? ?? '',
    );
  }

  VehicleModel copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    String? variant,
    int? year,
    String? registrationNumber,
    String? fuelType,
    int? engineCc,
    String? color,
    double? odometerKm,
    DateTime? purchaseDate,
    DateTime? insuranceExpiry,
    DateTime? pucExpiry,
    DateTime? lastServiceDate,
    DateTime? nextServiceDate,
    double? lastServiceOdometer,
    double? serviceIntervalKm,
    int? serviceIntervalDays,
    bool? isDefault,
    bool? isPrimary,
    List<Map<String, dynamic>>? documents,
    String? notes,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      variant: variant ?? this.variant,
      year: year ?? this.year,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      fuelType: fuelType ?? this.fuelType,
      engineCc: engineCc ?? this.engineCc,
      color: color ?? this.color,
      odometerKm: odometerKm ?? this.odometerKm,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      pucExpiry: pucExpiry ?? this.pucExpiry,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      lastServiceOdometer: lastServiceOdometer ?? this.lastServiceOdometer,
      serviceIntervalKm: serviceIntervalKm ?? this.serviceIntervalKm,
      serviceIntervalDays: serviceIntervalDays ?? this.serviceIntervalDays,
      isDefault: isDefault ?? this.isDefault,
      isPrimary: isPrimary ?? this.isPrimary,
      documents: documents ?? this.documents,
      notes: notes ?? this.notes,
    );
  }
}

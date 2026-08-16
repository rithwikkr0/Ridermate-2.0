import 'dart:convert';
export 'vehicle_model.dart';

/// RiderMate 2.0 — Fuel Log Model
class FuelRecord {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime date;
  final double liters;
  final double totalCost;
  final double odometerKm;
  final double calculatedMileageKmpl;

  const FuelRecord({
    required this.id,
    this.vehicleId = '',
    this.userId = '',
    required this.date,
    required this.liters,
    required this.totalCost,
    required this.odometerKm,
    required this.calculatedMileageKmpl,
  });
}

/// RiderMate 2.0 — Maintenance Record Data Model
class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String userId;
  final String serviceType;
  final DateTime date;
  final double odometer;
  final double cost;
  final String workshopName;
  final String notes;
  final List<String> partsReplaced;
  final DateTime createdAt;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.serviceType,
    required this.date,
    required this.odometer,
    required this.cost,
    this.workshopName = '',
    this.notes = '',
    this.partsReplaced = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'user_id': userId,
      'service_type': serviceType,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'cost': cost,
      'workshop': workshopName,
      'notes': notes,
      'parts_replaced_json': jsonEncode(partsReplaced),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    List<String> parts = [];
    if (map['parts_replaced_json'] != null && map['parts_replaced_json'] is String) {
      try {
        final decoded = jsonDecode(map['parts_replaced_json'] as String) as List<dynamic>;
        parts = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    return MaintenanceRecord(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      serviceType: map['service_type'] as String? ?? 'General Service',
      date: map['date'] != null ? DateTime.tryParse(map['date'] as String) ?? DateTime.now() : DateTime.now(),
      odometer: (map['odometer'] as num? ?? 0.0).toDouble(),
      cost: (map['cost'] as num? ?? 0.0).toDouble(),
      workshopName: map['workshop'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      partsReplaced: parts,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now() : DateTime.now(),
    );
  }
}

/// RiderMate 2.0 — Garage Reminder Data Model
class GarageReminder {
  final String id;
  final String vehicleId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isOverdue;
  final String category; // 'service', 'insurance', 'puc'

  const GarageReminder({
    required this.id,
    this.vehicleId = '',
    required this.title,
    required this.description,
    required this.dueDate,
    this.isOverdue = false,
    this.category = 'service',
  });
}

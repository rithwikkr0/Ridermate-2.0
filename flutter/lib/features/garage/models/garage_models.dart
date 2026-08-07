/// RiderMate 2.0 — Comprehensive Garage Models
class FuelRecord {
  final String id;
  final DateTime date;
  final double liters;
  final double totalCost;
  final double odometerKm;
  final double calculatedMileageKmpl;

  const FuelRecord({
    required this.id,
    required this.date,
    required this.liters,
    required this.totalCost,
    required this.odometerKm,
    required this.calculatedMileageKmpl,
  });
}

class MaintenanceRecord {
  final String id;
  final String title;
  final DateTime date;
  final double cost;
  final String workshopName;
  final List<String> partsReplaced;

  const MaintenanceRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.cost,
    required this.workshopName,
    required this.partsReplaced,
  });
}

class GarageReminder {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isOverdue;

  const GarageReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isOverdue = false,
  });
}

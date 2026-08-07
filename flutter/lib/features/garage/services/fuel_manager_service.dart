import '../models/garage_models.dart';

abstract class FuelManagerService {
  Future<List<FuelRecord>> getFuelLogs();
  Future<double> calculateAverageMileage();
}

class MockFuelManagerService implements FuelManagerService {
  final List<FuelRecord> _logs = [
    FuelRecord(id: 'f1', date: DateTime.now().subtract(const Duration(days: 7)), liters: 12.5, totalCost: 1320.0, odometerKm: 12480.0, calculatedMileageKmpl: 32.5),
    FuelRecord(id: 'f2', date: DateTime.now().subtract(const Duration(days: 14)), liters: 13.0, totalCost: 1370.0, odometerKm: 12070.0, calculatedMileageKmpl: 31.8),
  ];

  @override
  Future<List<FuelRecord>> getFuelLogs() async => List.unmodifiable(_logs);

  @override
  Future<double> calculateAverageMileage() async {
    if (_logs.isEmpty) return 0.0;
    final total = _logs.fold<double>(0.0, (sum, log) => sum + log.calculatedMileageKmpl);
    return double.parse((total / _logs.length).toStringAsFixed(1));
  }
}

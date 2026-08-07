import '../models/garage_models.dart';
import '../services/fuel_manager_service.dart';
import '../services/maintenance_service.dart';
import '../services/garage_reminder_engine.dart';

abstract class GarageRepository {
  Future<List<FuelRecord>> getFuelLogs();
  Future<List<MaintenanceRecord>> getServiceHistory();
  Future<List<GarageReminder>> getReminders();
}

class MockGarageRepository implements GarageRepository {
  final FuelManagerService fuelManager;
  final MaintenanceService maintenanceService;

  MockGarageRepository({required this.fuelManager, required this.maintenanceService});

  @override
  Future<List<FuelRecord>> getFuelLogs() => fuelManager.getFuelLogs();

  @override
  Future<List<MaintenanceRecord>> getServiceHistory() => maintenanceService.getServiceHistory();

  @override
  Future<List<GarageReminder>> getReminders() async => GarageReminderEngine.generateActiveReminders();
}

import '../../../core/errors/result.dart';
import '../models/garage_models.dart';
import '../services/fuel_manager_service.dart';
import '../services/maintenance_service.dart';
import '../services/garage_reminder_engine.dart';

abstract class GarageRepository {
  Future<Result<List<VehicleModel>>> getVehicles({required String userId});
  Future<Result<VehicleModel?>> getPrimaryVehicle({required String userId});
  Future<Result<VehicleModel>> saveVehicle(VehicleModel vehicle);
  Future<Result<bool>> deleteVehicle({required String id, required String userId});
  Future<Result<bool>> setPrimaryVehicle({required String id, required String userId});
  Future<Result<List<MaintenanceRecord>>> getServiceHistory({required String vehicleId, required String userId});
  Future<Result<MaintenanceRecord>> addMaintenanceRecord(MaintenanceRecord record);
  Future<Result<List<GarageReminder>>> getReminders({required String userId});

  // Legacy fallback getters for mock repository compatibility
  Future<List<FuelRecord>> getFuelLogs();
}

class MockGarageRepository implements GarageRepository {
  final FuelManagerService fuelManager;
  final MaintenanceService maintenanceService;

  MockGarageRepository({required this.fuelManager, required this.maintenanceService});

  @override
  Future<List<FuelRecord>> getFuelLogs() => fuelManager.getFuelLogs();

  @override
  Future<Result<List<VehicleModel>>> getVehicles({required String userId}) async {
    return Result.success([
      const VehicleModel(
        id: 'mock_v1',
        userId: 'user_guest',
        brand: 'Royal Enfield',
        model: 'Classic 350',
        year: 2023,
        registrationNumber: 'KA01AB1234',
        odometerKm: 12450.0,
        isPrimary: true,
      ),
    ]);
  }

  @override
  Future<Result<VehicleModel?>> getPrimaryVehicle({required String userId}) async {
    final v = await getVehicles(userId: userId);
    return Result.success(v.dataOrNull?.first);
  }

  @override
  Future<Result<VehicleModel>> saveVehicle(VehicleModel vehicle) async => Result.success(vehicle);

  @override
  Future<Result<bool>> deleteVehicle({required String id, required String userId}) async => Result.success(true);

  @override
  Future<Result<bool>> setPrimaryVehicle({required String id, required String userId}) async => Result.success(true);

  @override
  Future<Result<List<MaintenanceRecord>>> getServiceHistory({required String vehicleId, required String userId}) async {
    final history = await maintenanceService.getServiceHistory();
    return Result.success(history);
  }

  @override
  Future<Result<MaintenanceRecord>> addMaintenanceRecord(MaintenanceRecord record) async => Result.success(record);

  @override
  Future<Result<List<GarageReminder>>> getReminders({required String userId}) async {
    return Result.success(GarageReminderEngine.generateActiveReminders());
  }
}

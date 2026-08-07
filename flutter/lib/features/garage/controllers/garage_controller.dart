import '../../../providers/base_controller.dart';
import '../models/garage_models.dart';
import '../repositories/garage_repository.dart';

/// RiderMate 2.0 — Garage Controller
class GarageController extends BaseController {
  final GarageRepository repository;

  List<FuelRecord> fuelLogs = [];
  List<MaintenanceRecord> serviceHistory = [];
  List<GarageReminder> reminders = [];

  GarageController(this.repository) {
    loadGarageData();
  }

  double get totalServiceCost => serviceHistory.fold(0.0, (sum, rec) => sum + rec.cost);

  Future<void> loadGarageData() async {
    setState(ViewState.loading);
    fuelLogs = await repository.getFuelLogs();
    serviceHistory = await repository.getServiceHistory();
    reminders = await repository.getReminders();
    setState(ViewState.success);
  }
}

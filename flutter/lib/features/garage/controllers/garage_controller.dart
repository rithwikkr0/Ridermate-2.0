import 'dart:async';
import '../../../providers/base_controller.dart';
import '../../../core/services/shared_preferences_storage_service.dart';
import '../models/garage_models.dart';
import '../repositories/sqlite_garage_repository.dart';
import '../repositories/challan_repository.dart';
import '../repositories/sqlite_challan_repository.dart';
import '../models/challan_model.dart';
import '../models/vehicle_model.dart';
import '../services/garage_reminder_engine.dart';

/// RiderMate 2.0 — Production Garage Controller
class GarageController extends BaseController {
  final GarageRepository _repository;
  final ChallanRepository _challanRepository;
  final SharedPreferencesStorageService _storageService;

  List<VehicleModel> vehicles = [];
  VehicleModel? primaryVehicle;
  List<MaintenanceRecord> serviceHistory = [];
  List<GarageReminder> reminders = [];
  List<ChallanModel> challans = [];

  String _currentUserId = 'user_guest';
  bool _isDisposed = false;

  GarageController([
    GarageRepository? repository,
    ChallanRepository? challanRepository,
    SharedPreferencesStorageService? storageService,
  ])  : _repository = repository ?? SqliteGarageRepository(),
        _challanRepository = challanRepository ?? SqliteChallanRepository(),
        _storageService = storageService ?? SharedPreferencesStorageService() {
    _initAndLoad();
  }

  String get currentUserId => _currentUserId;

  Future<void> _initAndLoad() async {
    final uid = await _storageService.getString('user_id');
    if (uid != null && uid.isNotEmpty) {
      _currentUserId = uid;
    }
    await loadGarageData();
  }

  /// Re-initializes this controller for a new authenticated user.
  Future<void> refreshForUser(String userId) async {
    if (_isDisposed) return;
    _currentUserId = userId.isNotEmpty ? userId : 'user_guest';
    await loadGarageData();
  }

  double get totalServiceCost => serviceHistory.fold(0.0, (sum, rec) => sum + rec.cost);

  /// Loads vehicles, primary vehicle, service history, and active reminders.
  Future<void> loadGarageData() async {
    if (_isDisposed) return;
    setState(ViewState.loading);

    final vRes = await _repository.getVehicles(userId: _currentUserId);
    final pRes = await _repository.getPrimaryVehicle(userId: _currentUserId);
    final rRes = await _repository.getReminders(userId: _currentUserId);

    if (_isDisposed) return;

    if (vRes.isSuccess) {
      vehicles = vRes.dataOrNull ?? [];
      primaryVehicle = pRes.dataOrNull ?? (vehicles.isNotEmpty ? vehicles.first : null);
      reminders = rRes.dataOrNull ?? [];

      if (primaryVehicle != null) {
        final sRes = await _repository.getServiceHistory(
          vehicleId: primaryVehicle!.id,
          userId: _currentUserId,
        );
        serviceHistory = sRes.dataOrNull ?? [];
        await loadChallans(primaryVehicle!.id);
      } else {
        serviceHistory = [];
        challans = [];
      }

      setState(ViewState.success);

      // Check and dispatch due reminders to NotificationService
      GarageReminderEngine.instance.checkAndNotifyReminders(userId: _currentUserId);
    } else {
      setState(ViewState.error);
    }
  }

  /// Selects active vehicle for viewing details.
  Future<void> selectVehicle(VehicleModel vehicle) async {
    primaryVehicle = vehicle;
    final sRes = await _repository.getServiceHistory(
      vehicleId: vehicle.id,
      userId: _currentUserId,
    );
    serviceHistory = sRes.dataOrNull ?? [];
    await loadChallans(vehicle.id);
    if (!_isDisposed) notifyListeners();
  }

  /// Sets a vehicle as primary/default.
  Future<void> setPrimaryVehicle(String vehicleId) async {
    final res = await _repository.setPrimaryVehicle(id: vehicleId, userId: _currentUserId);
    if (res.isSuccess) {
      await loadGarageData();
    }
  }

  /// Adds or updates a vehicle record.
  Future<void> saveVehicle(VehicleModel vehicle) async {
    final toSave = vehicle.copyWith(userId: _currentUserId);
    final res = await _repository.saveVehicle(toSave);
    if (res.isSuccess) {
      await loadGarageData();
    }
  }

  /// Deletes a vehicle record.
  Future<void> deleteVehicle(String vehicleId) async {
    final res = await _repository.deleteVehicle(id: vehicleId, userId: _currentUserId);
    if (res.isSuccess) {
      await loadGarageData();
    }
  }

  /// Adds a maintenance/service record.
  Future<void> addMaintenanceRecord(MaintenanceRecord record) async {
    final toAdd = MaintenanceRecord(
      id: record.id.isNotEmpty ? record.id : 'maint_${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: record.vehicleId.isNotEmpty ? record.vehicleId : (primaryVehicle?.id ?? ''),
      userId: _currentUserId,
      serviceType: record.serviceType,
      date: record.date,
      odometer: record.odometer,
      cost: record.cost,
      workshopName: record.workshopName,
      notes: record.notes,
      partsReplaced: record.partsReplaced,
      createdAt: DateTime.now(),
    );

    final res = await _repository.addMaintenanceRecord(toAdd);
    if (res.isSuccess) {
      await loadGarageData();
    }
  }

  /// Loads challans for a vehicle
  Future<void> loadChallans(String vehicleId) async {
    final res = await _challanRepository.getChallansByVehicle(vehicleId);
    if (res.isSuccess) {
      challans = res.dataOrNull ?? [];
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Adds a new challan
  Future<void> addChallan(ChallanModel challan) async {
    final toAdd = challan.copyWith(userId: _currentUserId);
    final res = await _challanRepository.addChallan(toAdd);
    if (res.isSuccess && primaryVehicle != null) {
      await loadChallans(primaryVehicle!.id);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

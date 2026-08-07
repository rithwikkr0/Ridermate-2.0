import '../models/garage_models.dart';

abstract class MaintenanceService {
  Future<List<MaintenanceRecord>> getServiceHistory();
}

class MockMaintenanceService implements MaintenanceService {
  final List<MaintenanceRecord> _history = [
    MaintenanceRecord(
      id: 'm1',
      title: 'Full Periodic Service',
      date: DateTime.now().subtract(const Duration(days: 45)),
      cost: 4850.0,
      workshopName: 'KTM Pro-Biking Worli',
      partsReplaced: const ['Motul 7100 Engine Oil', 'Oil Filter', 'Brake Fluid Dot 4'],
    ),
  ];

  @override
  Future<List<MaintenanceRecord>> getServiceHistory() async => _history;
}

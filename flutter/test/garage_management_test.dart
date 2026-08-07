import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/features/garage/services/fuel_manager_service.dart';
import 'package:ridermate/features/garage/services/expense_calculator_service.dart';
import 'package:ridermate/features/garage/services/garage_reminder_engine.dart';

void main() {
  group('Garage Management Unit Tests', () {
    test('MockFuelManagerService calculates average mileage', () async {
      final fuelService = MockFuelManagerService();
      final mileage = await fuelService.calculateAverageMileage();
      expect(mileage, greaterThan(30.0));
    });

    test('ExpenseCalculatorService calculates cost per km correctly', () {
      final costPerKm = ExpenseCalculatorService.calculateCostPerKm(5000.0, 1000.0);
      expect(costPerKm, equals(5.0));
    });

    test('GarageReminderEngine generates active reminders', () {
      final reminders = GarageReminderEngine.generateActiveReminders();
      expect(reminders.length, equals(2));
      expect(reminders.first.title, contains('Insurance'));
    });
  });
}

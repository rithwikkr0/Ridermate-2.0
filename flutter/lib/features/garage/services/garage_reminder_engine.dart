import '../models/garage_models.dart';

class GarageReminderEngine {
  static List<GarageReminder> generateActiveReminders() {
    final now = DateTime.now();
    return [
      GarageReminder(
        id: 'r1',
        title: 'Insurance Renewal Due',
        description: 'Policy #POL-8942 expires in 14 days.',
        dueDate: now.add(const Duration(days: 14)),
      ),
      GarageReminder(
        id: 'r2',
        title: 'Chain Lubrication',
        description: 'Completed 480 km since last lube.',
        dueDate: now.add(const Duration(days: 2)),
      ),
    ];
  }
}

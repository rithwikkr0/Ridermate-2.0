import 'dart:async';
import '../../../core/notifications/services/notification_service.dart';
import '../models/garage_models.dart';
import '../repositories/sqlite_garage_repository.dart';

/// RiderMate 2.0 — Garage Service & Maintenance Reminder Engine
class GarageReminderEngine {
  static final GarageReminderEngine instance = GarageReminderEngine._();
  GarageReminderEngine._();

  final SqliteGarageRepository _repository = SqliteGarageRepository();

  /// Legacy static helper for tests
  static List<GarageReminder> generateActiveReminders() {
    final now = DateTime.now();
    return [
      GarageReminder(
        id: 'r1',
        title: 'Insurance Renewal',
        description: 'Vehicle insurance expires soon',
        dueDate: now.add(const Duration(days: 15)),
        category: 'insurance',
      ),
      GarageReminder(
        id: 'r2',
        title: 'Scheduled Service',
        description: 'Regular service due',
        dueDate: now.add(const Duration(days: 30)),
        category: 'service',
      ),
    ];
  }

  /// Evaluates vehicle service, insurance, and PUC status for the authenticated user
  /// and dispatches notifications via NotificationService if due.
  Future<void> checkAndNotifyReminders({required String userId}) async {
    if (userId.isEmpty || userId == 'user_guest') return;

    final remindersRes = await _repository.getReminders(userId: userId);
    if (remindersRes.isFailure || remindersRes.dataOrNull == null) return;

    final reminders = remindersRes.dataOrNull!;

    for (final reminder in reminders) {
      if (reminder.category == 'insurance') {
        await NotificationService.instance.notifyMaintenance(
          title: '📋 ${reminder.title}',
          body: reminder.description,
          vehicleId: reminder.vehicleId,
          userId: userId,
          cooldown: const Duration(hours: 24),
        );
      } else if (reminder.category == 'puc') {
        await NotificationService.instance.notifyMaintenance(
          title: '🌿 ${reminder.title}',
          body: reminder.description,
          vehicleId: reminder.vehicleId,
          userId: userId,
          cooldown: const Duration(hours: 24),
        );
      } else if (reminder.category == 'service') {
        await NotificationService.instance.notifyMaintenance(
          title: '🔧 ${reminder.title}',
          body: reminder.description,
          vehicleId: reminder.vehicleId,
          userId: userId,
          cooldown: const Duration(hours: 24),
        );
      }
    }
  }
}

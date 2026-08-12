import 'dart:async';
import '../../../providers/base_controller.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/shared_preferences_storage_service.dart';
import '../models/app_notification.dart';
import '../models/notification_preferences.dart';
import '../models/notification_type.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_service.dart';

/// RiderMate 2.0 — Production Notification System Controller
class NotificationController extends BaseController {
  final NotificationRepository _repository;
  final SharedPreferencesStorageService _storageService;

  List<AppNotification> notifications = [];
  int unreadCount = 0;
  NotificationPreferences? preferences;

  NotificationType? selectedFilter;
  bool unreadOnlyFilter = false;

  StreamSubscription<AppNotification>? _streamSub;
  String _currentUserId = 'user_guest';
  bool _isDisposed = false;

  NotificationController({
    NotificationRepository? repository,
    SharedPreferencesStorageService? storageService,
  })  : _repository = repository ?? SqliteNotificationRepository(),
        _storageService = storageService ?? SharedPreferencesStorageService() {
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final uid = await _storageService.getString('user_id');
    if (uid != null && uid.isNotEmpty) {
      _currentUserId = uid;
    }
    await loadPreferences();
    await loadNotifications();

    _streamSub?.cancel();
    _streamSub = NotificationService.instance.notificationStream.listen((newNotif) {
      if (newNotif.userId == _currentUserId) {
        loadNotifications();
      }
    });
  }

  String get currentUserId => _currentUserId;

  /// Loads notifications for current authenticated user with filter options.
  Future<void> loadNotifications() async {
    if (_isDisposed) return;
    setState(ViewState.loading);
    final res = await _repository.getNotifications(
      userId: _currentUserId,
      filterType: selectedFilter,
      unreadOnly: unreadOnlyFilter,
    );

    if (_isDisposed) return;

    if (res.isSuccess && res.data != null) {
      notifications = res.data!;
      await refreshUnreadCount();
      if (_isDisposed) return;
      setState(ViewState.success);
    } else {
      if (_isDisposed) return;
      setState(ViewState.error, error: StorageError(res.error?.message ?? 'Failed to load notifications'));
    }
  }

  /// Refreshes the unread counter.
  Future<void> refreshUnreadCount() async {
    final countRes = await _repository.getUnreadCount(userId: _currentUserId);
    if (countRes.isSuccess && countRes.data != null) {
      unreadCount = countRes.data!;
    }
  }

  /// Sets category filter chip selection.
  void setFilter(NotificationType? type) {
    selectedFilter = type;
    unreadOnlyFilter = false;
    loadNotifications();
  }

  /// Toggles unread-only filter.
  void setUnreadOnlyFilter(bool unreadOnly) {
    unreadOnlyFilter = unreadOnly;
    selectedFilter = null;
    loadNotifications();
  }

  /// Marks an individual notification as read.
  Future<void> markAsRead(String notificationId) async {
    final res = await _repository.markAsRead(id: notificationId, userId: _currentUserId);
    if (res.isSuccess && res.data == true) {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(readAt: DateTime.now());
      }
      await refreshUnreadCount();
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Marks all notifications as read for current user.
  Future<void> markAllAsRead() async {
    final res = await _repository.markAllAsRead(userId: _currentUserId);
    if (res.isSuccess) {
      final now = DateTime.now();
      notifications = notifications.map((n) => n.copyWith(readAt: now)).toList();
      unreadCount = 0;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Deletes a single notification record.
  Future<void> deleteNotification(String notificationId) async {
    final res = await _repository.deleteNotification(id: notificationId, userId: _currentUserId);
    if (res.isSuccess) {
      notifications.removeWhere((n) => n.id == notificationId);
      await refreshUnreadCount();
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Clears all notification history for current user.
  Future<void> clearAll() async {
    final res = await _repository.clearAllNotifications(userId: _currentUserId);
    if (res.isSuccess) {
      notifications.clear();
      unreadCount = 0;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Loads notification quiet settings preferences.
  Future<void> loadPreferences() async {
    final res = await _repository.getPreferences(userId: _currentUserId);
    if (res.isSuccess && res.data != null) {
      preferences = res.data!;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Saves updated notification preferences.
  Future<void> updatePreferences(NotificationPreferences newPrefs) async {
    final res = await _repository.savePreferences(newPrefs);
    if (res.isSuccess && res.data != null) {
      preferences = res.data!;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _streamSub?.cancel();
    super.dispose();
  }
}

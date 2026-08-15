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
///
/// Reactive state controller that drives:
///   - NotificationCenterScreen (list, filters, unread badge)
///   - NotificationBadge widget (unread count)
///   - NotificationSettingsScreen (preferences)
///
/// User isolation is enforced at every SQLite query via [_currentUserId].
/// Call [refreshForUser] after authentication state changes.
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

  String get currentUserId => _currentUserId;

  /// Initial load — reads userId from SharedPreferences, loads preferences
  /// and notifications, then subscribes to the real-time notification stream.
  Future<void> _initAndLoad() async {
    final uid = await _storageService.getString('user_id');
    if (uid != null && uid.isNotEmpty) {
      _currentUserId = uid;
    }
    await loadPreferences();
    await loadNotifications();
    _subscribeToStream();
  }

  /// Re-initializes this controller for a new authenticated user.
  ///
  /// Call this from AuthController after:
  ///   - Successful login (with the real user ID)
  ///   - Session restore (with the restored user ID)
  ///   - Logout (with 'user_guest' to clear state)
  Future<void> refreshForUser(String userId) async {
    if (_isDisposed) return;

    // Cancel existing stream subscription before switching user
    await _streamSub?.cancel();
    _streamSub = null;

    _currentUserId = userId.isNotEmpty ? userId : 'user_guest';

    // Reset filter state for clean slate
    selectedFilter = null;
    unreadOnlyFilter = false;

    await loadPreferences();
    await loadNotifications();
    _subscribeToStream();
  }

  /// Subscribes to the NotificationService broadcast stream.
  /// Reloads notifications when a new one arrives for the current user.
  void _subscribeToStream() {
    _streamSub?.cancel();
    _streamSub = NotificationService.instance.notificationStream.listen((newNotif) {
      if (!_isDisposed && newNotif.userId == _currentUserId) {
        loadNotifications();
      }
    });
  }

  /// Loads notifications for the current authenticated user.
  /// Applies active filter (type or unread-only).
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
      setState(
        ViewState.error,
        error: StorageError(res.error?.message ?? 'Failed to load notifications'),
      );
    }
  }

  /// Refreshes the unread count badge from SQLite.
  Future<void> refreshUnreadCount() async {
    if (_isDisposed) return;
    final countRes = await _repository.getUnreadCount(userId: _currentUserId);
    if (countRes.isSuccess && countRes.data != null && !_isDisposed) {
      unreadCount = countRes.data!;
      notifyListeners();
    }
  }

  /// Sets a category type filter. Clears unread-only filter.
  void setFilter(NotificationType? type) {
    if (_isDisposed) return;
    selectedFilter = type;
    unreadOnlyFilter = false;
    loadNotifications();
  }

  /// Toggles the unread-only filter. Clears type filter.
  void setUnreadOnlyFilter(bool unreadOnly) {
    if (_isDisposed) return;
    unreadOnlyFilter = unreadOnly;
    selectedFilter = null;
    loadNotifications();
  }

  /// Marks a single notification as read and updates the badge count.
  Future<void> markAsRead(String notificationId) async {
    if (_isDisposed) return;
    final res = await _repository.markAsRead(
      id: notificationId,
      userId: _currentUserId,
    );
    if (res.isSuccess && res.data == true) {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(readAt: DateTime.now());
      }
      await refreshUnreadCount();
    }
  }

  /// Marks all notifications as read for the current user.
  Future<void> markAllAsRead() async {
    if (_isDisposed) return;
    final res = await _repository.markAllAsRead(userId: _currentUserId);
    if (res.isSuccess) {
      final now = DateTime.now();
      notifications = notifications.map((n) => n.copyWith(readAt: now)).toList();
      unreadCount = 0;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Deletes a single notification and refreshes the badge count.
  Future<void> deleteNotification(String notificationId) async {
    if (_isDisposed) return;
    final res = await _repository.deleteNotification(
      id: notificationId,
      userId: _currentUserId,
    );
    if (res.isSuccess) {
      notifications.removeWhere((n) => n.id == notificationId);
      await refreshUnreadCount();
    }
  }

  /// Clears the entire notification history for the current user.
  Future<void> clearAll() async {
    if (_isDisposed) return;
    final res = await _repository.clearAllNotifications(userId: _currentUserId);
    if (res.isSuccess) {
      notifications.clear();
      unreadCount = 0;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Loads notification preferences from SQLite.
  Future<void> loadPreferences() async {
    if (_isDisposed) return;
    final res = await _repository.getPreferences(userId: _currentUserId);
    if (res.isSuccess && res.data != null && !_isDisposed) {
      preferences = res.data!;
      notifyListeners();
    }
  }

  /// Saves updated notification preferences to SQLite.
  Future<void> updatePreferences(NotificationPreferences newPrefs) async {
    if (_isDisposed) return;
    final res = await _repository.savePreferences(newPrefs);
    if (res.isSuccess && res.data != null && !_isDisposed) {
      preferences = res.data!;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _streamSub?.cancel();
    super.dispose();
  }
}

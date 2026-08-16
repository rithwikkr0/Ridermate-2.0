import 'dart:async';
import '../../../providers/base_controller.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/shared_preferences_storage_service.dart';
import '../models/emergency_timeline.dart';
import '../models/emergency_contact_model.dart';
import '../models/sos_event_model.dart';
import '../repositories/emergency_repository.dart';
import '../services/emergency_call_service.dart';
import '../services/emergency_sms_service.dart';
import '../services/emergency_sync_service.dart';
import '../../../core/notifications/services/notification_service.dart';

enum SosState { idle, countdown, activeEmergency, cancelled, resolved, failed }

/// RiderMate 2.0 — Production SOS & Emergency System Controller
class SosController extends BaseController {
  final EmergencyRepository _repository;
  final EmergencyCallService _callService;
  final EmergencySmsService _smsService;
  final EmergencySyncService _syncService;
  final DeviceLocationService _locationService;
  final SharedPreferencesStorageService _storageService;

  SosState sosState = SosState.idle;
  int countdownSeconds = 5;
  Timer? _countdownTimer;
  Timer? _locationTrackingTimer;

  SosEventModel? currentSosEvent;
  EmergencyContact? primaryContact;
  List<EmergencyContact> contacts = [];
  final EmergencyTimeline timeline = EmergencyTimeline();

  bool _isDisposed = false;
  String _cachedUserId = 'user_guest';
  String _cachedUserName = 'Rider';

  SosController({
    EmergencyRepository? repository,
    EmergencyCallService? callService,
    EmergencySmsService? smsService,
    EmergencySyncService? syncService,
    DeviceLocationService? locationService,
    SharedPreferencesStorageService? storageService,
  })  : _repository = repository ?? SqliteEmergencyRepository(),
        _callService = callService ?? const EmergencyCallService(),
        _smsService = smsService ?? const EmergencySmsService(),
        _syncService = syncService ??
            EmergencySyncService(
              repository: repository ?? SqliteEmergencyRepository(),
            ),
        _locationService = locationService ?? const DeviceLocationService(),
        _storageService = storageService ?? SharedPreferencesStorageService() {
    _initUserAndContacts();
  }

  Future<void> _initUserAndContacts() async {
    final uid = await _storageService.getString('user_id');
    final uname = await _storageService.getString('user_name');
    if (uid != null && uid.isNotEmpty) _cachedUserId = uid;
    if (uname != null && uname.isNotEmpty) _cachedUserName = uname;

    await loadContacts();
  }

  String get currentUserId => _cachedUserId;
  String get currentUserName => _cachedUserName;

  /// Updates the cached user and reloads emergency contacts from SQLite.
  void refreshForUser(String userId) {
    _cachedUserId = userId.isNotEmpty ? userId : 'user_guest';
    loadContacts();
  }

  /// Loads emergency contacts for the authenticated user from SQLite.
  Future<void> loadContacts() async {
    final res = await _repository.getContacts(userId: _cachedUserId);
    if (res.isSuccess && res.data != null) {
      contacts = res.data!;
      final primaryRes = await _repository.getPrimaryContact(userId: _cachedUserId);
      primaryContact = primaryRes.data;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Triggers the 5-second emergency countdown sequence.
  void triggerSos({String? rideId, double? rideDistanceKm, Duration? rideDuration}) {
    if (sosState == SosState.countdown || sosState == SosState.activeEmergency) return;

    sosState = SosState.countdown;
    countdownSeconds = 5;
    timeline.clear();
    timeline.logEvent('SOS Triggered', 'Manual trigger activated by rider', 'sos_icon');

    NotificationService.instance.notifyEmergency(
      title: 'RiderMate Emergency',
      body: 'SOS countdown initiated. Tap to open active emergency tracking.',
      rideId: rideId,
    );

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (countdownSeconds > 1) {
        countdownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _activateEmergencyMode(
          rideId: rideId,
          rideDistanceKm: rideDistanceKm,
          rideDuration: rideDuration,
        );
      }
    });
    setState(ViewState.loading);
  }

  /// Triggers immediate SOS without waiting for countdown.
  void triggerImmediateSos({
    String? rideId,
    double? rideDistanceKm,
    Duration? rideDuration,
    bool viaWhatsApp = false,
  }) {
    _countdownTimer?.cancel();
    _activateEmergencyMode(
      rideId: rideId,
      rideDistanceKm: rideDistanceKm,
      rideDuration: rideDuration,
      viaWhatsApp: viaWhatsApp,
    );
  }

  /// Cancels the SOS sequence during countdown.
  void cancelSos() {
    _countdownTimer?.cancel();
    _locationTrackingTimer?.cancel();

    if (currentSosEvent != null && currentSosEvent!.status == SosStatus.countdown) {
      final cancelledEvent = currentSosEvent!.copyWith(
        status: SosStatus.cancelled,
        cancelledAt: DateTime.now(),
      );
      _repository.updateSosEvent(cancelledEvent);
    }

    sosState = SosState.cancelled;
    timeline.logEvent('SOS Cancelled', 'Rider cancelled false alarm', 'cancel_icon');
    setState(ViewState.initial);
    if (!_isDisposed) notifyListeners();
  }

  /// Activates full emergency mode upon countdown completion or instant trigger.
  Future<void> _activateEmergencyMode({
    String? rideId,
    double? rideDistanceKm,
    Duration? rideDuration,
    bool viaWhatsApp = false,
  }) async {
    sosState = SosState.activeEmergency;
    setState(ViewState.loading);
    timeline.logEvent('Emergency Activated', 'Obtaining location & dispatching alerts', 'alert_icon');

    NotificationService.instance.notifyEmergency(
      title: 'RiderMate Emergency Active',
      body: 'SOS activated. Live emergency tracking & contacts alert active.',
      rideId: rideId,
    );

    // 1. Obtain best available GPS location
    double? lat;
    double? lng;
    double? accuracy;
    DateTime? locTime;

    try {
      final locRes = await _locationService.getCurrentLocation();
      if (locRes.isSuccess && locRes.data != null) {
        final loc = locRes.data!;
        lat = loc.latitude;
        lng = loc.longitude;
        accuracy = loc.accuracy;
        locTime = DateTime.fromMillisecondsSinceEpoch(loc.timestamp);
        timeline.logEvent(
          'GPS Location Acquired',
          'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)} (±${accuracy.toStringAsFixed(1)}m)',
          'location_icon',
        );
      }
    } catch (_) {}

    // Load latest contacts
    await loadContacts();
    final targetContact = primaryContact ?? (contacts.isNotEmpty ? contacts.first : null);

    // 2. Create canonical SOS event
    final String eventId = 'sos_${DateTime.now().millisecondsSinceEpoch}';
    final emergencyMessage = _smsService.buildEmergencyMessage(
      riderName: _cachedUserName,
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      emergencyContactName: targetContact?.name,
      emergencyContactPhone: targetContact?.phoneNumber,
      emergencyContactRelationship: targetContact?.relationship,
      rideDistanceKm: rideDistanceKm,
      rideDuration: rideDuration,
    );

    final event = SosEventModel(
      id: eventId,
      userId: _cachedUserId,
      rideId: rideId,
      status: SosStatus.active,
      latitude: lat,
      longitude: lng,
      accuracy: accuracy,
      locationTimestamp: locTime ?? DateTime.now(),
      startedAt: DateTime.now(),
      contactAttempts: [],
      message: emergencyMessage,
    );

    currentSosEvent = event;

    // 3. Save locally in SQLite (offline-first)
    await _repository.saveSosEvent(event);

    // 4. Contact emergency contact
    List<String> attempts = [];
    if (targetContact != null) {
      if (viaWhatsApp) {
        final waRes = await _smsService.sendWhatsApp(targetContact.phoneNumber, event.message);
        final waStatus = waRes.isSuccess ? 'WhatsApp dispatch launched' : 'WhatsApp launch failed';
        attempts.add('${targetContact.name} (${targetContact.phoneNumber}): $waStatus');
        timeline.logEvent('Emergency WhatsApp', '${targetContact.name} (${targetContact.phoneNumber})', 'sms_icon');
      } else {
        // Dispatch SMS Draft
        final smsRes = await _smsService.sendSms(targetContact.phoneNumber, event.message);
        final smsStatus = smsRes.isSuccess ? 'SMS draft launched' : 'SMS dispatch failed';
        attempts.add('${targetContact.name} (${targetContact.phoneNumber}): $smsStatus');
        timeline.logEvent('Emergency SMS', '${targetContact.name} (${targetContact.phoneNumber})', 'sms_icon');
      }

      // Next redirect to direct phone call
      final callRes = await _callService.placeCall(targetContact.phoneNumber);
      final callStatus = callRes.isSuccess ? 'Call initiated' : 'Call failed';
      attempts.add('${targetContact.name} (${targetContact.phoneNumber}): $callStatus');
      timeline.logEvent('Emergency Call', '${targetContact.name} (${targetContact.phoneNumber})', 'phone_icon');
    } else {
      timeline.logEvent('No Emergency Contact', 'No contacts configured by rider', 'warning_icon');
      attempts.add('No contacts configured');
    }

    // 5. Update SOS event with contact attempts
    final updatedEvent = event.copyWith(contactAttempts: attempts);
    currentSosEvent = updatedEvent;
    await _repository.updateSosEvent(updatedEvent);

    // 6. Sync to cloud (Firebase)
    _syncService.syncSosEvent(updatedEvent);

    // 7. Start periodic 15s location updates during emergency
    _startLiveLocationTracking();

    setState(ViewState.success);
    if (!_isDisposed) notifyListeners();
  }

  /// Dispatches instant draft SMS to primary emergency contact with live location and details,
  /// then immediately redirects to the phone call dialer.
  Future<void> dispatchEmergencyDraftAndCall({bool viaWhatsApp = false}) async {
    await loadContacts();
    final targetContact = primaryContact ?? (contacts.isNotEmpty ? contacts.first : null);
    if (targetContact == null) return;

    double? lat = currentSosEvent?.latitude;
    double? lng = currentSosEvent?.longitude;
    try {
      final locRes = await _locationService.getCurrentLocation();
      if (locRes.isSuccess && locRes.data != null) {
        lat = locRes.data!.latitude;
        lng = locRes.data!.longitude;
      }
    } catch (_) {}

    final msg = _smsService.buildEmergencyMessage(
      riderName: _cachedUserName,
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      emergencyContactName: targetContact.name,
      emergencyContactPhone: targetContact.phoneNumber,
      emergencyContactRelationship: targetContact.relationship,
    );

    if (viaWhatsApp) {
      await _smsService.sendWhatsApp(targetContact.phoneNumber, msg);
    } else {
      await _smsService.sendSms(targetContact.phoneNumber, msg);
    }

    await _callService.placeCall(targetContact.phoneNumber);
  }

  /// One-click draft SMS dispatch
  Future<void> dispatchSmsOnly() async {
    await loadContacts();
    final targetContact = primaryContact ?? (contacts.isNotEmpty ? contacts.first : null);
    if (targetContact == null) return;

    final msg = _smsService.buildEmergencyMessage(
      riderName: _cachedUserName,
      latitude: currentSosEvent?.latitude,
      longitude: currentSosEvent?.longitude,
      timestamp: DateTime.now(),
      emergencyContactName: targetContact.name,
      emergencyContactPhone: targetContact.phoneNumber,
      emergencyContactRelationship: targetContact.relationship,
    );
    await _smsService.sendSms(targetContact.phoneNumber, msg);
  }

  /// One-click WhatsApp dispatch
  Future<void> dispatchWhatsAppOnly() async {
    await loadContacts();
    final targetContact = primaryContact ?? (contacts.isNotEmpty ? contacts.first : null);
    if (targetContact == null) return;

    final msg = _smsService.buildEmergencyMessage(
      riderName: _cachedUserName,
      latitude: currentSosEvent?.latitude,
      longitude: currentSosEvent?.longitude,
      timestamp: DateTime.now(),
      emergencyContactName: targetContact.name,
      emergencyContactPhone: targetContact.phoneNumber,
      emergencyContactRelationship: targetContact.relationship,
    );
    await _smsService.sendWhatsApp(targetContact.phoneNumber, msg);
  }

  /// One-click direct call
  Future<void> dispatchCallOnly({String? overridePhone}) async {
    final phone = overridePhone ?? primaryContact?.phoneNumber ?? (contacts.isNotEmpty ? contacts.first.phoneNumber : '112');
    await _callService.placeCall(phone);
  }

  /// Starts live periodic GPS location tracking while emergency is active.
  void _startLiveLocationTracking() {
    _locationTrackingTimer?.cancel();
    _locationTrackingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (sosState != SosState.activeEmergency || currentSosEvent == null || _isDisposed) {
        _locationTrackingTimer?.cancel();
        return;
      }

      try {
        final locRes = await _locationService.getCurrentLocation();
        if (locRes.isSuccess && locRes.data != null) {
          final loc = locRes.data!;
          final updated = currentSosEvent!.copyWith(
            latitude: loc.latitude,
            longitude: loc.longitude,
            accuracy: loc.accuracy,
            locationTimestamp: DateTime.fromMillisecondsSinceEpoch(loc.timestamp),
          );
          currentSosEvent = updated;
          await _repository.updateSosEvent(updated);
          _syncService.syncSosEvent(updated);
          timeline.logEvent(
            'Location Updated',
            'Lat: ${loc.latitude.toStringAsFixed(5)}, Lng: ${loc.longitude.toStringAsFixed(5)}',
            'refresh_icon',
          );
          if (!_isDisposed) notifyListeners();
        }
      } catch (_) {}
    });
  }

  /// Resolves the emergency ("I'm Safe").
  Future<void> resolveEmergency() async {
    _locationTrackingTimer?.cancel();
    _countdownTimer?.cancel();

    if (currentSosEvent != null) {
      final resolvedEvent = currentSosEvent!.copyWith(
        status: SosStatus.completed,
        resolvedAt: DateTime.now(),
      );
      currentSosEvent = resolvedEvent;
      await _repository.updateSosEvent(resolvedEvent);
      await _syncService.syncSosEvent(resolvedEvent);
    }

    sosState = SosState.resolved;
    timeline.logEvent('Emergency Resolved', 'Rider marked safe', 'check_icon');
    setState(ViewState.initial);
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTimer?.cancel();
    _locationTrackingTimer?.cancel();
    super.dispose();
  }
}

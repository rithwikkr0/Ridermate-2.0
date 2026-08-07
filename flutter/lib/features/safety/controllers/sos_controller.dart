import 'dart:async';
import '../../../providers/base_controller.dart';
import '../models/emergency_timeline.dart';

enum SosState { idle, countdown, activeEmergency, cancelled, resolved }

/// RiderMate 2.0 — SOS System Controller
class SosController extends BaseController {
  SosState sosState = SosState.idle;
  int countdownSeconds = 5;
  Timer? _countdownTimer;
  final EmergencyTimeline timeline = EmergencyTimeline();

  void triggerSos() {
    sosState = SosState.countdown;
    countdownSeconds = 5;
    timeline.clear();
    timeline.logEvent('SOS Triggered', 'Manual trigger activated by rider', 'sos_icon');

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds > 1) {
        countdownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _activateEmergencyMode();
      }
    });
    setState(ViewState.loading);
  }

  void cancelSos() {
    _countdownTimer?.cancel();
    sosState = SosState.cancelled;
    timeline.logEvent('SOS Cancelled', 'Rider cancelled false alarm', 'cancel_icon');
    setState(ViewState.initial);
  }

  void _activateEmergencyMode() {
    sosState = SosState.activeEmergency;
    timeline.logEvent('Emergency Activated', 'Notifying emergency contacts via mock dispatch', 'alert_icon');
    timeline.logEvent('Contacts Notified', 'Ramesh Rider (+91 98765 43210)', 'phone_icon');
    setState(ViewState.success);
  }

  void resolveEmergency() {
    sosState = SosState.resolved;
    timeline.logEvent('Emergency Resolved', 'Rider marked safe', 'check_icon');
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

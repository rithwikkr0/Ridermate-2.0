import 'package:url_launcher/url_launcher.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';

/// RiderMate 2.0 — Real Android Emergency SMS Dispatch Service
class EmergencySmsService {
  const EmergencySmsService();

  /// Generates dynamic distress message
  String buildEmergencyMessage({
    required String riderName,
    required double? latitude,
    required double? longitude,
    required DateTime timestamp,
    double? rideDistanceKm,
    Duration? rideDuration,
  }) {
    final String locationStr = (latitude != null && longitude != null)
        ? 'https://maps.google.com/?q=$latitude,$longitude'
        : 'Location unavailable';

    final localTime = timestamp.toLocal();
    final timeStr = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    final buffer = StringBuffer()
      ..writeln('🚨 RIDERMATE EMERGENCY ALERT 🚨')
      ..writeln('Rider: $riderName')
      ..writeln('Time: $timeStr')
      ..writeln('Location: $locationStr');

    if (rideDistanceKm != null && rideDistanceKm > 0) {
      buffer.writeln('Ride Distance: ${rideDistanceKm.toStringAsFixed(1)} km');
    }

    buffer.write('Please check on rider immediately.');
    return buffer.toString();
  }

  /// Dispatches SMS distress message to [phoneNumber].
  Future<Result<bool>> sendSms(String phoneNumber, String message) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      return Result.failure(const ValidationError('Invalid emergency phone number'));
    }

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleaned,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    try {
      final canLaunch = await canLaunchUrl(smsUri);
      if (!canLaunch) {
        return Result.failure(const PermissionError('Device cannot send SMS'));
      }
      final launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );
      return Result.success(launched);
    } catch (e) {
      return Result.failure(NetworkError('Failed to dispatch SMS alert: $e'));
    }
  }
}

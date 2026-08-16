import 'package:url_launcher/url_launcher.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';

/// RiderMate 2.0 — Real Android Emergency SMS & WhatsApp Dispatch Service
class EmergencySmsService {
  const EmergencySmsService();

  /// Generates distress message with live location link, rider identity, and emergency contact details
  String buildEmergencyMessage({
    required String riderName,
    String? riderPhone,
    required double? latitude,
    required double? longitude,
    required DateTime timestamp,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
    double? rideDistanceKm,
    Duration? rideDuration,
  }) {
    final String locationUrl = (latitude != null && longitude != null)
        ? 'https://maps.google.com/?q=${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}'
        : 'Location unavailable';

    final localTime = timestamp.toLocal();
    final timeStr = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    final buffer = StringBuffer()
      ..writeln('🚨 RIDERMATE EMERGENCY DISTRESS ALERT 🚨')
      ..writeln('IN AN EMERGENCY! Please call or contact me immediately with my live location & details below.')
      ..writeln()
      ..writeln('👤 Rider: $riderName');

    if (riderPhone != null && riderPhone.isNotEmpty) {
      buffer.writeln('📞 Rider Phone: $riderPhone');
    }

    buffer.writeln('📍 Live Location: $locationUrl');
    if (latitude != null && longitude != null) {
      buffer.writeln('🗺 Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}');
    }
    buffer.writeln('⏰ Time: $timeStr');

    if (emergencyContactName != null && emergencyContactName.isNotEmpty) {
      buffer.writeln('🆘 Emergency Contact: $emergencyContactName (${emergencyContactRelationship ?? "Contact"}) $emergencyContactPhone');
    }

    if (rideDistanceKm != null && rideDistanceKm > 0) {
      buffer.writeln('🏍 Ride Distance: ${rideDistanceKm.toStringAsFixed(1)} km');
    }

    buffer.writeln();
    buffer.write('⚡ Please check on me or notify emergency responders immediately.');

    return buffer.toString();
  }

  /// Dispatches SMS distress message to [phoneNumber] via native draft SMS.
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
      final launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );
      return Result.success(launched);
    } catch (e) {
      return Result.failure(NetworkError('Failed to dispatch SMS alert: $e'));
    }
  }

  /// Dispatches WhatsApp distress message to [phoneNumber].
  Future<Result<bool>> sendWhatsApp(String phoneNumber, String message) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) {
      return Result.failure(const ValidationError('Invalid emergency phone number for WhatsApp'));
    }

    final encodedMsg = Uri.encodeComponent(message);
    final Uri waUri = Uri.parse('https://wa.me/$cleaned?text=$encodedMsg');

    try {
      final launched = await launchUrl(
        waUri,
        mode: LaunchMode.externalApplication,
      );
      return Result.success(launched);
    } catch (e) {
      return Result.failure(NetworkError('Failed to launch WhatsApp distress message: $e'));
    }
  }
}

import 'package:url_launcher/url_launcher.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';

/// RiderMate 2.0 — Real Android Emergency Call Service
class EmergencyCallService {
  const EmergencyCallService();

  /// Initiates an emergency phone call to [phoneNumber].
  Future<Result<bool>> placeCall(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      return Result.failure(const ValidationError('Invalid emergency phone number'));
    }

    final Uri callUri = Uri.parse('tel:$cleaned');
    try {
      final canLaunch = await canLaunchUrl(callUri);
      if (!canLaunch) {
        return Result.failure(const PermissionError('Device cannot place phone calls'));
      }
      final launched = await launchUrl(
        callUri,
        mode: LaunchMode.externalApplication,
      );
      return Result.success(launched);
    } catch (e) {
      return Result.failure(NetworkError('Failed to initiate phone call: $e'));
    }
  }
}

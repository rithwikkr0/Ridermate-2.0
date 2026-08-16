import '../../../core/network/azure_api_client.dart';
import 'package:flutter/foundation.dart';

class SafetyAssessment {
  final String riskLevel; // 'low', 'medium', 'high'
  final String safetyMessage;
  final List<String> tips;
  final String source; // 'azure' or 'local'

  SafetyAssessment({
    required this.riskLevel,
    required this.safetyMessage,
    required this.tips,
    required this.source,
  });
}

class AzureSafetyCoachService {
  final AzureApiClient _azureClient;

  AzureSafetyCoachService(this._azureClient);

  Future<SafetyAssessment?> analyzeSafetyProfile({
    required String userId,
    required double totalDistanceKm,
    required int totalRides,
    required double avgSpeedKmh,
    required double maxSpeedKmh,
    required int overspeedCount,
    required double safetyScore,
  }) async {
    try {
      final result = await _azureClient.analyzeSafety(
        rideId: 'profile_$userId',
        distanceKm: totalDistanceKm,
        durationMinutes: 0,
        maxSpeedKmh: maxSpeedKmh,
        averageSpeedKmh: avgSpeedKmh,
        safetyEvents: [{'type': 'overspeed', 'count': overspeedCount}],
      );

      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        return SafetyAssessment(
          riskLevel: data['riskLevel'] ?? _getLocalRiskLevel(safetyScore),
          safetyMessage: data['message'] ?? _getLocalMessage(safetyScore),
          tips: List<String>.from(data['tips'] ?? []),
          source: 'azure',
        );
      }
    } catch (e) {
      debugPrint('Azure Safety Coach API failed: $e');
    }

    // Fallback to local computation
    return SafetyAssessment(
      riskLevel: _getLocalRiskLevel(safetyScore),
      safetyMessage: _getLocalMessage(safetyScore),
      tips: ['Check your tire pressure', 'Always wear a helmet', 'Obey speed limits'],
      source: 'local',
    );
  }

  String _getLocalRiskLevel(double score) {
    if (score > 90) return 'low';
    if (score > 70) return 'medium';
    return 'high';
  }

  String _getLocalMessage(double score) {
    if (score > 90) return 'Excellent riding behavior';
    if (score > 70) return 'Good riding with room for improvement';
    return 'Safety violations detected, please review';
  }
}

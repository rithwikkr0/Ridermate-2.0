import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/result.dart';
import '../errors/app_error.dart';
import '../config/env_config.dart';

/// RiderMate 2.0 — Azure Function API Client
/// Encapsulates all network interaction with Microsoft Azure Functions.
/// Strictly offline-first: catches all socket/network exceptions and returns typed Results
/// to ensure local SQLite operations remain 100% functional even if cloud is unreachable.
class AzureApiClient {
  final http.Client _client;
  final EnvConfig config;

  AzureApiClient({
    http.Client? client,
    this.config = EnvConfig.dev,
  }) : _client = client ?? http.Client();

  String get _baseUrl {
    const envUrl = String.fromEnvironment('AZURE_API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    return config.azureApiBaseUrl;
  }

  String get _functionKey {
    return const String.fromEnvironment('AZURE_FUNCTION_KEY', defaultValue: '');
  }

  Map<String, String> _buildHeaders({String? authToken}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_functionKey.isNotEmpty) {
      headers['x-functions-key'] = _functionKey;
    }
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  /// Calls GET /api/health to verify Azure backend connectivity.
  Future<Result<Map<String, dynamic>>> checkHealth() async {
    if (_baseUrl.isEmpty) {
      return Result.failure(
        const NetworkError('Azure API base URL is not configured.', code: 'azure_unconfigured'),
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await _client
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.failure(
          NetworkError(
            'Azure health check failed with status code ${response.statusCode}',
            code: 'azure_http_${response.statusCode}',
          ),
        );
      }
    } on SocketException catch (e) {
      return Result.failure(
        NetworkError('Network unreachable: $e', code: 'network_unreachable'),
      );
    } on HttpException catch (e) {
      return Result.failure(
        NetworkError('HTTP protocol error: $e', code: 'http_error'),
      );
    } catch (e) {
      return Result.failure(
        NetworkError('Azure health check failed: $e', code: 'azure_unknown_error'),
      );
    }
  }

  /// Calls POST /api/safety/analyze to send ride summary for serverless cloud evaluation.
  Future<Result<Map<String, dynamic>>> analyzeSafety({
    required String rideId,
    required double distanceKm,
    required int durationMinutes,
    required double maxSpeedKmh,
    required double averageSpeedKmh,
    List<Map<String, dynamic>> safetyEvents = const [],
    String? authToken,
  }) async {
    if (_baseUrl.isEmpty) {
      return Result.failure(
        const NetworkError('Azure API base URL is not configured.', code: 'azure_unconfigured'),
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl/safety/analyze');
      final bodyPayload = json.encode({
        'rideId': rideId,
        'distanceKm': distanceKm,
        'durationMinutes': durationMinutes,
        'maxSpeedKmh': maxSpeedKmh,
        'averageSpeedKmh': averageSpeedKmh,
        'safetyEvents': safetyEvents,
      });

      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(authToken: authToken),
            body: bodyPayload,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.failure(
          NetworkError(
            'Azure safety analysis failed with status ${response.statusCode}',
            code: 'azure_http_${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      return Result.failure(
        NetworkError('Azure safety analysis failed: $e', code: 'azure_safety_error'),
      );
    }
  }

  void close() {
    _client.close();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/result.dart';
import '../errors/app_error.dart';
import '../config/env_config.dart';

abstract class NetworkService {
  Future<Result<Map<String, dynamic>>> get(String path, {Map<String, String>? headers, Map<String, dynamic>? queryParameters});
  Future<Result<Map<String, dynamic>>> post(String path, {Map<String, String>? headers, Map<String, dynamic>? body});
}

/// Real HTTP client pointing to the RiderMate REST API backend.
class HttpNetworkService implements NetworkService {
  final http.Client _client;
  final String _overrideBaseUrl;

  HttpNetworkService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _overrideBaseUrl = baseUrl ?? '';

  String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    return EnvConfig.prod.apiBaseUrl;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$baseUrl$cleanPath';
    final uri = Uri.parse(fullUrl);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return uri;
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (customHeaders != null) ...customHeaders,
    };
  }

  @override
  Future<Result<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return Result.success(<String, dynamic>{});
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return Result.success(decoded);
        return Result.success({'data': decoded});
      }

      return Result.failure(
        NetworkError(
          'HTTP ${response.statusCode}: ${response.body}',
          code: 'http_${response.statusCode}',
        ),
      );
    } on SocketException catch (e) {
      return Result.failure(
        NetworkError('Network unreachable (offline mode active): $e', code: 'offline'),
      );
    } on TimeoutException {
      return Result.failure(
        const NetworkError('Request timed out (15s).', code: 'timeout'),
      );
    } catch (e) {
      return Result.failure(
        NetworkError('Network request failed: $e', code: 'unknown_network_error'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(path);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return Result.success(<String, dynamic>{});
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return Result.success(decoded);
        return Result.success({'data': decoded});
      }

      return Result.failure(
        NetworkError(
          'HTTP ${response.statusCode}: ${response.body}',
          code: 'http_${response.statusCode}',
        ),
      );
    } on SocketException catch (e) {
      return Result.failure(
        NetworkError('Network unreachable (offline mode active): $e', code: 'offline'),
      );
    } on TimeoutException {
      return Result.failure(
        const NetworkError('Request timed out (15s).', code: 'timeout'),
      );
    } catch (e) {
      return Result.failure(
        NetworkError('Network request failed: $e', code: 'unknown_network_error'),
      );
    }
  }
}

/// Mock / offline simulation network service
class MockNetworkService implements NetworkService {
  @override
  Future<Result<Map<String, dynamic>>> get(String path, {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success({'status': 'ok', 'path': path, 'data': {}});
  }

  @override
  Future<Result<Map<String, dynamic>>> post(String path, {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success({'status': 'created', 'path': path, 'data': body ?? {}});
  }
}

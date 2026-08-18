import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/result.dart';
import '../errors/app_error.dart';
import '../config/env_config.dart';

/// RiderMate 2.0 — Azure Cloud API Client
/// Encapsulates all network interaction with the authenticated Azure Cloud backend.
/// Strictly offline-first: catches all socket/network exceptions and returns typed Results
/// to ensure local SQLite operations remain 100% functional even if cloud is unreachable.
class AzureApiClient {
  final http.Client _client;
  final EnvConfig config;

  AzureApiClient({
    http.Client? client,
    this.config = EnvConfig.prod,
  }) : _client = client ?? http.Client();

  String get _baseUrl {
    const envUrl = String.fromEnvironment('AZURE_API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    return config.azureApiBaseUrl;
  }

  String get _functionKey {
    return const String.fromEnvironment('AZURE_FUNCTION_KEY', defaultValue: '');
  }

  Map<String, String> _buildHeaders({String? authToken, String? idempotencyKey}) {
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
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['x-idempotency-key'] = idempotencyKey;
    }
    return headers;
  }

  // ── Health ─────────────────────────────────────────────────────────────
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

  // ── Auth ───────────────────────────────────────────────────────────────
  Future<Result<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
    String phone = '',
  }) async {
    return _post(
      '/v1/auth/register',
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'username': username,
        'phone': phone,
      },
    );
  }

  Future<Result<Map<String, dynamic>>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    return _post(
      '/v1/auth/login',
      body: {
        'email': emailOrUsername,
        'password': password,
      },
    );
  }

  Future<Result<Map<String, dynamic>>> getMe({required String authToken}) async {
    return _get('/v1/auth/me', authToken: authToken);
  }

  // ── Community ──────────────────────────────────────────────────────────
  Future<Result<Map<String, dynamic>>> createPost({
    required String type,
    required String caption,
    String mediaUrl = '',
    String? rideId,
    String? memoryId,
    String privacy = 'public',
    String? authToken,
    String? idempotencyKey,
  }) async {
    return _post(
      '/v1/community/posts',
      body: {
        'type': type,
        'caption': caption,
        'media_url': mediaUrl,
        'ride_id': rideId,
        'memory_id': memoryId,
        'privacy': privacy,
      },
      authToken: authToken,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<Result<List<dynamic>>> getFeed({
    int limit = 50,
    int offset = 0,
    String? authToken,
  }) async {
    return _getList('/v1/community/feed?limit=$limit&offset=$offset', authToken: authToken);
  }

  Future<Result<Map<String, dynamic>>> likePost({
    required String postId,
    required String authToken,
  }) async {
    return _post('/v1/community/posts/$postId/like', body: {}, authToken: authToken);
  }

  Future<Result<Map<String, dynamic>>> unlikePost({
    required String postId,
    required String authToken,
  }) async {
    return _delete('/v1/community/posts/$postId/like', authToken: authToken);
  }

  Future<Result<Map<String, dynamic>>> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
    required String authToken,
  }) async {
    return _post(
      '/v1/community/posts/$postId/comments',
      body: {
        'text': text,
        'parent_comment_id': parentCommentId,
      },
      authToken: authToken,
    );
  }

  Future<Result<Map<String, dynamic>>> savePost({
    required String postId,
    required String authToken,
  }) async {
    return _post('/v1/community/posts/$postId/save', body: {}, authToken: authToken);
  }

  Future<Result<Map<String, dynamic>>> unsavePost({
    required String postId,
    required String authToken,
  }) async {
    return _delete('/v1/community/posts/$postId/save', authToken: authToken);
  }

  // ── Friends & Squads ───────────────────────────────────────────────────
  Future<Result<Map<String, dynamic>>> sendFriendRequest({
    required String receiverId,
    required String authToken,
  }) async {
    return _post('/v1/friends/request', body: {'receiver_id': receiverId}, authToken: authToken);
  }

  Future<Result<Map<String, dynamic>>> acceptFriendRequest({
    required String requestId,
    required String authToken,
  }) async {
    return _post('/v1/friends/$requestId/accept', body: {}, authToken: authToken);
  }

  Future<Result<Map<String, dynamic>>> rejectFriendRequest({
    required String requestId,
    required String authToken,
  }) async {
    return _post('/v1/friends/$requestId/reject', body: {}, authToken: authToken);
  }

  Future<Result<Map<String, dynamic>>> createSquad({
    required String name,
    String description = '',
    bool isPrivate = false,
    String iconUrl = '',
    required String authToken,
  }) async {
    return _post(
      '/v1/squads/',
      body: {
        'name': name,
        'description': description,
        'is_private': isPrivate,
        'icon_url': iconUrl,
      },
      authToken: authToken,
    );
  }

  Future<Result<Map<String, dynamic>>> joinSquad({
    required String squadId,
    required String inviteCode,
    required String authToken,
  }) async {
    return _post(
      '/v1/squads/$squadId/join',
      body: {'invite_code': inviteCode},
      authToken: authToken,
    );
  }

  // ── Rides & Sync ───────────────────────────────────────────────────────
  Future<Result<Map<String, dynamic>>> syncRide({
    required Map<String, dynamic> rideData,
    required String authToken,
    String? idempotencyKey,
  }) async {
    return _post(
      '/v1/rides/sync',
      body: rideData,
      authToken: authToken,
      idempotencyKey: idempotencyKey,
    );
  }

  // ── Safety AI ──────────────────────────────────────────────────────────
  /// Calls POST /api/safety/analyze to send ride summary for cloud coaching.
  Future<Result<Map<String, dynamic>>> analyzeSafety({
    required String rideId,
    required double distanceKm,
    required int durationMinutes,
    required double maxSpeedKmh,
    required double averageSpeedKmh,
    List<Map<String, dynamic>> safetyEvents = const [],
    String? authToken,
  }) async {
    return _post(
      '/safety/analyze',
      body: {
        'rideId': rideId,
        'distanceKm': distanceKm,
        'durationMinutes': durationMinutes,
        'maxSpeedKmh': maxSpeedKmh,
        'averageSpeedKmh': averageSpeedKmh,
        'safetyEvents': safetyEvents,
      },
      authToken: authToken,
    );
  }

  // ── Internal Helpers ───────────────────────────────────────────────────
  Future<Result<Map<String, dynamic>>> _post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? authToken,
    String? idempotencyKey,
  }) async {
    if (_baseUrl.isEmpty) {
      return Result.failure(const NetworkError('Azure API base URL not configured.'));
    }
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(authToken: authToken, idempotencyKey: idempotencyKey),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.failure(
          NetworkError(
            'HTTP ${response.statusCode}: ${response.body}',
            code: 'http_${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      return Result.failure(NetworkError('Network request failed: $e'));
    }
  }

  Future<Result<Map<String, dynamic>>> _get(
    String endpoint, {
    String? authToken,
  }) async {
    if (_baseUrl.isEmpty) {
      return Result.failure(const NetworkError('Azure API base URL not configured.'));
    }
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _client
          .get(uri, headers: _buildHeaders(authToken: authToken))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.failure(NetworkError('HTTP ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      return Result.failure(NetworkError('Network request failed: $e'));
    }
  }

  Future<Result<List<dynamic>>> _getList(
    String endpoint, {
    String? authToken,
  }) async {
    if (_baseUrl.isEmpty) {
      return Result.failure(const NetworkError('Azure API base URL not configured.'));
    }
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _client
          .get(uri, headers: _buildHeaders(authToken: authToken))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return Result.success(data);
      } else {
        return Result.failure(NetworkError('HTTP ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      return Result.failure(NetworkError('Network request failed: $e'));
    }
  }

  Future<Result<Map<String, dynamic>>> _delete(
    String endpoint, {
    String? authToken,
  }) async {
    if (_baseUrl.isEmpty) {
      return Result.failure(const NetworkError('Azure API base URL not configured.'));
    }
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _client
          .delete(uri, headers: _buildHeaders(authToken: authToken))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.success(data);
      } else {
        return Result.failure(NetworkError('HTTP ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      return Result.failure(NetworkError('Network request failed: $e'));
    }
  }

  void close() {
    _client.close();
  }
}

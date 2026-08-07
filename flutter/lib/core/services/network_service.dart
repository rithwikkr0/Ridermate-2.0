import '../errors/result.dart';

abstract class NetworkService {
  Future<Result<Map<String, dynamic>>> get(String path, {Map<String, String>? headers, Map<String, dynamic>? queryParameters});
  Future<Result<Map<String, dynamic>>> post(String path, {Map<String, String>? headers, Map<String, dynamic>? body});
}

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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ridermate/core/network/azure_api_client.dart';
import 'package:ridermate/core/config/env_config.dart';

void main() {
  group('AzureApiClient Foundation & Offline Resilience Tests', () {
    test('checkHealth returns failure when base URL is unconfigured', () async {
      const emptyConfig = EnvConfig(
        environment: Environment.dev,
        apiBaseUrl: '',
        azureApiBaseUrl: '',
        supabaseUrl: '',
        supabaseAnonKey: '',
        mapTileServerUrl: '',
      );
      final client = AzureApiClient(config: emptyConfig);
      final result = await client.checkHealth();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, equals('azure_unconfigured'));
    });

    test('checkHealth parses 200 OK response from Azure Functions', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.path.endsWith('/health')) {
          return http.Response(
            '{"status":"ok","service":"ridermate-api","version":"1.0.0"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      const testConfig = EnvConfig(
        environment: Environment.dev,
        apiBaseUrl: '',
        azureApiBaseUrl: 'https://func-ridermate-api.azurewebsites.net/api',
        supabaseUrl: '',
        supabaseAnonKey: '',
        mapTileServerUrl: '',
      );

      final client = AzureApiClient(client: mockHttp, config: testConfig);
      final result = await client.checkHealth();

      expect(result.isSuccess, isTrue);
      final data = result.dataOrNull!;
      expect(data['status'], equals('ok'));
      expect(data['service'], equals('ridermate-api'));
    });

    test('analyzeSafety sends payload and returns structured analysis', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.path.endsWith('/safety/analyze')) {
          return http.Response(
            '{"riskLevel":"low","safetyAssessment":"Safe ride behavior observed","tips":["Maintain safe distance"]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      const testConfig = EnvConfig(
        environment: Environment.dev,
        apiBaseUrl: '',
        azureApiBaseUrl: 'https://func-ridermate-api.azurewebsites.net/api',
        supabaseUrl: '',
        supabaseAnonKey: '',
        mapTileServerUrl: '',
      );

      final client = AzureApiClient(client: mockHttp, config: testConfig);
      final result = await client.analyzeSafety(
        rideId: 'ride_1001',
        distanceKm: 15.2,
        durationMinutes: 25,
        maxSpeedKmh: 65.0,
        averageSpeedKmh: 36.5,
      );

      expect(result.isSuccess, isTrue);
      final data = result.dataOrNull!;
      expect(data['riskLevel'], equals('low'));
      expect(data['tips'], contains('Maintain safe distance'));
    });

    test('analyzeSafety catches network errors without crashing offline app', () async {
      final mockHttp = MockClient((request) async {
        throw Exception('Network unreachable');
      });

      const testConfig = EnvConfig(
        environment: Environment.dev,
        apiBaseUrl: '',
        azureApiBaseUrl: 'https://func-ridermate-api.azurewebsites.net/api',
        supabaseUrl: '',
        supabaseAnonKey: '',
        mapTileServerUrl: '',
      );

      final client = AzureApiClient(client: mockHttp, config: testConfig);
      final result = await client.analyzeSafety(
        rideId: 'ride_1002',
        distanceKm: 5.0,
        durationMinutes: 10,
        maxSpeedKmh: 40.0,
        averageSpeedKmh: 30.0,
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, equals('azure_safety_error'));
    });
  });
}

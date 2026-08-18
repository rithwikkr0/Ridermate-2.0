enum Environment { dev, staging, prod }

/// RiderMate 2.0 — Environment Configuration
class EnvConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String azureApiBaseUrl;
  final String azureFunctionKey;
  final String mapTileServerUrl;

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.azureApiBaseUrl = '',
    this.azureFunctionKey = '',
    required this.mapTileServerUrl,
  });

  static const EnvConfig dev = EnvConfig(
    environment: Environment.dev,
    apiBaseUrl: 'http://localhost:8000/api/v1',
    azureApiBaseUrl: 'https://app-ridermate-api.azurewebsites.net/api',
    azureFunctionKey: '',
    mapTileServerUrl: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const EnvConfig prod = EnvConfig(
    environment: Environment.prod,
    apiBaseUrl: 'https://app-ridermate-api.azurewebsites.net/api/v1',
    azureApiBaseUrl: 'https://app-ridermate-api.azurewebsites.net/api',
    azureFunctionKey: '',
    mapTileServerUrl: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
}

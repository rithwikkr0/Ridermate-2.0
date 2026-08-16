enum Environment { dev, staging, prod }

/// RiderMate 2.0 — Environment Configuration
class EnvConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String azureApiBaseUrl;
  final String azureFunctionKey;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String mapTileServerUrl;

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.azureApiBaseUrl = '',
    this.azureFunctionKey = '',
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.mapTileServerUrl,
  });

  static const EnvConfig dev = EnvConfig(
    environment: Environment.dev,
    apiBaseUrl: 'http://localhost:8000/api/v1',
    azureApiBaseUrl: 'http://10.0.2.2:7071/api',
    azureFunctionKey: '',
    supabaseUrl: 'https://dev.supabase.co',
    supabaseAnonKey: 'mock_dev_key',
    mapTileServerUrl: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const EnvConfig prod = EnvConfig(
    environment: Environment.prod,
    apiBaseUrl: 'https://api.ridermate.app/v1',
    azureApiBaseUrl: 'https://func-ridermate-api.azurewebsites.net/api',
    azureFunctionKey: '',
    supabaseUrl: 'https://prod.supabase.co',
    supabaseAnonKey: 'mock_prod_key',
    mapTileServerUrl: 'https://tiles.ridermate.app/{z}/{x}/{y}.png',
  );
}

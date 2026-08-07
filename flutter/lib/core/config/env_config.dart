enum Environment { dev, staging, prod }

/// RiderMate 2.0 — Environment Configuration
class EnvConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String mapTileServerUrl;

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.mapTileServerUrl,
  });

  static const EnvConfig dev = EnvConfig(
    environment: Environment.dev,
    apiBaseUrl: 'http://localhost:8000/api/v1',
    supabaseUrl: 'https://dev.supabase.co',
    supabaseAnonKey: 'mock_dev_key',
    mapTileServerUrl: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const EnvConfig prod = EnvConfig(
    environment: Environment.prod,
    apiBaseUrl: 'https://api.ridermate.app/v1',
    supabaseUrl: 'https://prod.supabase.co',
    supabaseAnonKey: 'mock_prod_key',
    mapTileServerUrl: 'https://tiles.ridermate.app/{z}/{x}/{y}.png',
  );
}

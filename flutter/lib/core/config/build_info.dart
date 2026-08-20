// RiderMate 2.0 — Build Info
// Values are injected at compile time via --dart-define.
// Fallback values are used if building without the build script.
class BuildInfo {
  static const String commit =
      String.fromEnvironment('BUILD_COMMIT', defaultValue: 'dev');

  static const String version =
      String.fromEnvironment('BUILD_VERSION', defaultValue: '2.0.0');

  static const String buildNumber =
      String.fromEnvironment('BUILD_NUMBER', defaultValue: '0');

  /// Human-readable label: "v2.0.0 build 12345678 (c5844db)"
  static String get label => 'v$version build $buildNumber ($commit)';

  /// Short label for in-app display
  static String get short => '$version+$buildNumber';
}

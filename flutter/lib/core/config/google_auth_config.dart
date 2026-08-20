// RiderMate 2.0 — Google Sign-In Configuration
// Replace PLACEHOLDER_WEB_CLIENT_ID with your actual Google Cloud Web OAuth client ID
// after completing the Google Cloud Console setup steps.
class GoogleAuthConfig {
  /// The Web OAuth Client ID from Google Cloud Console.
  /// Required for backend ID-token verification via google-auth.
  /// This MUST be the Web client ID, NOT the Android client ID.
  /// See: docs/google_signin_setup.md
  static const String serverClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');
}

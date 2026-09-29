/// RevenueCat configuration for RiderMate 2.0.
class RevenueCatConfig {
  RevenueCatConfig._();

  static const androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: '',
  );

  static const entitlementId = 'rider_pro';
  static const offeringId = 'default';
}

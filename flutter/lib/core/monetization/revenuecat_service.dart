import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenuecat_config.dart';

class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  bool _configured = false;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;
  bool get isConfigured => _configured;
  bool get isPro =>
      _customerInfo?.entitlements.active.containsKey(
        RevenueCatConfig.entitlementId,
      ) == true;

  Future<void> initialize() async {
    if (_configured) return;
    final key = RevenueCatConfig.androidApiKey.trim();
    if (key.isEmpty) {
      debugPrint('RevenueCat: missing Android public SDK key.');
      return;
    }
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(key));
    _configured = true;
    await refresh();
  }

  Future<void> identify(String userId) async {
    if (!_configured || userId.isEmpty || userId == 'user_guest') return;
    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;
      await refreshOfferings();
    } catch (e) {
      debugPrint('RevenueCat identify failed: $e');
    }
  }

  Future<void> logout() async {
    if (!_configured) return;
    try {
      _customerInfo = await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logout failed: $e');
    }
  }

  Future<void> refresh() async {
    if (!_configured) return;
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      await refreshOfferings();
    } catch (e) {
      debugPrint('RevenueCat refresh failed: $e');
    }
  }

  Future<void> refreshOfferings() async {
    if (!_configured) return;
    try {
      _offerings = await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCat offerings failed: $e');
    }
  }

  Future<CustomerInfo?> purchase(Package package) async {
    if (!_configured) return null;
    _customerInfo = await Purchases.purchasePackage(package);
    return _customerInfo;
  }

  Future<CustomerInfo?> restorePurchases() async {
    if (!_configured) return null;
    _customerInfo = await Purchases.restorePurchases();
    return _customerInfo;
  }
}

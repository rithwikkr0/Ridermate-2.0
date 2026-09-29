import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenuecat_service.dart';

class RevenueCatController extends ChangeNotifier {
  RevenueCatController(this.service);
  final RevenueCatService service;

  bool loading = false;
  String? error;

  bool get isPro => service.isPro;
  bool get isConfigured => service.isConfigured;
  Offerings? get offerings => service.offerings;

  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await service.initialize();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> identify(String userId) async {
    await service.identify(userId);
    notifyListeners();
  }

  Future<void> logout() async {
    await service.logout();
    notifyListeners();
  }

  Future<void> purchase(Package package) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await service.purchase(package);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await service.restorePurchases();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../core/errors/app_error.dart';

enum ViewState { initial, loading, success, error }

/// RiderMate 2.0 — Base Controller State Management
abstract class BaseController extends ChangeNotifier {
  ViewState _state = ViewState.initial;
  AppError? _error;

  ViewState get state => _state;
  AppError? get error => _error;
  bool get isLoading => _state == ViewState.loading;

  void setState(ViewState newState, {AppError? error}) {
    _state = newState;
    _error = error;
    notifyListeners();
  }
}

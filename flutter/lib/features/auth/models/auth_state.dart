import 'user_model.dart';
import '../../../core/errors/app_error.dart';

enum AuthStatus { unauthenticated, registering, otpVerification, loggedIn, sessionExpired, loading, error }

/// RiderMate 2.0 — Authentication State Representation
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final AppError? error;

  const AuthState({
    required this.status,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.loggedIn(UserModel user, String token) => AuthState(status: AuthStatus.loggedIn, user: user, accessToken: token);
  factory AuthState.error(AppError err) => AuthState(status: AuthStatus.error, error: err);
}

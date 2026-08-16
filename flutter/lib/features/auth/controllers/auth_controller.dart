import 'dart:math';
import '../../../providers/base_controller.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../services/mock_auth_service.dart';
import '../services/session_service.dart';
import '../../profile/repositories/sqlite_user_repository.dart';
import '../../../core/services/database_service.dart';

// Callback type — receives the authenticated userId, or 'user_guest' on logout
typedef UserChangedCallback = void Function(String userId);

/// RiderMate 2.0 — Auth Controller
class AuthController extends BaseController {
  final AuthService authService;
  final SessionService sessionService;
  final DatabaseService? databaseService;

  /// Optional callback invoked after every auth state change.
  /// Wire to NotificationController.refreshForUser in main.dart.
  UserChangedCallback? onUserChanged;

  AuthState stateModel = AuthState.unauthenticated();

  AuthController(
    this.authService,
    this.sessionService, {
    this.databaseService,
    this.onUserChanged,
  });

  // ── Session restore on cold start ───────────────────────────────────────

  Future<void> restoreSession() async {
    setState(ViewState.loading);
    stateModel = AuthState.loading();

    try {
      final userId = await sessionService.getUserId();
      final token = await sessionService.getAccessToken();

      if (userId == null || token == null) {
        final demoUser = UserModel.guest();
        stateModel = AuthState.loggedIn(demoUser, 'demo_token');
        onUserChanged?.call(demoUser.id);
        setState(ViewState.success);
        return;
      }

      // Load the user from the real database
      if (databaseService != null) {
        final repo = SqliteUserRepository(
          databaseService!,
          userId: userId,
        );
        final result = await repo.getCurrentUser();
        if (result.isSuccess && result.dataOrNull != null) {
          stateModel = AuthState.loggedIn(result.dataOrNull!, token);
          onUserChanged?.call(userId);
          setState(ViewState.success);
          return;
        }
      }

      // Session exists but user not loadable — clear it
      await sessionService.clearSession();
      stateModel = AuthState.unauthenticated();
      setState(ViewState.initial);
    } catch (_) {
      stateModel = AuthState.unauthenticated();
      setState(ViewState.initial);
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    setState(ViewState.loading);
    stateModel = AuthState.loading();
    final result = await authService.login(email, password);

    if (result.isSuccess) {
      final user = result.dataOrNull!;
      final token = _generateToken(user.id);
      await sessionService.saveSession(
        accessToken: token,
        refreshToken: token,
        userId: user.id,
      );
      stateModel = AuthState.loggedIn(user, token);
      onUserChanged?.call(user.id);
      setState(ViewState.success);
    } else {
      stateModel = AuthState.error(result.errorOrNull!);
      setState(ViewState.error, error: result.errorOrNull!);
    }
  }

  // ── Register ─────────────────────────────────────────────────────────────

  Future<void> register(
      String fullName, String email, String password) async {
    setState(ViewState.loading);
    stateModel = AuthState.loading();
    final result = await authService.register(fullName, email, password);

    if (result.isSuccess) {
      final user = result.dataOrNull!;
      final token = _generateToken(user.id);
      await sessionService.saveSession(
        accessToken: token,
        refreshToken: token,
        userId: user.id,
      );
      stateModel = AuthState.loggedIn(user, token);
      onUserChanged?.call(user.id);
      setState(ViewState.success);
    } else {
      stateModel = AuthState.error(result.errorOrNull!);
      setState(ViewState.error, error: result.errorOrNull!);
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await sessionService.clearSession();
    await authService.logout();
    onUserChanged?.call('user_guest');
    stateModel = AuthState.unauthenticated();
    setState(ViewState.initial);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get isLoggedIn => stateModel.status == AuthStatus.loggedIn;
  UserModel? get currentUser => stateModel.user;

  static String _generateToken(String userId) {
    final rng = Random.secure();
    final bytes = List<int>.generate(24, (_) => rng.nextInt(256));
    final random = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'rm_${userId}_$random';
  }
}

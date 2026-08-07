import '../../../providers/base_controller.dart';
import '../models/auth_state.dart';
import '../services/mock_auth_service.dart';
import '../services/session_service.dart';

/// RiderMate 2.0 — Auth Controller
class AuthController extends BaseController {
  final AuthService authService;
  final SessionService sessionService;

  AuthState stateModel = AuthState.unauthenticated();

  AuthController(this.authService, this.sessionService);

  Future<void> login(String email, String password) async {
    setState(ViewState.loading);
    stateModel = AuthState.loading();
    final result = await authService.login(email, password);

    if (result.isSuccess) {
      final user = result.dataOrNull!;
      const token = 'mock_jwt_access_token_12345';
      await sessionService.saveSession(
        accessToken: token,
        refreshToken: 'mock_refresh_token_67890',
        userId: user.id,
      );
      stateModel = AuthState.loggedIn(user, token);
      setState(ViewState.success);
    } else {
      stateModel = AuthState.error(result.errorOrNull!);
      setState(ViewState.error, error: result.errorOrNull!);
    }
  }

  Future<void> logout() async {
    await sessionService.clearSession();
    await authService.logout();
    stateModel = AuthState.unauthenticated();
    setState(ViewState.initial);
  }
}

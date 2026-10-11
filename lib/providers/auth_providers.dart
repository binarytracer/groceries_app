import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groceries_app/services/api_client.dart';
import 'package:groceries_app/services/auth_api_service.dart';
import 'package:groceries_app/services/auth_session.dart';
import 'package:groceries_app/services/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(createBareClient()),
);

final authSessionProvider = Provider<AuthSession>(
  (ref) => AuthSession(
    ref.watch(tokenStorageProvider),
    ref.watch(authApiServiceProvider),
  ),
);

/// Whether the user is signed in. Loading while a stored session is restored.
class AuthNotifier extends AsyncNotifier<bool> {
  AuthSession get _session => ref.read(authSessionProvider);

  @override
  Future<bool> build() {
    _session.onExpired = () => state = const AsyncData(false);
    return _session.restore();
  }

  Future<void> login(String username, String password) async {
    await _session.login(username, password);
    state = const AsyncData(true);
  }

  Future<void> logout() async {
    await _session.logout();
    state = const AsyncData(false);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

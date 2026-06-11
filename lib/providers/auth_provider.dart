import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import 'service_providers.dart';

/// Streams the current [AppUser] (null = signed out).
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges();
});

/// Convenience: the resolved user or null while loading.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Imperative auth actions (sign-in / up / out) with a loading flag.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._auth) : super(const AsyncValue.data(null));

  final AuthService _auth;

  Future<bool> signIn(String email, String password) =>
      _run(() => _auth.signInWithEmail(email, password));

  Future<bool> signUp(String email, String password, String name) =>
      _run(() => _auth.signUpWithEmail(email, password, name));

  Future<bool> signInWithGoogle() => _run(_auth.signInWithGoogle);

  Future<bool> continueAsGuest() => _run(_auth.continueAsGuest);

  Future<void> signOut() => _auth.signOut();

  Future<bool> _run(Future<Object?> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

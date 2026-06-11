import 'dart:async';

import '../models/app_user.dart';

/// Auth contract used by the app. Two implementations exist:
///  - [MockAuthService] (default, no Firebase needed)
///  - [FirebaseAuthService] (real, see firebase_auth_service.dart)
abstract class AuthService {
  /// Emits the current user (or null when signed out).
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );

  Future<AppUser> signInWithGoogle();

  /// Enters browse-only guest mode.
  Future<AppUser> continueAsGuest();

  Future<void> signOut();
}

/// In-memory auth for demos and tests. Accepts any credentials.
class MockAuthService implements AuthService {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  void _emit(AppUser? user) {
    _current = user;
    _controller.add(user);
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = AppUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
      photoUrl: 'https://ui-avatars.com/api/?name=${email.split('@').first}'
          '&background=FF5A3C&color=fff',
    );
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = AppUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: displayName,
      photoUrl: 'https://ui-avatars.com/api/?name=$displayName'
          '&background=FF5A3C&color=fff',
    );
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    const user = AppUser(
      uid: 'mock_google',
      email: 'foodie@gmail.com',
      displayName: 'Google Foodie',
      photoUrl: 'https://ui-avatars.com/api/?name=Google+Foodie'
          '&background=FF5A3C&color=fff',
    );
    _emit(user);
    return user;
  }

  @override
  Future<AppUser> continueAsGuest() async {
    final guest = AppUser.guest();
    _emit(guest);
    return guest;
  }

  @override
  Future<void> signOut() async => _emit(null);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

/// Live [AuthService] backed by Firebase Auth + a `users/{uid}` Firestore
/// profile document. Activated when [AppConfig.useMockBackend] is false.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _google;

  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        _current = null;
        return null;
      }
      _current = await _loadOrCreateProfile(user);
      return _current;
    });
  }

  Future<AppUser> _loadOrCreateProfile(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) {
      return AppUser.fromMap(user.uid, snap.data()!);
    }
    final profile = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName ?? user.email?.split('@').first ?? 'Foodie',
      photoUrl: user.photoURL,
    );
    await ref.set(profile.toMap());
    return profile;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _loadOrCreateProfile(cred.user!);
  }

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);
    return _loadOrCreateProfile(cred.user!);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'aborted',
        message: 'Google sign-in was cancelled.',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return _loadOrCreateProfile(cred.user!);
  }

  @override
  Future<AppUser> continueAsGuest() async {
    final cred = await _auth.signInAnonymously();
    final guest = AppUser(uid: cred.user!.uid, displayName: 'Guest', isGuest: true);
    _current = guest;
    return guest;
  }

  @override
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
    _current = null;
  }
}

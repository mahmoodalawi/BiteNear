import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_config.dart';
import '../services/auth_service.dart';
import '../services/catalog_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/location_service.dart';

/// Wires concrete service implementations into the provider graph.
///
/// Selecting mock vs. live happens here based on [AppConfig.useMockBackend],
/// so the rest of the app depends only on the abstractions.

final authServiceProvider = Provider<AuthService>((ref) {
  return AppConfig.useMockBackend ? MockAuthService() : FirebaseAuthService();
});

final catalogServiceProvider = Provider<CatalogService>((ref) {
  // CatalogService is mock-backed today; swap for a Firestore-backed
  // implementation when going live (the method surface matches).
  return CatalogService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Resolved during app bootstrap (see main.dart) so reads are synchronous.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main()');
});

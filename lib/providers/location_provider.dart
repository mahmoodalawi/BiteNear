import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';
import 'service_providers.dart';

/// Resolves the user's current location once (falls back to a demo location
/// when GPS/permission is unavailable). Refresh by invalidating the provider.
final currentLocationProvider = FutureProvider<LatLngPoint>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentLocation();
});

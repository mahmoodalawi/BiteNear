import 'package:geolocator/geolocator.dart';

import 'mock_data.dart';

/// Simple lat/lng pair used app-wide so the UI doesn't depend on the
/// geolocator package's [Position] type directly.
class LatLngPoint {
  final double latitude;
  final double longitude;
  const LatLngPoint(this.latitude, this.longitude);
}

/// Wraps `geolocator` for permission handling and one-shot location reads.
///
/// In demo/mock mode (or when permission is denied / no GPS), this falls back
/// to [MockData.userLat]/[MockData.userLng] so the app always has a usable
/// "current location".
class LocationService {
  /// Requests permission and returns the current position, or the demo
  /// fallback when location is unavailable.
  Future<LatLngPoint> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _fallback;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallback;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      return LatLngPoint(pos.latitude, pos.longitude);
    } catch (_) {
      // Emulators / web without GPS land here — keep the app usable.
      return _fallback;
    }
  }

  /// Triggers the OS permission dialog (used during onboarding).
  Future<bool> requestPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  LatLngPoint get _fallback =>
      const LatLngPoint(MockData.userLat, MockData.userLng);
}

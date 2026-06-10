import 'package:url_launcher/url_launcher.dart';

/// Opens external Google Maps directions to a destination.
class MapsLauncher {
  MapsLauncher._();

  /// Launches turn-by-turn directions to [lat]/[lng] in the Google Maps app
  /// (or browser fallback).
  static Future<bool> directionsTo(
    double lat,
    double lng, {
    String? label,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng'
      '&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Dials a phone number.
  static Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) return launchUrl(uri);
    return false;
  }
}

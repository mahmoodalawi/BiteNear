import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/app_config.dart';
import 'providers/service_providers.dart';
import 'services/firebase_bootstrap.dart';

/// App entry point.
///
/// Bootstraps SharedPreferences (always) and Firebase (only when running
/// against the live backend), then launches the app with the provider graph.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.useMockBackend) {
    await FirebaseBootstrap.init();
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Make prefs available synchronously throughout the app.
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const BiteNearApp(),
    ),
  );
}

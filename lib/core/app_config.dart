/// Compile-time-ish toggles for how the app sources its data.
///
/// The MVP ships with [useMockBackend] = true so it runs immediately with no
/// Firebase project. Flip it to false (and add your `firebase_options.dart`)
/// to switch Auth/Firestore to the live implementations. See README → Backend
/// modes.
class AppConfig {
  AppConfig._();

  /// When true, Auth + catalog are served from in-memory mock data.
  /// Can be overridden at build time:
  ///   flutter run --dart-define=USE_MOCK=false
  static const bool useMockBackend =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);
}

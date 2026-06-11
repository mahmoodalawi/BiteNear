import 'package:firebase_core/firebase_core.dart';

/// Initializes Firebase for the live backend.
///
/// On Android/iOS this reads the native `google-services.json` /
/// `GoogleService-Info.plist`. For web (or to pin options explicitly), run
/// `flutterfire configure` to generate `lib/firebase_options.dart`, then pass
/// `options: DefaultFirebaseOptions.currentPlatform` below.
///
/// Kept in its own file so `main.dart` never imports the (gitignored)
/// generated options when running in mock mode.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<void> init() async {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // uncomment after
      // running `flutterfire configure`.
    );
  }
}

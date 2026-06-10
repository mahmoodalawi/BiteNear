# 🍽️ BiteNear

**Discover dishes, not just restaurants.**

BiteNear flips food discovery around: instead of searching for a restaurant and
digging through its menu, you search for the **dish or drink** you're craving
(“matcha”, “shawarma”, “keto bowl”) and BiteNear shows every nearby place that
serves it — with dish-level ratings, prices, distance, and one-tap directions.

> Built with Flutter + Riverpod + Firebase. Ships with a rich in-memory demo
> dataset so it runs end-to-end with **zero backend setup**.

---

## ✨ Features

| Area | What's included |
|------|-----------------|
| **Onboarding** | 3 value-prop slides, skip option, location-permission step |
| **Auth** | Email/password, Google Sign-In, and guest (browse-only) mode |
| **Home** | “What are you craving?” search, quick-filter chips, *Nearby Right Now* carousel, trending list |
| **Search** | Dish search, sort (nearest / top-rated / price), filters (radius, price, dietary), **list ⇄ map toggle** |
| **Dish detail** | Hero photo, price, dietary tags, restaurant link, **Get Directions**, dish-level reviews + write-review |
| **Restaurant profile** | Cover/logo, **Menu / Reviews / Info** tabs, categorized menu, hours, call/directions |
| **Map** | Full-screen Google Map, dish pins, tap-for-preview bottom sheet, “Search this area” |
| **Profile** | Saved dishes, review count, settings, sign out |
| **Restaurant dashboard** | Menu CRUD (add/edit/delete) + dish analytics (views, search hits) |

---

## 🏗️ Architecture

Clean, layered, and feature-first:

```
models  →  services  →  providers (Riverpod)  →  features/widgets (UI)
```

- **models/** – plain Dart data classes (`Dish`, `Restaurant`, `Review`, …)
- **services/** – data sources & integrations (auth, catalog, location, Firestore)
- **providers/** – Riverpod state: auth, search, favorites, reviews, location
- **features/** – one folder per screen, each with its own `widgets/`
- **widgets/** – shared, reusable UI (cards, rating stars, sheets, map)
- **core/** – theme, constants, utils, routing, app config

See [`CLAUDE.md`](./CLAUDE.md) for a full directory map and conventions.

### State management
[Riverpod](https://riverpod.dev) throughout. Services are injected via
`Provider`s in `lib/providers/service_providers.dart`, so swapping
implementations (mock ⇄ Firebase) happens in exactly one place.

### Routing
[go_router](https://pub.dev/packages/go_router) with a `StatefulShellRoute`
bottom-nav shell (Home / Map / Saved / Profile) and auth + onboarding redirects.

---

## 🚀 Getting started

### Prerequisites
- Flutter **3.27+** (stable channel), Dart **3.6+**
- An IDE with the Flutter plugin (VS Code / Android Studio)

### Run the demo (no backend needed)

This repo contains the Dart source (`lib/`, `test/`). Generate the platform
folders, fetch packages, and run:

```bash
# 1. Generate android/, ios/, web/ etc. (keeps existing lib/)
flutter create .

# 2. Install dependencies
flutter pub get

# 3. Run — defaults to the in-memory mock backend
flutter run
```

The app boots straight into onboarding → auth (use **any** email/password, or
“Browse as guest”) → home feed, all served from `lib/services/mock_data.dart`.

### Run the tests

```bash
flutter test
```

---

## 🔌 Backend modes

BiteNear has a single toggle in `lib/core/app_config.dart`:

```dart
static const bool useMockBackend = bool.fromEnvironment('USE_MOCK', defaultValue: true);
```

| Mode | How | Data source |
|------|-----|-------------|
| **Mock** (default) | just run | `MockData` + `MockAuthService` (in-memory) |
| **Live** | `flutter run --dart-define=USE_MOCK=false` | Firebase Auth + Firestore |

Because the UI depends only on the service *abstractions*, no screen code
changes between modes.

---

## 🔥 Firebase setup (live mode)

1. **Create a project** at <https://console.firebase.google.com> and enable
   **Authentication** (Email/Password, Google, Anonymous) and **Firestore**.

2. **Wire up the apps** with the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` (git-ignored) and the native
   config files. A template is provided at `lib/firebase_options.dart.example`.

3. **Enable explicit options** in `lib/services/firebase_bootstrap.dart`:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

4. **Deploy security rules & indexes** (provided under `firebase/`):
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

### Firestore data model
```
users/{uid}                     → AppUser profile
restaurants/{restaurantId}      → Restaurant (GeoPoint `location`, `ownerId`)
dishes/{dishId}                 → Dish (flat collection; `restaurantId`, `nameLower`)
reviews/{reviewId}              → Review (`dishId`, `restaurantId`, `userId`)
```
> Geo-search in this MVP filters client-side. For production, add a geohash
> field and use `geoflutterfire` (noted in `FirestoreService`).

---

## 🗺️ Google Maps setup

The map view and pins use
[`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter). Add a
Maps SDK API key per platform (the app still runs without one — tiles render
blank but all logic works):

- **Android** — `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <manifest ...>
    <application ...>
      <meta-data android:name="com.google.android.geo.API_KEY"
                 android:value="YOUR_ANDROID_MAPS_KEY"/>
  ```
- **iOS** — `ios/Runner/AppDelegate.swift`:
  ```swift
  GMSServices.provideAPIKey("YOUR_IOS_MAPS_KEY")
  ```

### Location permissions
`geolocator` requires platform permission strings:
- **Android** — add `ACCESS_FINE_LOCATION` to `AndroidManifest.xml`.
- **iOS** — add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist`.

---

## 📁 Project layout (short)

```
lib/
├── main.dart                 # bootstrap (prefs, optional Firebase)
├── app.dart                  # MaterialApp.router + theme
├── core/                     # theme, constants, utils, router, app_config
├── models/                   # Dish, Restaurant, Review, AppUser, enums…
├── services/                 # auth, catalog, location, firestore, mock_data
├── providers/                # Riverpod providers
├── features/                 # onboarding, auth, home, search, dish, restaurant,
│                             # map, profile, dashboard, shell
└── widgets/                  # shared UI (cards, rating, sheets, map)
firebase/                     # firestore.rules, firestore.indexes.json
test/                         # unit tests
```

Full conventions and a per-folder guide live in **[CLAUDE.md](./CLAUDE.md)**.

---

## 🧭 Tech stack

Flutter · Riverpod · go_router · Firebase (Auth/Firestore) · google_maps_flutter
· geolocator · google_fonts · cached_network_image · url_launcher

---

## 📄 License

Released under the MIT License — see `LICENSE` (add one before publishing).

# CLAUDE.md

Guidance for AI assistants (and humans) working in the **BiteNear** codebase.
Read this before making changes — it captures the architecture, conventions,
and workflows that keep the project consistent.

---

## 1. What this app is

BiteNear is a **Flutter** food-discovery app. The core idea: users search by
**dish/drink** (“matcha”, “shawarma”), not by restaurant. The app geolocates
the user and surfaces every nearby place serving that item, with dish-level
ratings, prices, distance, and directions. Restaurants manage their menus via a
dashboard.

- **UI:** Flutter (Material 3, custom warm “food-app” theme)
- **State:** Riverpod (`flutter_riverpod`)
- **Routing:** `go_router`
- **Backend:** Firebase (Auth + Firestore) — **optional**; a mock backend is the
  default so the app runs with no setup.
- **Maps/location:** `google_maps_flutter`, `geolocator`

---

## 2. Build & run commands

```bash
flutter create .          # one-time: generate android/ios/web platform folders
flutter pub get           # fetch dependencies
flutter run               # run in MOCK mode (default, no backend)
flutter run --dart-define=USE_MOCK=false   # run against live Firebase
flutter test              # run unit tests
flutter analyze           # static analysis (must stay clean)
dart format lib test      # format before committing
```

> ⚠️ The repo intentionally commits only `lib/`, `test/`, and config. Platform
> folders (`android/`, `ios/`, `web/`) are generated with `flutter create .`.
> Don't hand-author them unless adding platform-specific native config.

---

## 3. Architecture & layering

Strict one-directional dependency flow. **Never** import “up” the stack.

```
core/ ───────────────┐  (theme, constants, utils — no app logic deps)
models/ ─────────────┤  depends on: core
services/ ───────────┤  depends on: models, core
providers/ ──────────┤  depends on: services, models, core   ← Riverpod wiring
features/ + widgets/ ┘  depends on: providers, models, core   ← UI only
```

Rules of thumb:
- **UI never talks to a service directly.** It reads/writes through a provider.
- **Services never import Flutter widgets** or Riverpod. They're pure Dart.
- **Models are plain data classes** with `fromMap`/`toMap`. No business logic,
  no Flutter imports (except `cloud_firestore` for `GeoPoint`/`Timestamp`).
- Swapping a data source (mock ⇄ Firebase) happens **only** in
  `lib/providers/service_providers.dart`.

---

## 4. Directory map

```
lib/
├── main.dart                      # Entry: init prefs, optional Firebase, ProviderScope
├── app.dart                       # BiteNearApp → MaterialApp.router
│
├── core/
│   ├── app_config.dart            # useMockBackend toggle (USE_MOCK dart-define)
│   ├── constants/app_constants.dart
│   ├── theme/                     # app_colors, app_text_styles, app_theme
│   └── utils/                     # formatters (distance/price/haversine), maps_launcher
│
├── models/                        # dish, restaurant, review, app_user, enums, dish_result
│
├── services/
│   ├── auth_service.dart          # AuthService abstract + MockAuthService
│   ├── firebase_auth_service.dart # FirebaseAuthService (live)
│   ├── catalog_service.dart       # CatalogService (mock-backed dish queries + SearchFilters)
│   ├── firestore_service.dart     # FirestoreService (live reads/writes)
│   ├── location_service.dart      # geolocator wrapper + LatLngPoint
│   ├── firebase_bootstrap.dart    # Firebase.initializeApp (live mode only)
│   └── mock_data.dart             # in-memory demo dataset (SF-based)
│
├── providers/                     # Riverpod providers (see §6)
│
├── features/                      # one folder per screen; local widgets/ subfolder
│   ├── onboarding/  auth/  home/  search/  dish/
│   ├── restaurant/  map/  profile/  dashboard/  shell/
│
├── widgets/                       # shared UI: dish_card, rating_stars, dish_image,
│                                  # favorite_button, filter/preview/review sheets, results_map…
│
└── router/                        # routes.dart (AppRoute enum) + app_router.dart (GoRouter)
```

---

## 5. Routing (`lib/router/`)

- **`routes.dart`** — `AppRoute` enum is the single source of truth for paths +
  names. Always navigate by name: `context.pushNamed(AppRoute.dishDetail.name, …)`.
- **`app_router.dart`** — builds the `GoRouter` via `routerProvider`.
  - Bottom-nav tabs use a `StatefulShellRoute.indexedStack`
    (Home / Map / Saved / Profile).
  - Full-screen pages (search, dish detail, restaurant profile, dashboard) are
    pushed above the shell via `parentNavigatorKey: _rootKey`.
  - `RouterNotifier` bridges `authStateProvider` + `onboardingSeenProvider` into
    GoRouter's `redirect`/`refreshListenable`.

**Redirect logic:** onboarding (if unseen) → login (if no session; guest counts)
→ app. Add new routes to **both** the `AppRoute` enum and the `routes` list.

---

## 6. State management (Riverpod)

All providers live in `lib/providers/`. Key ones:

| Provider | Type | Purpose |
|----------|------|---------|
| `service_providers.dart` | `Provider` | DI for auth/catalog/location + `sharedPrefsProvider` (overridden in `main`) |
| `authStateProvider` | `StreamProvider<AppUser?>` | current session |
| `authControllerProvider` | `StateNotifierProvider` | sign in/up/out actions + loading |
| `currentLocationProvider` | `FutureProvider<LatLngPoint>` | user location (falls back to demo) |
| `searchQueryProvider` / `searchFiltersProvider` | `StateProvider` | search inputs |
| `nearbyFeedProvider` / `searchResultsProvider` | `FutureProvider<List<DishResult>>` | feeds |
| `dishResultProvider(id)` | `FutureProvider.family` | one dish + restaurant + distance |
| `favoritesProvider` | `StateNotifierProvider<…, Set<String>>` | persisted favorites |
| `dishReviewsProvider(id)` | `StateNotifierProvider.family` | reviews (seeded from mock) |
| `menuEditorProvider(id)` | `StateNotifierProvider.family` | dashboard menu CRUD |
| `onboardingSeenProvider` | `StateNotifierProvider<…, bool>` | onboarding flag |

Conventions:
- Widgets that read providers extend `ConsumerWidget` / `ConsumerStatefulWidget`.
- Use `ref.watch` in `build`, `ref.read` for one-off actions/callbacks.
- Don't mutate a `StateProvider` during `build` — defer with
  `WidgetsBinding.instance.addPostFrameCallback` (see `SearchResultsScreen`).
- `sharedPrefsProvider` **must** be overridden in `main()`; it throws otherwise.

---

## 7. Data model cheat-sheet

- **`Dish`** — menu item. Has `category` (`DishCategory`: food/drinks/desserts),
  `dietaryTags`, aggregate `rating`/`reviewCount`, and analytics `views`/
  `searchHits`. `toMap()` writes a denormalized `nameLower` for prefix search.
- **`Restaurant`** — `location` (lat/lng), `cuisine`, `hours` map, aggregates.
- **`Review`** — dish-level (`dishId` + `restaurantId`), `rating` 1–5.
- **`AppUser`** — decoupled from FirebaseAuth; supports `isGuest` and
  `isRestaurantOwner` / `ownedRestaurantId`.
- **`DishResult`** — view-model pairing a `Dish` + `Restaurant` + `distanceKm`.
  This is what feeds/search/map render — prefer it over raw `Dish` in UI.

---

## 8. Mock vs. live backend

- Toggle: `AppConfig.useMockBackend` (default `true`; override with
  `--dart-define=USE_MOCK=false`).
- **Mock path:** `MockAuthService` + `CatalogService` (reads `MockData`).
  Reviews/menu edits live in in-memory `StateNotifier`s.
- **Live path:** `FirebaseAuthService` + `FirestoreService`. Requires
  `flutterfire configure` and enabling `options:` in `firebase_bootstrap.dart`.
- The two implementations share method surfaces so **UI/provider code is
  identical** across modes. When adding a data operation, add it to **both** the
  mock and live services (or the relevant abstraction).

---

## 9. Theming & UI conventions

- Colors: `AppColors` (warm tomato primary `#FF5A3C`, saffron, mint). Never
  hard-code hex in widgets — add to `AppColors`.
- Type: `AppTextStyles` (Poppins display, Inter body via `google_fonts`).
- Global theme: `AppTheme.light` (Material 3). Rounded corners (16–24px),
  soft shadows, pill chips. Match this aesthetic for new UI.
- Images: always render network images through `DishImage` (handles
  loading/error placeholders) — never raw `Image.network`.
- Reusable pieces go in `lib/widgets/`; screen-specific ones in that feature's
  `widgets/` subfolder.
- Use `withValues(alpha: …)` (Flutter 3.27+), **not** the deprecated
  `withOpacity`.

---

## 10. Conventions & style

- **Lints:** `flutter_lints` via `analysis_options.yaml`. Keep `flutter analyze`
  clean. Prefer `const` constructors and single quotes.
- **Comments:** English, explain *why* not *what*; doc-comment (`///`) public
  classes and non-obvious logic. Match the existing density.
- **Naming:** files `snake_case.dart`; types `PascalCase`; members
  `camelCase`; private `_prefixed`.
- **Navigation:** always `AppRoute.<x>.name`, never raw path strings.
- **No secrets in VCS:** `firebase_options.dart`, `google-services.json`,
  `GoogleService-Info.plist`, and Maps keys are git-ignored.

---

## 11. Where to make common changes

| I want to… | Go to |
|------------|-------|
| Add a screen | new folder in `features/`, register in `routes.dart` + `app_router.dart` |
| Add demo data | `lib/services/mock_data.dart` |
| Change search/filter logic | `lib/services/catalog_service.dart` (`SearchFilters`, `search`) |
| Add a filter/sort option | `models/enums.dart` + `catalog_service.dart` + `filter_sheet.dart` |
| Tweak colors/typography | `core/theme/` |
| Add a Firestore read/write | `services/firestore_service.dart` (+ mock equivalent) |
| Add app-wide state | new provider in `lib/providers/` |
| Change quick filters / radius defaults | `core/constants/app_constants.dart` |

---

## 12. Testing

- Unit tests in `test/` (see `widget_test.dart`): cover `Formatters`,
  `CatalogService` search/sort/filter, and model serialization.
- Prefer testing **services and pure logic** — they have no Flutter/Firebase
  deps and run fast. Use `CatalogService` + `MockData` directly.
- Run `flutter test` before committing logic changes.

---

## 13. Gotchas

- The app **always has a location**: if GPS/permission is unavailable,
  `LocationService` falls back to the demo coordinates (SF Ferry Building). Don't
  assume real GPS in tests.
- Google Maps tiles are blank without an API key, but markers/logic still work —
  this is expected in demo runs.
- `sharedPrefsProvider` throws unless overridden in `main()` — keep the override.
- Two providers must stay in sync when adding data ops: mock service **and**
  Firestore service.
- When editing routing, update the `AppRoute` enum **and** the route table.

---

_Keep this file current: when you add a screen, provider, service, or convention,
update the relevant section so the next contributor (human or AI) stays aligned._

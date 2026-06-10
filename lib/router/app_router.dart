import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/dashboard/restaurant_dashboard_screen.dart';
import '../features/dish/dish_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/map/map_view_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/saved_screen.dart';
import '../features/restaurant/restaurant_profile_screen.dart';
import '../features/search/search_results_screen.dart';
import '../features/shell/home_shell.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

/// Builds the app [GoRouter], wiring auth/onboarding redirects and the
/// bottom-navigation shell.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoute.home.path,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.signup.path,
        name: AppRoute.signup.name,
        builder: (_, __) => const SignupScreen(),
      ),

      // Bottom-nav shell (Home / Map / Saved / Profile).
      StatefulShellRoute.indexedStack(
        builder: (_, __, navShell) => HomeShell(navigationShell: navShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.map.path,
                name: AppRoute.map.name,
                builder: (_, __) => const MapViewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.saved.path,
                name: AppRoute.saved.name,
                builder: (_, __) => const SavedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profile.path,
                name: AppRoute.profile.name,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes pushed above the shell.
      GoRoute(
        path: AppRoute.search.path,
        name: AppRoute.search.name,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => SearchResultsScreen(
          initialQuery: state.uri.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.dishDetail.path,
        name: AppRoute.dishDetail.name,
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            DishDetailScreen(dishId: state.pathParameters['dishId']!),
      ),
      GoRoute(
        path: AppRoute.restaurant.path,
        name: AppRoute.restaurant.name,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => RestaurantProfileScreen(
          restaurantId: state.pathParameters['restaurantId']!,
        ),
      ),
      GoRoute(
        path: AppRoute.dashboard.path,
        name: AppRoute.dashboard.name,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const RestaurantDashboardScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod auth/onboarding state into GoRouter's redirect + refresh.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(onboardingSeenProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final onboardingSeen = _ref.read(onboardingSeenProvider);
    final authState = _ref.read(authStateProvider);
    final loggedIn = authState.valueOrNull != null;

    final loc = state.matchedLocation;
    final atOnboarding = loc == AppRoute.onboarding.path;
    final atAuth =
        loc == AppRoute.login.path || loc == AppRoute.signup.path;

    // 1. Force onboarding first.
    if (!onboardingSeen) {
      return atOnboarding ? null : AppRoute.onboarding.path;
    }

    // 2. Require a session (guest counts) for everything but the auth pages.
    if (!loggedIn && !atAuth) return AppRoute.login.path;

    // 3. Bounce signed-in users away from onboarding/auth.
    if (loggedIn && (atAuth || atOnboarding)) return AppRoute.home.path;

    return null;
  }
}

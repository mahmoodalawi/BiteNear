import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dish_result.dart';
import '../services/catalog_service.dart';
import 'location_provider.dart';
import 'service_providers.dart';

/// Current text query (driven by the search bar).
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Active filters for the results screen.
final searchFiltersProvider =
    StateProvider<SearchFilters>((ref) => const SearchFilters());

/// The "Nearby Right Now" home feed, nearest first.
final nearbyFeedProvider = FutureProvider<List<DishResult>>((ref) async {
  final origin = await ref.watch(currentLocationProvider.future);
  final catalog = ref.watch(catalogServiceProvider);
  return catalog.nearby(origin);
});

/// Search results derived from query + filters + location.
final searchResultsProvider = FutureProvider<List<DishResult>>((ref) async {
  final origin = await ref.watch(currentLocationProvider.future);
  final catalog = ref.watch(catalogServiceProvider);
  final query = ref.watch(searchQueryProvider);
  final filters = ref.watch(searchFiltersProvider);
  return catalog.search(query, origin, filters);
});

/// A single dish + restaurant + distance, by dish id.
final dishResultProvider =
    FutureProvider.family<DishResult?, String>((ref, dishId) async {
  final origin = await ref.watch(currentLocationProvider.future);
  final catalog = ref.watch(catalogServiceProvider);
  return catalog.dishResult(dishId, origin);
});

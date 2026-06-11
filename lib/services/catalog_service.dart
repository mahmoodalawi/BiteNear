import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/dish.dart';
import '../models/dish_result.dart';
import '../models/enums.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import 'location_service.dart';
import 'mock_data.dart';

/// Filters applied to a dish search.
class SearchFilters {
  final double radiusKm;
  final PriceLevel priceLevel;
  final Set<String> dietaryTags;
  final SortOption sort;

  const SearchFilters({
    this.radiusKm = AppConstants.defaultRadiusKm,
    this.priceLevel = PriceLevel.any,
    this.dietaryTags = const {},
    this.sort = SortOption.nearest,
  });

  SearchFilters copyWith({
    double? radiusKm,
    PriceLevel? priceLevel,
    Set<String>? dietaryTags,
    SortOption? sort,
  }) {
    return SearchFilters(
      radiusKm: radiusKm ?? this.radiusKm,
      priceLevel: priceLevel ?? this.priceLevel,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      sort: sort ?? this.sort,
    );
  }
}

/// Read/query facade over the dish catalog.
///
/// This implementation is backed by [MockData] so the MVP runs without a live
/// backend. The method surface mirrors what a Firestore-backed implementation
/// would expose, so swapping in [FirestoreService] later is mechanical.
class CatalogService {
  /// Builds a [DishResult] feed of everything near [origin], nearest first.
  List<DishResult> nearby(LatLngPoint origin, {int limit = 20}) {
    final results = _allResults(origin)
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return results.take(limit).toList();
  }

  /// Searches dishes by name/tag and applies [filters].
  List<DishResult> search(
    String query,
    LatLngPoint origin,
    SearchFilters filters,
  ) {
    final q = query.trim().toLowerCase();
    var results = _allResults(origin).where((r) {
      // Text match against dish name, description, tags and cuisine.
      final matchesQuery = q.isEmpty ||
          r.dish.name.toLowerCase().contains(q) ||
          r.dish.description.toLowerCase().contains(q) ||
          r.restaurant.cuisine.toLowerCase().contains(q) ||
          r.dish.dietaryTags.any((t) => t.toLowerCase().contains(q));
      if (!matchesQuery) return false;

      // Radius.
      if (r.distanceKm > filters.radiusKm) return false;

      // Price bucket.
      final cap = filters.priceLevel.maxPrice;
      if (cap != null && r.dish.price > cap) return false;

      // Dietary tags (dish must contain all selected tags).
      if (filters.dietaryTags.isNotEmpty &&
          !filters.dietaryTags.every((t) => r.dish.dietaryTags.contains(t))) {
        return false;
      }
      return true;
    }).toList();

    results = _applySort(results, filters.sort);
    return results;
  }

  Restaurant? restaurant(String id) => MockData.restaurantById(id);

  List<Dish> menu(String restaurantId) =>
      MockData.dishesForRestaurant(restaurantId);

  Dish? dish(String id) => MockData.dishById(id);

  DishResult? dishResult(String dishId, LatLngPoint origin) {
    final d = MockData.dishById(dishId);
    if (d == null) return null;
    final r = MockData.restaurantById(d.restaurantId);
    if (r == null) return null;
    return DishResult(
      dish: d,
      restaurant: r,
      distanceKm: Formatters.haversineKm(
        origin.latitude,
        origin.longitude,
        r.latitude,
        r.longitude,
      ),
    );
  }

  List<Review> reviews(String dishId) => MockData.reviewsForDish(dishId);

  List<DishResult> _allResults(LatLngPoint origin) {
    return MockData.dishes.map((d) {
      final r = MockData.restaurantById(d.restaurantId)!;
      return DishResult(
        dish: d,
        restaurant: r,
        distanceKm: Formatters.haversineKm(
          origin.latitude,
          origin.longitude,
          r.latitude,
          r.longitude,
        ),
      );
    }).toList();
  }

  List<DishResult> _applySort(List<DishResult> items, SortOption sort) {
    switch (sort) {
      case SortOption.nearest:
        items.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case SortOption.rating:
        items.sort((a, b) => b.dish.rating.compareTo(a.dish.rating));
        break;
      case SortOption.priceLowToHigh:
        items.sort((a, b) => a.dish.price.compareTo(b.dish.price));
        break;
    }
    return items;
  }
}

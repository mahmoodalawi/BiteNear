import 'dish.dart';
import 'restaurant.dart';

/// A search/feed result pairing a [Dish] with its owning [Restaurant]
/// and the computed distance from the user (km).
///
/// This is the primary view-model rendered in the home feed, search list
/// and map bottom sheets.
class DishResult {
  final Dish dish;
  final Restaurant restaurant;
  final double distanceKm;

  const DishResult({
    required this.dish,
    required this.restaurant,
    required this.distanceKm,
  });
}

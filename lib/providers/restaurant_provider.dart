import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dish.dart';
import '../models/restaurant.dart';
import 'service_providers.dart';

/// Restaurant profile by id.
final restaurantProvider =
    Provider.family<Restaurant?, String>((ref, id) {
  return ref.watch(catalogServiceProvider).restaurant(id);
});

/// Full menu for a restaurant.
final restaurantMenuProvider =
    Provider.family<List<Dish>, String>((ref, restaurantId) {
  return ref.watch(catalogServiceProvider).menu(restaurantId);
});

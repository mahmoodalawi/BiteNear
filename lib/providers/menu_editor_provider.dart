import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dish.dart';
import '../services/mock_data.dart';

/// In-memory, editable menu used by the restaurant dashboard demo.
///
/// Seeded from [MockData]; in live mode these operations would proxy to
/// [FirestoreService.addDish] / updateDish / deleteDish.
class MenuEditorNotifier extends StateNotifier<List<Dish>> {
  MenuEditorNotifier(this.restaurantId)
      : super(MockData.dishesForRestaurant(restaurantId));

  final String restaurantId;
  int _seq = 0;

  void add(Dish dish) {
    final withId = Dish(
      id: 'local_${restaurantId}_${_seq++}',
      restaurantId: restaurantId,
      name: dish.name,
      description: dish.description,
      price: dish.price,
      imageUrl: dish.imageUrl,
      category: dish.category,
      dietaryTags: dish.dietaryTags,
    );
    state = [...state, withId];
  }

  void update(Dish dish) {
    state = [
      for (final d in state)
        if (d.id == dish.id) dish else d,
    ];
  }

  void remove(String dishId) {
    state = state.where((d) => d.id != dishId).toList();
  }
}

final menuEditorProvider =
    StateNotifierProvider.family<MenuEditorNotifier, List<Dish>, String>(
  (ref, restaurantId) => MenuEditorNotifier(restaurantId),
);

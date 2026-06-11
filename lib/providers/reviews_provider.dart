import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review.dart';
import '../services/mock_data.dart';

/// Reviews for a single dish, seeded from [MockData] and extended with
/// locally submitted reviews (demo mode). In live mode this would be a
/// `StreamProvider` over [FirestoreService.reviewsForDish].
class DishReviewsNotifier extends StateNotifier<List<Review>> {
  DishReviewsNotifier(this.dishId)
      : super(MockData.reviewsForDish(dishId));

  final String dishId;

  void add(Review review) {
    state = [review, ...state];
  }

  double get average {
    if (state.isEmpty) return 0;
    final sum = state.fold<double>(0, (acc, r) => acc + r.rating);
    return sum / state.length;
  }
}

final dishReviewsProvider = StateNotifierProvider.family<DishReviewsNotifier,
    List<Review>, String>((ref, dishId) {
  return DishReviewsNotifier(dishId);
});

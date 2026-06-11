import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dish.dart';
import '../models/restaurant.dart';
import '../models/review.dart';

/// Live Firestore data access for restaurants, dishes and reviews.
///
/// Collection layout:
///   restaurants/{restaurantId}
///   restaurants/{restaurantId}/dishes/{dishId}
///   dishes/{dishId}                (flat mirror for cross-restaurant search)
///   reviews/{reviewId}
///
/// Note: production geo-search should use a geohash field + a library like
/// `geoflutterfire`. For the MVP we fetch a candidate set and filter/sort
/// client-side (see CatalogService for the mock equivalent).
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // High Unicode code point used as the upper bound of a prefix query.
  static const String _highSentinel = '\u{F8FF}';

  CollectionReference<Map<String, dynamic>> get _restaurants =>
      _db.collection('restaurants');
  CollectionReference<Map<String, dynamic>> get _dishes =>
      _db.collection('dishes');
  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  // ---- Reads ----

  Future<List<Dish>> searchDishesByName(String query) async {
    final q = query.toLowerCase();
    // Prefix range query on the denormalized `nameLower` field.
    final snap = await _dishes
        .orderBy('nameLower')
        .startAt([q])
        .endAt(['$q$_highSentinel'])
        .limit(50)
        .get();
    return snap.docs.map((d) => Dish.fromMap(d.id, d.data())).toList();
  }

  Future<List<Dish>> allDishes() async {
    final snap = await _dishes.limit(200).get();
    return snap.docs.map((d) => Dish.fromMap(d.id, d.data())).toList();
  }

  Future<Restaurant?> restaurant(String id) async {
    final snap = await _restaurants.doc(id).get();
    if (!snap.exists) return null;
    return Restaurant.fromMap(snap.id, snap.data()!);
  }

  Future<List<Dish>> menu(String restaurantId) async {
    final snap =
        await _dishes.where('restaurantId', isEqualTo: restaurantId).get();
    return snap.docs.map((d) => Dish.fromMap(d.id, d.data())).toList();
  }

  Stream<List<Review>> reviewsForDish(String dishId) {
    return _reviews
        .where('dishId', isEqualTo: dishId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Review.fromMap(d.id, d.data())).toList());
  }

  // ---- Writes (restaurant dashboard) ----

  Future<String> addDish(Dish dish) async {
    final ref = await _dishes.add(dish.toMap());
    return ref.id;
  }

  Future<void> updateDish(Dish dish) async {
    await _dishes.doc(dish.id).update(dish.toMap());
  }

  Future<void> deleteDish(String dishId) async {
    await _dishes.doc(dishId).delete();
  }

  Future<void> addReview(Review review) async {
    await _reviews.add(review.toMap());
    // Recompute the dish aggregate in a transaction.
    final dishRef = _dishes.doc(review.dishId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(dishRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      final count = (data['reviewCount'] as num?)?.toInt() ?? 0;
      final avg = (data['rating'] as num?)?.toDouble() ?? 0;
      final newCount = count + 1;
      final newAvg = ((avg * count) + review.rating) / newCount;
      tx.update(dishRef, {'reviewCount': newCount, 'rating': newAvg});
    });
  }
}

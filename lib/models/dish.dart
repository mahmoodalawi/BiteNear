import 'enums.dart';

/// A single menu item (food or drink) offered by a restaurant.
class Dish {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final DishCategory category;
  final List<String> dietaryTags;
  final double rating; // aggregate 0..5
  final int reviewCount;

  /// Lightweight analytics for the restaurant dashboard.
  final int views;
  final int searchHits;

  const Dish({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.dietaryTags = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.views = 0,
    this.searchHits = 0,
  });

  factory Dish.fromMap(String id, Map<String, dynamic> map) {
    return Dish(
      id: id,
      restaurantId: map['restaurantId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      category: DishCategory.fromString(map['category'] as String? ?? 'food'),
      dietaryTags: List<String>.from(map['dietaryTags'] as List? ?? const []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      views: (map['views'] as num?)?.toInt() ?? 0,
      searchHits: (map['searchHits'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category.name,
      'dietaryTags': dietaryTags,
      'rating': rating,
      'reviewCount': reviewCount,
      'views': views,
      'searchHits': searchHits,
      // Lowercase search key for case-insensitive name queries.
      'nameLower': name.toLowerCase(),
    };
  }

  Dish copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    DishCategory? category,
    List<String>? dietaryTags,
  }) {
    return Dish(
      id: id,
      restaurantId: restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      rating: rating,
      reviewCount: reviewCount,
      views: views,
      searchHits: searchHits,
    );
  }
}

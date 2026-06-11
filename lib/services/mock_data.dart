import '../models/dish.dart';
import '../models/enums.dart';
import '../models/restaurant.dart';
import '../models/review.dart';

/// In-memory demo dataset.
///
/// Lets the app run end-to-end without a live Firebase backend. The data is
/// centered on San Francisco; swap [MockData] usage for [FirestoreService]
/// once a real backend is provisioned (see README → Backend modes).
class MockData {
  MockData._();

  // Demo "user location" — Ferry Building, San Francisco.
  static const double userLat = 37.7955;
  static const double userLng = -122.3937;

  static final List<Restaurant> restaurants = [
    Restaurant(
      id: 'r_matcha_house',
      name: 'Matcha House',
      cuisine: 'Japanese Café',
      logoUrl: _logo('Matcha+House', '2EC4B6'),
      coverUrl: _cover('1', 800, 400),
      latitude: 37.7912,
      longitude: -122.3990,
      address: '120 Market St, San Francisco, CA',
      phone: '+1 415 555 0142',
      rating: 4.7,
      reviewCount: 318,
      hours: _weekdayHours('08:00 - 20:00'),
    ),
    Restaurant(
      id: 'r_shawarma_bros',
      name: 'Shawarma Bros',
      cuisine: 'Middle Eastern',
      logoUrl: _logo('Shawarma', 'FF5A3C'),
      coverUrl: _cover('2', 800, 400),
      latitude: 37.7990,
      longitude: -122.4001,
      address: '88 Drumm St, San Francisco, CA',
      phone: '+1 415 555 0177',
      rating: 4.5,
      reviewCount: 512,
      hours: _weekdayHours('11:00 - 23:00'),
    ),
    Restaurant(
      id: 'r_green_bowl',
      name: 'Green Bowl Kitchen',
      cuisine: 'Healthy / Vegan',
      logoUrl: _logo('Green+Bowl', '2BB673'),
      coverUrl: _cover('3', 800, 400),
      latitude: 37.7880,
      longitude: -122.3995,
      address: '55 California St, San Francisco, CA',
      phone: '+1 415 555 0199',
      rating: 4.6,
      reviewCount: 204,
      hours: _weekdayHours('09:00 - 21:00'),
    ),
    Restaurant(
      id: 'r_burger_lab',
      name: 'Burger Lab',
      cuisine: 'American',
      logoUrl: _logo('Burger+Lab', 'FFB627'),
      coverUrl: _cover('4', 800, 400),
      latitude: 37.7935,
      longitude: -122.3960,
      address: '201 Spear St, San Francisco, CA',
      phone: '+1 415 555 0124',
      rating: 4.4,
      reviewCount: 689,
      hours: _weekdayHours('11:00 - 22:00'),
    ),
    Restaurant(
      id: 'r_sakura_sushi',
      name: 'Sakura Sushi',
      cuisine: 'Japanese',
      logoUrl: _logo('Sakura', 'FF7A50'),
      coverUrl: _cover('5', 800, 400),
      latitude: 37.8005,
      longitude: -122.4050,
      address: '12 Clay St, San Francisco, CA',
      phone: '+1 415 555 0150',
      rating: 4.8,
      reviewCount: 421,
      hours: _weekdayHours('12:00 - 22:30'),
    ),
  ];

  static final List<Dish> dishes = [
    // Matcha House
    Dish(
      id: 'd_matcha_latte',
      restaurantId: 'r_matcha_house',
      name: 'Iced Matcha Latte',
      description:
          'Ceremonial-grade matcha whisked with oat milk over ice. Earthy, '
          'creamy, lightly sweet.',
      price: 5.50,
      imageUrl: _food('matcha-latte'),
      category: DishCategory.drinks,
      dietaryTags: ['Vegan', 'Vegetarian'],
      rating: 4.8,
      reviewCount: 142,
      views: 3120,
      searchHits: 980,
    ),
    Dish(
      id: 'd_matcha_cake',
      restaurantId: 'r_matcha_house',
      name: 'Matcha Basque Cheesecake',
      description: 'Burnt-top Basque cheesecake folded with stone-ground matcha.',
      price: 7.00,
      imageUrl: _food('matcha-cake'),
      category: DishCategory.desserts,
      dietaryTags: ['Vegetarian'],
      rating: 4.6,
      reviewCount: 64,
      views: 1450,
      searchHits: 410,
    ),
    // Shawarma Bros
    Dish(
      id: 'd_chicken_shawarma',
      restaurantId: 'r_shawarma_bros',
      name: 'Chicken Shawarma Wrap',
      description:
          'Marinated chicken thigh, garlic toum, pickles and fries rolled in '
          'saj bread.',
      price: 9.50,
      imageUrl: _food('shawarma'),
      category: DishCategory.food,
      dietaryTags: ['Halal'],
      rating: 4.7,
      reviewCount: 233,
      views: 5210,
      searchHits: 2040,
    ),
    Dish(
      id: 'd_falafel_plate',
      restaurantId: 'r_shawarma_bros',
      name: 'Falafel Plate',
      description: 'Crispy chickpea falafel, hummus, tabbouleh and warm pita.',
      price: 11.00,
      imageUrl: _food('falafel'),
      category: DishCategory.food,
      dietaryTags: ['Vegan', 'Vegetarian', 'Halal'],
      rating: 4.5,
      reviewCount: 98,
      views: 1980,
      searchHits: 540,
    ),
    // Green Bowl
    Dish(
      id: 'd_keto_bowl',
      restaurantId: 'r_green_bowl',
      name: 'Keto Power Bowl',
      description:
          'Grilled salmon, avocado, soft egg and greens with tahini dressing.',
      price: 14.00,
      imageUrl: _food('keto-bowl'),
      category: DishCategory.food,
      dietaryTags: ['Keto', 'Gluten-Free'],
      rating: 4.6,
      reviewCount: 76,
      views: 1320,
      searchHits: 610,
    ),
    Dish(
      id: 'd_green_smoothie',
      restaurantId: 'r_green_bowl',
      name: 'Glow Green Smoothie',
      description: 'Spinach, mango, banana, ginger and coconut water.',
      price: 6.50,
      imageUrl: _food('smoothie'),
      category: DishCategory.drinks,
      dietaryTags: ['Vegan', 'Vegetarian', 'Gluten-Free'],
      rating: 4.4,
      reviewCount: 52,
      views: 880,
      searchHits: 300,
    ),
    // Burger Lab
    Dish(
      id: 'd_classic_burger',
      restaurantId: 'r_burger_lab',
      name: 'Lab Classic Cheeseburger',
      description:
          'Smashed dry-aged beef, american cheese, house pickles and Lab sauce.',
      price: 12.50,
      imageUrl: _food('burger'),
      category: DishCategory.food,
      dietaryTags: ['Spicy'],
      rating: 4.5,
      reviewCount: 311,
      views: 6010,
      searchHits: 2600,
    ),
    Dish(
      id: 'd_vegan_burger',
      restaurantId: 'r_burger_lab',
      name: 'Beyond Vegan Burger',
      description: 'Plant-based patty, vegan cheddar, caramelized onion.',
      price: 13.00,
      imageUrl: _food('vegan-burger'),
      category: DishCategory.food,
      dietaryTags: ['Vegan', 'Vegetarian'],
      rating: 4.3,
      reviewCount: 87,
      views: 1700,
      searchHits: 720,
    ),
    // Sakura Sushi
    Dish(
      id: 'd_salmon_nigiri',
      restaurantId: 'r_sakura_sushi',
      name: 'Salmon Nigiri (2 pc)',
      description: 'Hand-pressed sushi rice topped with buttery king salmon.',
      price: 7.50,
      imageUrl: _food('nigiri'),
      category: DishCategory.food,
      dietaryTags: ['Gluten-Free'],
      rating: 4.9,
      reviewCount: 188,
      views: 2900,
      searchHits: 1100,
    ),
    Dish(
      id: 'd_matcha_icecream',
      restaurantId: 'r_sakura_sushi',
      name: 'Matcha Soft Serve',
      description: 'Silky matcha soft serve with a black-sesame crumble.',
      price: 5.00,
      imageUrl: _food('matcha-icecream'),
      category: DishCategory.desserts,
      dietaryTags: ['Vegetarian'],
      rating: 4.7,
      reviewCount: 73,
      views: 1240,
      searchHits: 520,
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'rv1',
      dishId: 'd_matcha_latte',
      restaurantId: 'r_matcha_house',
      userId: 'u1',
      userName: 'Aya K.',
      userPhotoUrl: _avatar('Aya'),
      rating: 5,
      comment: 'Best matcha in the city — not bitter at all and so creamy.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'rv2',
      dishId: 'd_matcha_latte',
      restaurantId: 'r_matcha_house',
      userId: 'u2',
      userName: 'Diego R.',
      userPhotoUrl: _avatar('Diego'),
      rating: 4,
      comment: 'Great flavor, wish the cup was a little bigger for the price.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Review(
      id: 'rv3',
      dishId: 'd_chicken_shawarma',
      restaurantId: 'r_shawarma_bros',
      userId: 'u3',
      userName: 'Lina M.',
      userPhotoUrl: _avatar('Lina'),
      rating: 5,
      comment: 'Tastes like home. The toum is dangerously good.',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Review(
      id: 'rv4',
      dishId: 'd_classic_burger',
      restaurantId: 'r_burger_lab',
      userId: 'u4',
      userName: 'Sam P.',
      userPhotoUrl: _avatar('Sam'),
      rating: 4,
      comment: 'Juicy smash patty, sauce is the star. Fries were a bit cold.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static List<Review> reviewsForDish(String dishId) =>
      reviews.where((r) => r.dishId == dishId).toList();

  static List<Dish> dishesForRestaurant(String restaurantId) =>
      dishes.where((d) => d.restaurantId == restaurantId).toList();

  static Restaurant? restaurantById(String id) {
    for (final r in restaurants) {
      if (r.id == id) return r;
    }
    return null;
  }

  static Dish? dishById(String id) {
    for (final d in dishes) {
      if (d.id == id) return d;
    }
    return null;
  }

  // --- Placeholder image helpers (deterministic, no real assets needed) ---
  static String _food(String seed) =>
      'https://source.unsplash.com/600x600/?food,$seed';
  static String _cover(String seed, int w, int h) =>
      'https://picsum.photos/seed/bitenear$seed/$w/$h';
  static String _logo(String text, String color) =>
      'https://placehold.co/200x200/$color/FFFFFF/png?text=$text';
  static String _avatar(String name) =>
      'https://ui-avatars.com/api/?name=$name&background=FF5A3C&color=fff';

  static Map<String, String> _weekdayHours(String range) => {
        'Mon': range,
        'Tue': range,
        'Wed': range,
        'Thu': range,
        'Fri': range,
        'Sat': range,
        'Sun': range,
      };
}

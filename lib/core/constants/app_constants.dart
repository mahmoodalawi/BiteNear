/// Static configuration values used across the app.
class AppConstants {
  AppConstants._();

  static const String appName = 'BiteNear';
  static const String tagline = 'Discover dishes, not just restaurants.';

  /// Default search radius in kilometers.
  static const double defaultRadiusKm = 5.0;
  static const double minRadiusKm = 1.0;
  static const double maxRadiusKm = 25.0;

  /// Default map zoom when centering on the user.
  static const double defaultMapZoom = 14.0;

  /// Shared-preferences keys.
  static const String prefOnboardingSeen = 'onboarding_seen';
  static const String prefFavorites = 'favorite_dish_ids';

  /// Popular quick-filter terms shown on the home screen.
  static const List<String> quickFilters = [
    'Matcha',
    'Shawarma',
    'Burger',
    'Sushi',
    'Keto',
    'Vegan',
    'Pizza',
    'Ramen',
    'Tacos',
    'Smoothie',
  ];

  /// Dietary tags used for filtering.
  static const List<String> dietaryTags = [
    'Vegan',
    'Vegetarian',
    'Keto',
    'Gluten-Free',
    'Halal',
    'Spicy',
  ];
}

/// Menu category a dish belongs to.
enum DishCategory {
  food,
  drinks,
  desserts;

  String get label {
    switch (this) {
      case DishCategory.food:
        return 'Food';
      case DishCategory.drinks:
        return 'Drinks';
      case DishCategory.desserts:
        return 'Desserts';
    }
  }

  static DishCategory fromString(String value) {
    return DishCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => DishCategory.food,
    );
  }
}

/// Sort options for search results.
enum SortOption {
  nearest,
  rating,
  priceLowToHigh;

  String get label {
    switch (this) {
      case SortOption.nearest:
        return 'Nearest';
      case SortOption.rating:
        return 'Top rated';
      case SortOption.priceLowToHigh:
        return 'Price';
    }
  }
}

/// Price bucket used by filters ($ / $$ / $$$).
enum PriceLevel {
  any,
  cheap,
  moderate,
  premium;

  String get label {
    switch (this) {
      case PriceLevel.any:
        return 'Any';
      case PriceLevel.cheap:
        return '\$';
      case PriceLevel.moderate:
        return '\$\$';
      case PriceLevel.premium:
        return '\$\$\$';
    }
  }

  /// Inclusive max price (USD) for the bucket; null means "no cap".
  double? get maxPrice {
    switch (this) {
      case PriceLevel.any:
        return null;
      case PriceLevel.cheap:
        return 8;
      case PriceLevel.moderate:
        return 18;
      case PriceLevel.premium:
        return double.infinity;
    }
  }
}

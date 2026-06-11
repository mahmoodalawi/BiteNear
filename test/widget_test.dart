import 'package:bitenear/core/utils/formatters.dart';
import 'package:bitenear/models/dish.dart';
import 'package:bitenear/models/enums.dart';
import 'package:bitenear/services/catalog_service.dart';
import 'package:bitenear/services/location_service.dart';
import 'package:bitenear/services/mock_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('distance formats meters and kilometers', () {
      expect(Formatters.distance(0.45), '450 m');
      expect(Formatters.distance(2.34), '2.3 km');
    });

    test('haversine distance is ~0 for identical points', () {
      final d = Formatters.haversineKm(37.79, -122.39, 37.79, -122.39);
      expect(d, closeTo(0, 0.001));
    });

    test('price formats with two decimals', () {
      expect(Formatters.price(5.5), '\$5.50');
    });
  });

  group('CatalogService', () {
    final catalog = CatalogService();
    const origin = LatLngPoint(MockData.userLat, MockData.userLng);

    test('nearby returns results sorted by distance', () {
      final results = catalog.nearby(origin);
      expect(results, isNotEmpty);
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].distanceKm >= results[i - 1].distanceKm,
          isTrue,
        );
      }
    });

    test('search matches dish name case-insensitively', () {
      final results = catalog.search(
        'matcha',
        origin,
        const SearchFilters(radiusKm: 25),
      );
      expect(results, isNotEmpty);
      expect(
        results.every((r) =>
            r.dish.name.toLowerCase().contains('matcha') ||
            r.dish.description.toLowerCase().contains('matcha') ||
            r.dish.dietaryTags
                .any((t) => t.toLowerCase().contains('matcha'))),
        isTrue,
      );
    });

    test('dietary filter narrows results to vegan dishes', () {
      final results = catalog.search(
        '',
        origin,
        const SearchFilters(radiusKm: 25, dietaryTags: {'Vegan'}),
      );
      expect(results, isNotEmpty);
      expect(results.every((r) => r.dish.dietaryTags.contains('Vegan')), isTrue);
    });
  });

  group('Dish serialization', () {
    test('round-trips through map', () {
      const dish = Dish(
        id: 'd1',
        restaurantId: 'r1',
        name: 'Test Latte',
        description: 'desc',
        price: 4.25,
        imageUrl: 'http://x',
        category: DishCategory.drinks,
        dietaryTags: ['Vegan'],
      );
      final map = dish.toMap();
      expect(map['nameLower'], 'test latte');
      final parsed = Dish.fromMap('d1', map);
      expect(parsed.name, dish.name);
      expect(parsed.category, DishCategory.drinks);
      expect(parsed.dietaryTags, contains('Vegan'));
    });
  });
}

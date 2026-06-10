import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import 'service_providers.dart';

/// Persisted set of favorited dish ids, stored in SharedPreferences.
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._prefs)
      : super(
          (_prefs.getStringList(AppConstants.prefFavorites) ?? const [])
              .toSet(),
        );

  final SharedPreferences _prefs;

  bool isFavorite(String dishId) => state.contains(dishId);

  void toggle(String dishId) {
    final next = {...state};
    if (!next.add(dishId)) next.remove(dishId);
    state = next;
    _prefs.setStringList(AppConstants.prefFavorites, next.toList());
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(ref.watch(sharedPrefsProvider));
});

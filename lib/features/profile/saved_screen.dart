import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/empty_state.dart';

/// "Saved" tab — the user's favorited dishes.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final feed = ref.watch(nearbyFeedProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Saved dishes', style: AppTextStyles.headline)),
      body: feed.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final saved =
              items.where((r) => favorites.contains(r.dish.id)).toList();
          if (saved.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No saved dishes yet',
              message: 'Tap the heart on any dish to save it here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: saved.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => DishListTile(result: saved[i]),
          );
        },
      ),
    );
  }
}

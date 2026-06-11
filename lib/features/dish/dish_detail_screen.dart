import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/maps_launcher.dart';
import '../../models/dish_result.dart';
import '../../providers/reviews_provider.dart';
import '../../providers/search_provider.dart';
import '../../router/routes.dart';
import '../../widgets/dietary_tag_chip.dart';
import '../../widgets/dish_image.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rating_stars.dart';
import 'widgets/review_tile.dart';
import 'widgets/write_review_sheet.dart';

/// Full dish page: hero photo, details, directions and dish-level reviews.
class DishDetailScreen extends ConsumerWidget {
  final String dishId;
  const DishDetailScreen({super.key, required this.dishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(dishResultProvider(dishId));

    return Scaffold(
      body: asyncResult.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (result) {
          if (result == null) {
            return const Center(child: Text('Dish not found'));
          }
          return _DishContent(result: result);
        },
      ),
    );
  }
}

class _DishContent extends ConsumerWidget {
  final DishResult result;
  const _DishContent({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dish = result.dish;
    final restaurant = result.restaurant;
    final reviews = ref.watch(dishReviewsProvider(dish.id));
    final avg = reviews.isEmpty
        ? dish.rating
        : ref.read(dishReviewsProvider(dish.id).notifier).average;

    return CustomScrollView(
      slivers: [
        // Hero image
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppColors.charcoal,
          leading: _CircleIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FavoriteButton(dishId: dish.id, filled: true),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                DishImage(url: dish.imageUrl),
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.photoScrim),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(dish.name, style: AppTextStyles.displayLarge)),
                    Text(Formatters.price(dish.price),
                        style: AppTextStyles.price.copyWith(fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingStars(rating: avg, size: 18, showValue: true),
                    const SizedBox(width: 6),
                    Text('(${reviews.length} reviews)',
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 16),
                if (dish.dietaryTags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        dish.dietaryTags.map((t) => DietaryTagChip(t)).toList(),
                  ),
                const SizedBox(height: 16),
                Text(dish.description, style: AppTextStyles.body),
                const SizedBox(height: 20),

                // Restaurant row (tappable -> restaurant profile)
                _RestaurantRow(
                  result: result,
                  onTap: () => context.pushNamed(
                    AppRoute.restaurant.name,
                    pathParameters: {'restaurantId': restaurant.id},
                  ),
                ),
                const SizedBox(height: 20),

                PrimaryButton(
                  label: 'Get directions',
                  icon: Icons.directions_rounded,
                  onPressed: () => MapsLauncher.directionsTo(
                    restaurant.latitude,
                    restaurant.longitude,
                    label: restaurant.name,
                  ),
                ),
                const SizedBox(height: 28),

                // Reviews header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reviews', style: AppTextStyles.title),
                    TextButton.icon(
                      onPressed: () => WriteReviewSheet.show(
                        context,
                        dishId: dish.id,
                        restaurantId: restaurant.id,
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Write'),
                    ),
                  ],
                ),
                if (reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Be the first to review this dish!',
                        style: AppTextStyles.bodyMuted),
                  )
                else
                  ...reviews.map((r) => ReviewTile(review: r)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  final DishResult result;
  final VoidCallback onTap;
  const _RestaurantRow({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = result.restaurant;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DishImage(url: r.logoUrl, width: 48, height: 48),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: AppTextStyles.subtitle),
                  Text(
                    '${r.cuisine} · ${Formatters.distance(result.distanceKm)} away',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0x66000000),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

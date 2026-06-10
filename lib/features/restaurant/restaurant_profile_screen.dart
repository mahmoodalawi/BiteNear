import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/maps_launcher.dart';
import '../../models/dish.dart';
import '../../models/enums.dart';
import '../../providers/restaurant_provider.dart';
import '../../router/routes.dart';
import '../../widgets/dish_image.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rating_stars.dart';

/// Restaurant page with Menu / Reviews / Info tabs.
class RestaurantProfileScreen extends ConsumerWidget {
  final String restaurantId;
  const RestaurantProfileScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantProvider(restaurantId));
    final menu = ref.watch(restaurantMenuProvider(restaurantId));

    if (restaurant == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.store_mall_directory_rounded,
          title: 'Restaurant not found',
          message: 'This place may no longer be available.',
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.charcoal,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    DishImage(url: restaurant.coverUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.photoScrim),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 16,
                      right: 20,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: DishImage(
                                url: restaurant.logoUrl, width: 56, height: 56),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(restaurant.name,
                                    style: AppTextStyles.headline
                                        .copyWith(color: Colors.white)),
                                Text(restaurant.cuisine,
                                    style: AppTextStyles.caption
                                        .copyWith(color: Colors.white70)),
                              ],
                            ),
                          ),
                          RatingStars(
                              rating: restaurant.rating,
                              size: 16,
                              showValue: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Menu'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Info'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _MenuTab(menu: menu),
              _ReviewsTab(menu: menu),
              _InfoTab(restaurant: restaurant),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  final List<Dish> menu;
  const _MenuTab({required this.menu});

  @override
  Widget build(BuildContext context) {
    if (menu.isEmpty) {
      return const EmptyState(
        icon: Icons.menu_book_rounded,
        title: 'No menu yet',
        message: 'This restaurant hasn’t published dishes.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in DishCategory.values)
          ..._categorySection(context, category,
              menu.where((d) => d.category == category).toList()),
      ],
    );
  }

  List<Widget> _categorySection(
      BuildContext context, DishCategory category, List<Dish> dishes) {
    if (dishes.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(category.label, style: AppTextStyles.title),
      ),
      ...dishes.map((d) => _MenuRow(dish: d)),
      const SizedBox(height: 8),
    ];
  }
}

class _MenuRow extends StatelessWidget {
  final Dish dish;
  const _MenuRow({required this.dish});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.dishDetail.name,
        pathParameters: {'dishId': dish.id},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DishImage(url: dish.imageUrl, width: 64, height: 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dish.name, style: AppTextStyles.subtitle),
                  const SizedBox(height: 2),
                  Text(dish.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  RatingStars(rating: dish.rating, size: 13, showValue: true),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(Formatters.price(dish.price), style: AppTextStyles.price),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<Dish> menu;
  const _ReviewsTab({required this.menu});

  @override
  Widget build(BuildContext context) {
    // Aggregate: show top-reviewed dishes as an entry point to dish reviews.
    final sorted = [...menu]
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    if (sorted.isEmpty) {
      return const EmptyState(
        icon: Icons.reviews_rounded,
        title: 'No reviews yet',
        message: 'Reviews appear here once dishes are rated.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Most reviewed dishes', style: AppTextStyles.title),
        const SizedBox(height: 12),
        ...sorted.map(
          (d) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: DishImage(url: d.imageUrl, width: 48, height: 48),
            ),
            title: Text(d.name, style: AppTextStyles.subtitle),
            subtitle: Row(
              children: [
                RatingStars(rating: d.rating, size: 13, showValue: true),
                const SizedBox(width: 6),
                Text('${d.reviewCount} reviews',
                    style: AppTextStyles.caption),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed(
              AppRoute.dishDetail.name,
              pathParameters: {'dishId': d.id},
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  final dynamic restaurant;
  const _InfoTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoRow(
          icon: Icons.place_rounded,
          label: 'Address',
          value: restaurant.address,
        ),
        _InfoRow(
          icon: Icons.phone_rounded,
          label: 'Phone',
          value: restaurant.phone,
          onTap: () => MapsLauncher.call(restaurant.phone),
        ),
        const SizedBox(height: 12),
        Text('Opening hours', style: AppTextStyles.title),
        const SizedBox(height: 8),
        ...(restaurant.hours as Map<String, String>).entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: AppTextStyles.body),
                    Text(e.value, style: AppTextStyles.bodyMuted),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => MapsLauncher.directionsTo(
            restaurant.latitude,
            restaurant.longitude,
            label: restaurant.name,
          ),
          icon: const Icon(Icons.directions_rounded),
          label: const Text('Get directions'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.caption),
      subtitle: Text(value, style: AppTextStyles.body),
      onTap: onTap,
    );
  }
}

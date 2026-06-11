import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/dish.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_editor_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/dish_image.dart';
import 'widgets/dish_editor_sheet.dart';

/// Restaurant-owner view: menu CRUD + lightweight dish analytics.
class RestaurantDashboardScreen extends ConsumerWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // Use the owner's restaurant when present, else a demo restaurant.
    final restaurantId = user?.ownedRestaurantId ?? demoOwnedRestaurantId();
    final restaurant = ref.watch(restaurantProvider(restaurantId));
    final menu = ref.watch(menuEditorProvider(restaurantId));

    final totalViews = menu.fold<int>(0, (a, d) => a + d.views);
    final totalSearches = menu.fold<int>(0, (a, d) => a + d.searchHits);

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant?.name ?? 'Dashboard',
            style: AppTextStyles.headline),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final dish = await DishEditorSheet.show(context,
              restaurantId: restaurantId);
          if (dish != null) {
            ref.read(menuEditorProvider(restaurantId).notifier).add(dish);
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add dish'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Analytics summary
          Row(
            children: [
              _MetricCard(
                icon: Icons.visibility_rounded,
                label: 'Total views',
                value: _compact(totalViews),
              ),
              const SizedBox(width: 12),
              _MetricCard(
                icon: Icons.search_rounded,
                label: 'Search hits',
                value: _compact(totalSearches),
              ),
              const SizedBox(width: 12),
              _MetricCard(
                icon: Icons.restaurant_menu_rounded,
                label: 'Dishes',
                value: '${menu.length}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Your menu', style: AppTextStyles.title),
          const SizedBox(height: 12),
          ...menu.map(
            (d) => _DashboardDishRow(
              dish: d,
              onEdit: () async {
                final updated = await DishEditorSheet.show(
                  context,
                  restaurantId: restaurantId,
                  existing: d,
                );
                if (updated != null) {
                  ref
                      .read(menuEditorProvider(restaurantId).notifier)
                      .update(updated);
                }
              },
              onDelete: () => _confirmDelete(context, ref, restaurantId, d),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String restaurantId, Dish dish) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete dish?'),
        content: Text('“${dish.name}” will be removed from your menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(menuEditorProvider(restaurantId).notifier)
                  .remove(dish.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  static String _compact(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetricCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.title),
            Text(label,
                textAlign: TextAlign.center, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _DashboardDishRow extends StatelessWidget {
  final Dish dish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DashboardDishRow({
    required this.dish,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DishImage(url: dish.imageUrl, width: 56, height: 56),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: AppTextStyles.subtitle),
                Text(
                  '${dish.category.label} · ${Formatters.price(dish.price)}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 2),
                Text('${dish.views} views · ${dish.searchHits} searches',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/dish_result.dart';
import '../router/routes.dart';
import 'dish_image.dart';
import 'rating_stars.dart';

/// Compact preview shown when a map pin is tapped. Tapping it opens the
/// full dish detail screen.
class DishPreviewSheet extends StatelessWidget {
  final DishResult result;
  const DishPreviewSheet({super.key, required this.result});

  static void show(BuildContext context, DishResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DishPreviewSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dish = result.dish;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          context.pushNamed(
            AppRoute.dishDetail.name,
            pathParameters: {'dishId': dish.id},
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DishImage(url: dish.imageUrl, width: 80, height: 80),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle),
                  Text(result.restaurant.name, style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingStars(rating: dish.rating, size: 14, showValue: true),
                      const Spacer(),
                      Text('${Formatters.distance(result.distanceKm)} · '
                          '${Formatters.price(dish.price)}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

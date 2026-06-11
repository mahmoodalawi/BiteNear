import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/formatters.dart';
import '../models/dish_result.dart';
import '../router/routes.dart';
import 'dish_image.dart';
import 'favorite_button.dart';
import 'rating_stars.dart';

/// Compact card for horizontal "Nearby Right Now" carousels.
class DishCard extends StatelessWidget {
  final DishResult result;
  const DishCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final dish = result.dish;
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.dishDetail.name,
        pathParameters: {'dishId': dish.id},
      ),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: DishImage(
                    url: dish.imageUrl,
                    height: 120,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteButton(dishId: dish.id, filled: true, size: 18),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: _DistancePill(km: result.distanceKm),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingStars(
                        rating: dish.rating,
                        size: 14,
                        showValue: true,
                      ),
                      Text(Formatters.price(dish.price),
                          style: AppTextStyles.price),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width row for vertical search-result lists.
class DishListTile extends StatelessWidget {
  final DishResult result;
  const DishListTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final dish = result.dish;
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoute.dishDetail.name,
        pathParameters: {'dishId': dish.id},
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DishImage(url: dish.imageUrl, width: 96, height: 96),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                      FavoriteButton(dishId: dish.id, size: 20),
                    ],
                  ),
                  Text(
                    result.restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingStars(rating: dish.rating, size: 14, showValue: true),
                      const SizedBox(width: 6),
                      Text('(${dish.reviewCount})', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Text(Formatters.distance(result.distanceKm),
                          style: AppTextStyles.caption),
                      const Spacer(),
                      Text(Formatters.price(dish.price),
                          style: AppTextStyles.price),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistancePill extends StatelessWidget {
  final double km;
  const _DistancePill({required this.km});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.near_me_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            Formatters.distance(km),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

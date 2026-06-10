import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/review.dart';
import '../../../widgets/rating_stars.dart';

/// Single review row in the dish detail review list.
class ReviewTile extends StatelessWidget {
  final Review review;
  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            backgroundImage: review.userPhotoUrl != null
                ? NetworkImage(review.userPhotoUrl!)
                : null,
            child: review.userPhotoUrl == null
                ? const Icon(Icons.person_rounded, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(review.userName,
                          style: AppTextStyles.subtitle),
                    ),
                    Text(Formatters.relativeTime(review.createdAt),
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 4),
                RatingStars(rating: review.rating, size: 14),
                const SizedBox(height: 6),
                Text(review.comment, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

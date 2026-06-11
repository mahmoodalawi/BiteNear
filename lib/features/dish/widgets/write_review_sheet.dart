import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/review.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/reviews_provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/rating_stars.dart';

/// Bottom sheet for submitting a dish-level review.
class WriteReviewSheet extends ConsumerStatefulWidget {
  final String dishId;
  final String restaurantId;

  const WriteReviewSheet({
    super.key,
    required this.dishId,
    required this.restaurantId,
  });

  static Future<void> show(
    BuildContext context, {
    required String dishId,
    required String restaurantId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          WriteReviewSheet(dishId: dishId, restaurantId: restaurantId),
    );
  }

  @override
  ConsumerState<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<WriteReviewSheet> {
  int _rating = 5;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    final user = ref.read(currentUserProvider);
    final review = Review(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      dishId: widget.dishId,
      restaurantId: widget.restaurantId,
      userId: user?.uid ?? 'guest',
      userName: user?.displayName ?? 'Guest',
      userPhotoUrl: user?.photoUrl,
      rating: _rating.toDouble(),
      comment: _comment.text.trim(),
      createdAt: DateTime.now(),
    );
    ref.read(dishReviewsProvider(widget.dishId).notifier).add(review);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your review! 🍽️')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate this dish', style: AppTextStyles.headline),
          const SizedBox(height: 16),
          Center(
            child: RatingInput(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _comment,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share what you loved (or didn’t)…',
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Submit review', onPressed: _submit),
        ],
      ),
    );
  }
}

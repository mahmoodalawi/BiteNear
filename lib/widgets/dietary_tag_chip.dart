import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Small pill showing a dietary tag (Vegan, Keto, Halal…).
class DietaryTagChip extends StatelessWidget {
  final String tag;
  const DietaryTagChip(this.tag, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _colorFor(String tag) {
    switch (tag.toLowerCase()) {
      case 'vegan':
      case 'vegetarian':
        return AppColors.success;
      case 'keto':
      case 'gluten-free':
        return AppColors.accent;
      case 'spicy':
        return AppColors.primary;
      case 'halal':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../providers/favorites_provider.dart';

/// Heart toggle bound to [favoritesProvider].
class FavoriteButton extends ConsumerWidget {
  final String dishId;
  final double size;
  final bool filled; // render on a translucent circle (over photos)

  const FavoriteButton({
    super.key,
    required this.dishId,
    this.size = 22,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(dishId);
    final icon = Icon(
      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      color: isFav ? AppColors.primary : (filled ? Colors.white : AppColors.textSecondary),
      size: size,
    );

    return GestureDetector(
      onTap: () => ref.read(favoritesProvider.notifier).toggle(dishId),
      child: filled
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0x66000000),
                shape: BoxShape.circle,
              ),
              child: icon,
            )
          : Padding(padding: const EdgeInsets.all(4), child: icon),
    );
  }
}

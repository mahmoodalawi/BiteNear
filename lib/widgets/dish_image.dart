import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Network image with graceful loading + error placeholders, used for all
/// dish/restaurant photos so failures never break the layout.
class DishImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const DishImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _Placeholder(width: width, height: height),
      errorWidget: (_, __, ___) => _Placeholder(
        width: width,
        height: height,
        icon: Icons.restaurant_rounded,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;

  const _Placeholder({
    this.width,
    this.height,
    this.icon = Icons.image_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.divider,
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.textSecondary, size: 32),
    );
  }
}

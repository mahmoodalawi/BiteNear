import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/location_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/dish_preview_sheet.dart';
import '../../widgets/results_map.dart';

/// Full-screen map of nearby dishes. Pins open a preview sheet; "Search this
/// area" re-queries around the current map center.
class MapViewScreen extends ConsumerWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(currentLocationProvider);
    final feed = ref.watch(nearbyFeedProvider);

    return Scaffold(
      body: origin.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Location error: $e')),
        data: (point) {
          return Stack(
            children: [
              feed.maybeWhen(
                data: (items) => ResultsMap(
                  results: items,
                  origin: point,
                  onMarkerTap: (r) => DishPreviewSheet.show(context, r),
                ),
                orElse: () => const Center(child: CircularProgressIndicator()),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 12),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Explore dishes near you',
                            style: AppTextStyles.subtitle),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.charcoal,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () => ref.invalidate(nearbyFeedProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Search this area'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

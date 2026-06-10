import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../router/routes.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/quick_filter_chips.dart';
import 'widgets/home_search_bar.dart';

/// Landing feed: greeting, search entry, quick filters and "Nearby Right Now".
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context, String query) {
    context.pushNamed(
      AppRoute.search.name,
      queryParameters: query.isEmpty ? null : {'q': query},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final feed = ref.watch(nearbyFeedProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(nearbyFeedProvider),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Greeting
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hungry, ${user?.displayName ?? 'there'}? 👋',
                              style: AppTextStyles.bodyMuted),
                          const SizedBox(height: 2),
                          Text("What are you craving?",
                              style: AppTextStyles.headline),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? const Icon(Icons.person_rounded,
                              color: AppColors.primary)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search bar (tap navigates to results screen)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: HomeSearchBar(onSubmitted: (q) => _openSearch(context, q)),
              ),
              const SizedBox(height: 16),

              // Quick filters
              QuickFilterChips(
                items: AppConstants.quickFilters,
                onSelected: (term) => _openSearch(context, term),
              ),
              const SizedBox(height: 24),

              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nearby Right Now', style: AppTextStyles.title),
                    TextButton(
                      onPressed: () => _openSearch(context, ''),
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Horizontal carousel of nearest dishes
              SizedBox(
                height: 250,
                child: feed.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(child: Text('Something went wrong: $e')),
                  data: (items) {
                    if (items.isEmpty) {
                      return const EmptyState(
                        icon: Icons.restaurant_rounded,
                        title: 'Nothing nearby yet',
                        message: 'Try widening your search radius.',
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) => DishCard(result: items[i]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Vertical "Trending dishes" list reusing the same feed.
              feed.maybeWhen(
                data: (items) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Trending dishes', style: AppTextStyles.title),
                    ),
                    const SizedBox(height: 8),
                    ...items.take(6).map(
                          (r) => Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: DishListTile(result: r),
                          ),
                        ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

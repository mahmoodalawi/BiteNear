import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/reviews_provider.dart';
import '../../router/routes.dart';
import '../../services/mock_data.dart';

/// User profile: identity card, quick stats and settings/actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final favCount = ref.watch(favoritesProvider).length;

    // Count locally-authored reviews across all demo dishes.
    final myReviews = MockData.dishes
        .map((d) => ref.watch(dishReviewsProvider(d.id)))
        .expand((list) => list)
        .where((r) => r.userId == (user?.uid ?? 'guest'))
        .length;

    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: AppTextStyles.headline)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Identity card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.warmGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(Icons.person_rounded,
                          color: Colors.white, size: 32)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'Guest',
                          style: AppTextStyles.headline
                              .copyWith(color: Colors.white)),
                      Text(
                        user?.isGuest == true
                            ? 'Browsing as guest'
                            : (user?.email ?? ''),
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              _StatCard(label: 'Saved', value: '$favCount', icon: Icons.favorite_rounded),
              const SizedBox(width: 12),
              _StatCard(label: 'Reviews', value: '$myReviews', icon: Icons.reviews_rounded),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          _ActionTile(
            icon: Icons.favorite_border_rounded,
            label: 'Saved dishes',
            onTap: () => context.goNamed(AppRoute.saved.name),
          ),
          _ActionTile(
            icon: Icons.storefront_rounded,
            label: 'Restaurant dashboard',
            subtitle: 'Manage your menu & analytics',
            onTap: () => context.pushNamed(AppRoute.dashboard.name),
          ),
          _ActionTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () => _todo(context),
          ),
          _ActionTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & support',
            onTap: () => _todo(context),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            danger: true,
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('${AppConstants.appName} • v1.0.0',
                style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }

  void _todo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon in a future release.')),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.headline),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: danger ? AppColors.error : AppColors.primary),
      title: Text(label, style: AppTextStyles.subtitle.copyWith(color: color)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption)
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

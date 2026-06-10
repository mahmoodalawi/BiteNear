import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Shared layout for login/signup: branded header + scrollable form body.
class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.warmGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(AppConstants.appName, style: AppTextStyles.headline),
                ],
              ),
              const SizedBox(height: 40),
              Text(title, style: AppTextStyles.displayLarge),
              const SizedBox(height: 8),
              Text(subtitle, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import 'service_providers.dart';

/// Whether the user has completed onboarding (persisted).
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._ref)
      : super(_ref.read(sharedPrefsProvider).getBool(
                AppConstants.prefOnboardingSeen,
              ) ??
            false);

  final Ref _ref;

  Future<void> complete() async {
    await _ref
        .read(sharedPrefsProvider)
        .setBool(AppConstants.prefOnboardingSeen, true);
    state = true;
  }
}

final onboardingSeenProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref);
});

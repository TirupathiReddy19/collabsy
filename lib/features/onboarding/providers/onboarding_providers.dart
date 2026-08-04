import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_providers.g.dart';

/// Tracks which onboarding slide is currently visible so the dot
/// indicator can stay in sync with the PageView.
@riverpod
class OnboardingPageIndex extends _$OnboardingPageIndex {
  @override
  int build() => 0;

  void set(int value) => state = value;
}

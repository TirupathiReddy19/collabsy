// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks which onboarding slide is currently visible so the dot
/// indicator can stay in sync with the PageView.

@ProviderFor(OnboardingPageIndex)
final onboardingPageIndexProvider = OnboardingPageIndexProvider._();

/// Tracks which onboarding slide is currently visible so the dot
/// indicator can stay in sync with the PageView.
final class OnboardingPageIndexProvider
    extends $NotifierProvider<OnboardingPageIndex, int> {
  /// Tracks which onboarding slide is currently visible so the dot
  /// indicator can stay in sync with the PageView.
  OnboardingPageIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingPageIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingPageIndexHash();

  @$internal
  @override
  OnboardingPageIndex create() => OnboardingPageIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$onboardingPageIndexHash() =>
    r'979d3f33349a1f48e67f1f70e7f59fa97f1a7fb7';

/// Tracks which onboarding slide is currently visible so the dot
/// indicator can stay in sync with the PageView.

abstract class _$OnboardingPageIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

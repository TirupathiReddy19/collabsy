// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_account_moderation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Suspending/reinstating a Creator or Brand account found violating the
/// Terms of Service — shared between the Creator and Brand detail screens.
/// The actual enforcement happens server-side (disabling the Firebase Auth
/// user, revoking sessions) via `suspendUserAccount`/`reinstateUserAccount`;
/// this is just the thin client-side call.

@ProviderFor(AdminAccountModerationController)
final adminAccountModerationControllerProvider =
    AdminAccountModerationControllerProvider._();

/// Suspending/reinstating a Creator or Brand account found violating the
/// Terms of Service — shared between the Creator and Brand detail screens.
/// The actual enforcement happens server-side (disabling the Firebase Auth
/// user, revoking sessions) via `suspendUserAccount`/`reinstateUserAccount`;
/// this is just the thin client-side call.
final class AdminAccountModerationControllerProvider
    extends $AsyncNotifierProvider<AdminAccountModerationController, void> {
  /// Suspending/reinstating a Creator or Brand account found violating the
  /// Terms of Service — shared between the Creator and Brand detail screens.
  /// The actual enforcement happens server-side (disabling the Firebase Auth
  /// user, revoking sessions) via `suspendUserAccount`/`reinstateUserAccount`;
  /// this is just the thin client-side call.
  AdminAccountModerationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminAccountModerationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminAccountModerationControllerHash();

  @$internal
  @override
  AdminAccountModerationController create() =>
      AdminAccountModerationController();
}

String _$adminAccountModerationControllerHash() =>
    r'd619a0e3634d924147de22082964feb7c548e433';

/// Suspending/reinstating a Creator or Brand account found violating the
/// Terms of Service — shared between the Creator and Brand detail screens.
/// The actual enforcement happens server-side (disabling the Firebase Auth
/// user, revoking sessions) via `suspendUserAccount`/`reinstateUserAccount`;
/// this is just the thin client-side call.

abstract class _$AdminAccountModerationController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

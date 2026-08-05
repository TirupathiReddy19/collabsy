import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'admin_account_moderation_providers.g.dart';

/// Suspending/reinstating a Creator or Brand account found violating the
/// Terms of Service — shared between the Creator and Brand detail screens.
/// The actual enforcement happens server-side (disabling the Firebase Auth
/// user, revoking sessions) via `suspendUserAccount`/`reinstateUserAccount`;
/// this is just the thin client-side call.
@Riverpod(keepAlive: true)
class AdminAccountModerationController
    extends _$AdminAccountModerationController {
  @override
  FutureOr<void> build() {}

  Future<void> suspendAccount({required String uid, String? reason}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('suspendUserAccount')
          .call({'uid': uid, if (reason != null) 'reason': reason}),
    );
  }

  Future<void> reinstateAccount(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('reinstateUserAccount')
          .call({'uid': uid}),
    );
  }
}

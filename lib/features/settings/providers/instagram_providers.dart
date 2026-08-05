import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/instagram_auth_service.dart';
import '../data/instagram_repository.dart';
import '../models/instagram_account.dart';

part 'instagram_providers.g.dart';

@Riverpod(keepAlive: true)
InstagramRepository instagramRepository(Ref ref) {
  return InstagramRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
}

@Riverpod(keepAlive: true)
InstagramAuthService instagramAuthService(Ref ref) {
  return const InstagramAuthService();
}

// Both read the user from authStateChangesProvider rather than
// authRepositoryProvider.currentUser — the latter is a plain getter, so
// watching it doesn't rebuild this provider when auth state actually
// changes, and it would lock in whatever currentUser was the first time
// something read this provider for the rest of the app session.
@Riverpod(keepAlive: true)
Stream<InstagramAccount?> ownInstagramAccount(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(instagramRepositoryProvider).watchAccount(user.uid);
}

/// A specific creator's connected Instagram account, for the Brand-facing
/// public profile view — same data as [ownInstagramAccountProvider], just
/// parameterized by whichever creator is being viewed rather than always
/// the signed-in user.
@riverpod
Stream<InstagramAccount?> instagramAccountForUser(Ref ref, String userId) {
  return ref.watch(instagramRepositoryProvider).watchAccount(userId);
}

/// Every connected Instagram account — for the Admin Creators list.
@Riverpod(keepAlive: true)
Stream<List<InstagramAccount>> allInstagramAccounts(Ref ref) {
  return ref.watch(instagramRepositoryProvider).watchAllAccounts();
}

/// Drives the Connected Accounts screen's connect/disconnect/refresh
/// actions and their loading/error state.
@Riverpod(keepAlive: true)
class InstagramController extends _$InstagramController {
  @override
  FutureOr<void> build() {}

  Future<void> connect(BuildContext context) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(instagramAuthServiceProvider);
      final code = await authService.authorize(context);
      await ref.read(instagramRepositoryProvider).connect(code);
    });
  }

  Future<void> disconnect() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(instagramRepositoryProvider).disconnect(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(instagramRepositoryProvider).refresh(),
    );
  }
}

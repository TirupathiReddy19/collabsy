import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/creator_profile_repository.dart';
import '../models/collaboration_preference.dart';
import '../models/creator_gender.dart';
import '../models/creator_profile.dart';

part 'creator_profile_providers.g.dart';

@Riverpod(keepAlive: true)
CreatorProfileRepository creatorProfileRepository(Ref ref) {
  return CreatorProfileRepository(ref.watch(firestoreProvider));
}

/// The signed-in creator's own `creatorProfiles/{uid}` document.
@Riverpod(keepAlive: true)
Future<CreatorProfile?> ownCreatorProfile(Ref ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Future.value(null);
  return ref
      .watch(creatorProfileRepositoryProvider)
      .fetchCreatorProfile(user.uid);
}

/// Live version of [ownCreatorProfileProvider] — the verification-pending
/// screen watches this so it can move on the instant an admin decides,
/// rather than requiring an app relaunch to notice.
///
/// Reads the user from [authStateChangesProvider] rather than
/// `authRepositoryProvider.currentUser` — the latter is a plain getter, so
/// watching it doesn't rebuild this provider when auth state actually
/// changes. It would lock in whatever `currentUser` was the first time
/// something read this provider (often null, before login even resolves)
/// and never update again for the rest of the app session, which is
/// exactly the kind of stale read the router's live verification gate
/// depends on this provider NOT being.
@Riverpod(keepAlive: true)
Stream<CreatorProfile?> ownCreatorProfileStream(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(creatorProfileRepositoryProvider).watchProfile(user.uid);
}

/// Every creator profile, for the Brand's Discover directory.
@Riverpod(keepAlive: true)
Stream<List<CreatorProfile>> creatorDirectory(Ref ref) {
  return ref.watch(creatorProfileRepositoryProvider).watchDirectory();
}

/// A specific creator's profile, for the Brand-facing public profile view.
@riverpod
Future<CreatorProfile?> creatorProfileById(Ref ref, String creatorId) {
  return ref
      .watch(creatorProfileRepositoryProvider)
      .fetchCreatorProfile(creatorId);
}

/// Category/state/language filters for the Brand's Discover screen —
/// all multi-select, applied client-side over [creatorDirectoryProvider]'s
/// full list (a creator matches if they have ANY of the selected values
/// for that dimension).
@Riverpod(keepAlive: true)
class DiscoverCategoryFilter extends _$DiscoverCategoryFilter {
  @override
  Set<String> build() => {};

  void set(Set<String> value) => state = value;
}

@Riverpod(keepAlive: true)
class DiscoverStateFilter extends _$DiscoverStateFilter {
  @override
  Set<String> build() => {};

  void set(Set<String> value) => state = value;
}

@Riverpod(keepAlive: true)
class DiscoverLanguageFilter extends _$DiscoverLanguageFilter {
  @override
  Set<String> build() => {};

  void set(Set<String> value) => state = value;
}

/// Drives editing the creator's own profile (bio/categories).
@Riverpod(keepAlive: true)
class CreatorProfileController extends _$CreatorProfileController {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({
    String? bio,
    List<String>? categories,
    List<String>? languages,
    String? stateName,
    String? city,
    CreatorGender? gender,
    CollaborationPreference? collaborationPreference,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to update a profile for.');
      }
      await ref
          .read(creatorProfileRepositoryProvider)
          .updateProfile(
            userId: user.uid,
            bio: bio,
            categories: categories,
            languages: languages,
            state: stateName,
            city: city,
            gender: gender,
            collaborationPreference: collaborationPreference,
          );
      ref.invalidate(ownCreatorProfileProvider);
    });
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/brand_profile_repository.dart';
import '../models/brand_profile.dart';

part 'brand_profile_providers.g.dart';

@Riverpod(keepAlive: true)
BrandProfileRepository brandProfileRepository(Ref ref) {
  return BrandProfileRepository(ref.watch(firestoreProvider));
}

/// The signed-in brand's own `brandProfiles/{uid}` document.
@Riverpod(keepAlive: true)
Future<BrandProfile?> ownBrandProfile(Ref ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Future.value(null);
  return ref.watch(brandProfileRepositoryProvider).fetchBrandProfile(user.uid);
}

/// Live version of [ownBrandProfileProvider] — the verification-pending
/// screen watches this so it can move on the instant an admin decides,
/// rather than requiring an app relaunch to notice.
@Riverpod(keepAlive: true)
Stream<BrandProfile?> ownBrandProfileStream(Ref ref) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return Stream.value(null);
  return ref.watch(brandProfileRepositoryProvider).watchProfile(user.uid);
}

/// A specific brand's `brandProfiles` document by ID — for showing a
/// brand's profile to a creator (e.g. tapping the brand header on a
/// campaign they're viewing), as opposed to [ownBrandProfileProvider]
/// which is always the signed-in brand's own.
@riverpod
Future<BrandProfile?> brandProfileById(Ref ref, String brandId) {
  return ref.watch(brandProfileRepositoryProvider).fetchBrandProfile(brandId);
}

/// Every brand profile, for the Admin's Brands directory.
@Riverpod(keepAlive: true)
Stream<List<BrandProfile>> brandDirectory(Ref ref) {
  return ref.watch(brandProfileRepositoryProvider).watchDirectory();
}

/// Drives editing the brand's own profile (bio/industries/website).
@Riverpod(keepAlive: true)
class BrandProfileController extends _$BrandProfileController {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({
    String? companyName,
    String? designation,
    String? bio,
    List<String>? categories,
    String? website,
    String? companySize,
    String? linkedinUrl,
    String? stateName,
    String? city,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw StateError('No active session to update a profile for.');
      }
      await ref
          .read(brandProfileRepositoryProvider)
          .updateProfile(
            userId: user.uid,
            companyName: companyName,
            designation: designation,
            bio: bio,
            categories: categories,
            website: website,
            companySize: companySize,
            linkedinUrl: linkedinUrl,
            state: stateName,
            city: city,
          );
      ref.invalidate(ownBrandProfileProvider);
    });
  }
}

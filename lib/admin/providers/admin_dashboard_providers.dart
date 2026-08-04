import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'admin_dashboard_providers.g.dart';

/// Real Firestore-backed counts for the dashboard's top stat row — no
/// wallet/GMV/revenue numbers, since no financial feature exists yet.
@riverpod
Future<int> totalCreatorsCount(Ref ref) async {
  final snapshot = await ref
      .watch(firestoreProvider)
      .collection('users')
      .where('role', isEqualTo: 'creator')
      .count()
      .get();
  return snapshot.count ?? 0;
}

@riverpod
Future<int> totalBrandsCount(Ref ref) async {
  final snapshot = await ref
      .watch(firestoreProvider)
      .collection('users')
      .where('role', isEqualTo: 'brand')
      .count()
      .get();
  return snapshot.count ?? 0;
}

@riverpod
Future<int> activeCampaignsCount(Ref ref) async {
  final snapshot = await ref
      .watch(firestoreProvider)
      .collection('campaigns')
      .where('status', isEqualTo: 'active')
      .count()
      .get();
  return snapshot.count ?? 0;
}

@riverpod
Future<int> totalApplicationsCount(Ref ref) async {
  final snapshot = await ref
      .watch(firestoreProvider)
      .collection('applications')
      .count()
      .get();
  return snapshot.count ?? 0;
}

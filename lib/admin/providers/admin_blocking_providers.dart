import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../features/blocking/models/block.dart';
import '../../features/blocking/models/user_report.dart';

part 'admin_blocking_providers.g.dart';

/// Every block relationship on the platform, newest first — read-only,
/// feeds the Trust & Safety "Blocked pairs" section.
@riverpod
Stream<List<Block>> allBlocks(Ref ref) {
  return ref.watch(firestoreProvider).collection('blocks').snapshots().map((
    snapshot,
  ) {
    final items = snapshot.docs
        .map((doc) => Block.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    items.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items;
  });
}

/// Every user report, newest first — feeds the Trust & Safety "Reports
/// queue" section.
@riverpod
Stream<List<UserReport>> allReports(Ref ref) {
  return ref.watch(firestoreProvider).collection('reports').snapshots().map((
    snapshot,
  ) {
    final items = snapshot.docs
        .map((doc) => UserReport.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    items.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items;
  });
}

@Riverpod(keepAlive: true)
class AdminBlockingController extends _$AdminBlockingController {
  @override
  FutureOr<void> build() {}

  Future<void> markReportReviewed(String reportId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(firestoreProvider)
          .collection('reports')
          .doc(reportId)
          .update({'status': 'reviewed'}),
    );
  }
}

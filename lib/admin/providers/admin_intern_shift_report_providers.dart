import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';
import '../../shared/utils/date_key.dart';

part 'admin_intern_shift_report_providers.g.dart';

typedef InternShiftStat = ({
  String internId,
  String internEmail,
  int activeSeconds,
});

/// Every intern's `internShiftStats` doc for [date] — see
/// `lib/intern/providers/intern_shift_providers.dart` for the write side.
@riverpod
Stream<List<InternShiftStat>> allInternShiftStatsForDate(
  Ref ref,
  DateTime date,
) {
  return ref
      .watch(firestoreProvider)
      .collection('internShiftStats')
      .where('date', isEqualTo: dateKey(date))
      .snapshots()
      .map((snapshot) {
        final stats = snapshot.docs.map((doc) {
          final data = doc.data();
          return (
            internId: data['internId'] as String? ?? '',
            internEmail: data['internEmail'] as String? ?? '',
            activeSeconds: data['activeSeconds'] as int? ?? 0,
          );
        }).toList();
        stats.sort((a, b) => a.internEmail.compareTo(b.internEmail));
        return stats;
      });
}

typedef InternMessageCount = ({String internEmail, int count});

/// Number of `leads` each intern created on [date], keyed by `internId` —
/// same "messages sent" count the intern tool itself shows, computed here
/// across every intern instead of just the signed-in one. Carries
/// `internEmail` too so an intern who sent messages but has no
/// `internShiftStats` doc yet (e.g. very first tick hasn't landed) still
/// shows up by name in the report.
@riverpod
Stream<Map<String, InternMessageCount>> internMessageCountsForDate(
  Ref ref,
  DateTime date,
) {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));
  return ref
      .watch(firestoreProvider)
      .collection('leads')
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('createdAt', isLessThan: Timestamp.fromDate(end))
      .snapshots()
      .map((snapshot) {
        final counts = <String, InternMessageCount>{};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final internId = data['internId'] as String? ?? '';
          final internEmail = data['internEmail'] as String? ?? '';
          final existing = counts[internId];
          counts[internId] = (
            internEmail: internEmail,
            count: (existing?.count ?? 0) + 1,
          );
        }
        return counts;
      });
}

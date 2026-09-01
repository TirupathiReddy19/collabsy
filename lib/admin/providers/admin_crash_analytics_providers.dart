import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/firebase_service.dart';

part 'admin_crash_analytics_providers.g.dart';

typedef DailyCrashCount = ({DateTime day, String platform, int count});

typedef TopCrashIssue = ({
  String issueId,
  String platform,
  String label,
  int eventCount,
  int affectedInstalls,
  DateTime lastSeenAt,
});

typedef TopDevice = ({
  String platform,
  String model,
  int eventCount,
  int affectedInstalls,
});

typedef CrashAnalytics = ({
  List<DailyCrashCount> trend,
  List<TopCrashIssue> topIssues,
  List<TopDevice> topDevices,
});

/// Calls the `getCrashAnalytics` Cloud Function, which queries Crashlytics'
/// BigQuery export directly — there's no Firestore copy of this data, so
/// unlike every other admin analytics provider this is a one-shot Future,
/// not a live stream. Requires the Crashlytics -> BigQuery link to be
/// turned on in Firebase Console; until then (or until the first export
/// has actually run) this returns empty trend/topIssues rather than an
/// error, since a missing BigQuery table is expected, not exceptional.
@riverpod
Future<CrashAnalytics> crashAnalytics(Ref ref, int days) async {
  final result = await ref
      .watch(firebaseFunctionsProvider)
      .httpsCallable('getCrashAnalytics')
      .call({'days': days});

  final data = result.data as Map<Object?, Object?>;
  final trend = (data['trend'] as List<Object?>)
      .cast<Map<Object?, Object?>>()
      .map(
        (e) => (
          day: DateTime.parse(e['day'] as String),
          platform: e['platform'] as String,
          count: (e['count'] as num).toInt(),
        ),
      )
      .toList();
  final topIssues = (data['topIssues'] as List<Object?>)
      .cast<Map<Object?, Object?>>()
      .map(
        (e) => (
          issueId: e['issueId'] as String,
          platform: e['platform'] as String,
          label: e['label'] as String,
          eventCount: (e['eventCount'] as num).toInt(),
          affectedInstalls: (e['affectedInstalls'] as num).toInt(),
          lastSeenAt: DateTime.parse(e['lastSeenAt'] as String),
        ),
      )
      .toList();

  final topDevices = (data['topDevices'] as List<Object?>)
      .cast<Map<Object?, Object?>>()
      .map(
        (e) => (
          platform: e['platform'] as String,
          model: e['model'] as String,
          eventCount: (e['eventCount'] as num).toInt(),
          affectedInstalls: (e['affectedInstalls'] as num).toInt(),
        ),
      )
      .toList();

  return (trend: trend, topIssues: topIssues, topDevices: topDevices);
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/firestore_converters.dart';
import '../../../shared/models/user_role.dart';
import 'report_reason.dart';

part 'user_report.freezed.dart';
part 'user_report.g.dart';

/// Matches a document in the `reports` collection — a moderation queue,
/// not a "my reports" feature: `firestore.rules` deliberately doesn't let
/// the reporter read it back afterward, only admin/trust-safety staff can.
@freezed
abstract class UserReport with _$UserReport {
  const factory UserReport({
    required String id,
    required String reporterId,
    required UserRole reporterRole,
    required String reportedId,
    required UserRole reportedRole,
    // Snapshotted at creation, same pattern as `campaignTitle` elsewhere —
    // avoids the admin queue needing a separate lookup per row.
    String? reportedName,
    required ReportReason reason,
    String? details,
    String? chatId,
    @Default('open') String status,
    @NullableTimestampConverter() DateTime? createdAt,
  }) = _UserReport;

  factory UserReport.fromJson(Map<String, dynamic> json) =>
      _$UserReportFromJson(json);
}

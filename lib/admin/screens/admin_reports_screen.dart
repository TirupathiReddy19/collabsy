import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/campaigns/models/campaign.dart';
import '../../features/campaigns/models/campaign_application.dart';
import '../../features/campaigns/providers/campaigns_providers.dart';
import '../../features/settings/providers/instagram_providers.dart';
import '../../features/support/models/support_chat.dart';
import '../../features/support/models/support_chat_status.dart';
import '../../features/support/models/support_message.dart';
import '../../features/support/providers/support_chat_providers.dart';
import '../../shared/models/announcement.dart';
import '../../shared/models/user_role.dart';
import '../models/audit_log.dart';
import '../providers/admin_analytics_providers.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_broadcast_providers.dart';
import '../providers/admin_dashboard_providers.dart';
import '../utils/creator_display_name.dart';
import '../utils/csv_download.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _fmtDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

String _dateKey(DateTime day) =>
    '${day.year}'
    '${day.month.toString().padLeft(2, '0')}'
    '${day.day.toString().padLeft(2, '0')}';

bool _inRange(DateTime? value, DateTime start, DateTime endExclusive) {
  if (value == null) return false;
  return !value.isBefore(start) && value.isBefore(endExclusive);
}

const _overdueThreshold = Duration(minutes: 30);

bool _isOverdue(SupportChat chat) {
  if (chat.status != SupportChatStatus.open) return false;
  if (chat.lastMessageSenderRole != SupportSenderRole.user) return false;
  final lastMessageAt = chat.lastMessageAt;
  if (lastMessageAt == null) return false;
  return DateTime.now().difference(lastMessageAt) > _overdueThreshold;
}

String _actionLabel(AuditLogAction action) => switch (action) {
  AuditLogAction.campaignApproved => 'Campaign approved',
  AuditLogAction.campaignRejected => 'Campaign rejected',
  AuditLogAction.brandVerified => 'Brand verified',
  AuditLogAction.brandRejected => 'Brand rejected',
  AuditLogAction.creatorVerified => 'Creator verified',
  AuditLogAction.creatorRejected => 'Creator rejected',
  AuditLogAction.staffAccountCreated => 'Staff role created',
  AuditLogAction.staffPermissionsUpdated => 'Staff permissions updated',
  AuditLogAction.staffAccountForcedLogout => 'Staff account force-logged-out',
  AuditLogAction.supportReplySent => 'Support reply sent',
  AuditLogAction.supportTicketResolved => 'Support ticket resolved',
  AuditLogAction.supportTicketReopened => 'Support ticket reopened',
  AuditLogAction.broadcastSent => 'Broadcast sent',
  AuditLogAction.outreachSettingsUpdated => 'Outreach settings updated',
  AuditLogAction.creatorSuspended => 'Creator suspended',
  AuditLogAction.creatorReinstated => 'Creator reinstated',
  AuditLogAction.brandSuspended => 'Brand suspended',
  AuditLogAction.brandReinstated => 'Brand reinstated',
};

enum _ReportSection {
  growth('Growth'),
  moderation('Moderation activity'),
  platformActivity('Platform activity'),
  campaigns('Campaigns & applications'),
  support('Support'),
  broadcasts('Broadcasts');

  const _ReportSection(this.label);
  final String label;
}

/// Admin-only, date-range view over data that already flows through
/// existing "watch all" providers (Analytics, Audit Logs, Campaigns,
/// Support, Broadcasts). A dropdown picks one section at a time, and each
/// shows the actual underlying records for the picked range — not just an
/// aggregate count — with a CSV export of whichever section is showing.
/// Super-admin-only: several of the underlying collections are gated
/// behind their own specific staff permission (`/analytics`, `/audit`,
/// `/support`), so a staff account granted only `/reports` would hit
/// permission-denied reading them — see the `isReportsRoute` guard in
/// `admin_router.dart`, mirroring `/roles`.
class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  late DateTime _start;
  late DateTime _end;
  _ReportSection _section = _ReportSection.growth;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _end = DateTime(today.year, today.month, today.day);
    _start = _end.subtract(const Duration(days: 29));
  }

  DateTime get _endExclusive => _end.add(const Duration(days: 1));

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: _end,
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final signupsAsync = ref.watch(allUserSignupsProvider);
    final activityAsync = ref.watch(allDailyActivityProvider);
    final auditLogsAsync = ref.watch(allAuditLogsProvider);
    final campaignsAsync = ref.watch(allCampaignsProvider);
    final applicationsAsync = ref.watch(allApplicationsProvider);
    final supportChatsAsync = ref.watch(allSupportChatsProvider);
    final announcementsAsync = ref.watch(allAnnouncementsProvider);

    final loaded =
        signupsAsync.value != null &&
        activityAsync.value != null &&
        auditLogsAsync.value != null &&
        campaignsAsync.value != null &&
        applicationsAsync.value != null &&
        supportChatsAsync.value != null &&
        announcementsAsync.value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(title: 'Reports'),
        Expanded(
          child: !loaded
              ? const Center(child: LoadingIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  child: _buildContent(
                    signups: signupsAsync.value!,
                    activity: activityAsync.value!,
                    auditLogs: auditLogsAsync.value!,
                    campaigns: campaignsAsync.value!,
                    applications: applicationsAsync.value!,
                    supportChats: supportChatsAsync.value!,
                    announcements: announcementsAsync.value!,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildContent({
    required List<UserSignup> signups,
    required List<DailyActivityEntry> activity,
    required List<AuditLogEntry> auditLogs,
    required List<Campaign> campaigns,
    required List<CampaignApplication> applications,
    required List<SupportChat> supportChats,
    required List<Announcement> announcements,
  }) {
    final roleByUserId = {for (final s in signups) s.userId: s.role};

    final signupsInRange =
        signups
            .where((s) => _inRange(s.createdAt, _start, _endExclusive))
            .toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );

    final logsInRange =
        auditLogs
            .where((l) => _inRange(l.timestamp, _start, _endExclusive))
            .toList()
          ..sort(
            (a, b) => (b.timestamp ?? DateTime(0)).compareTo(
              a.timestamp ?? DateTime(0),
            ),
          );

    final startKey = _dateKey(_start);
    final endKey = _dateKey(_end);
    final activityInRange = activity
        .where(
          (a) =>
              a.date.compareTo(startKey) >= 0 && a.date.compareTo(endKey) <= 0,
        )
        .toList();
    final activeDaysByUser = <String, int>{};
    for (final entry in activityInRange) {
      activeDaysByUser[entry.userId] =
          (activeDaysByUser[entry.userId] ?? 0) + 1;
    }
    final activeUserIds = activeDaysByUser.keys.toList()
      ..sort((a, b) => activeDaysByUser[b]!.compareTo(activeDaysByUser[a]!));

    final campaignsInRange =
        campaigns
            .where((c) => _inRange(c.createdAt, _start, _endExclusive))
            .toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );
    final applicationsInRange =
        applications
            .where((a) => _inRange(a.appliedAt, _start, _endExclusive))
            .toList()
          ..sort(
            (a, b) => (b.appliedAt ?? DateTime(0)).compareTo(
              a.appliedAt ?? DateTime(0),
            ),
          );

    final supportInRange =
        supportChats
            .where(
              (s) =>
                  _inRange(s.createdAt, _start, _endExclusive) ||
                  (s.status == SupportChatStatus.resolved &&
                      _inRange(s.lastMessageAt, _start, _endExclusive)),
            )
            .toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );

    final announcementsInRange =
        announcements
            .where((a) => _inRange(a.createdAt, _start, _endExclusive))
            .toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
              a.createdAt ?? DateTime(0),
            ),
          );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          const SizedBox(height: 24),
          _SectionCard(
            title: _section.label,
            subtitle: switch (_section) {
              _ReportSection.growth => 'New signups in this range.',
              _ReportSection.moderation => 'Every admin action in this range.',
              _ReportSection.platformActivity =>
                'Distinct users active at least once in this range.',
              _ReportSection.campaigns => 'Created/applied within this range.',
              _ReportSection.support =>
                '"Overdue" is a live snapshot, not range-scoped.',
              _ReportSection.broadcasts => 'Sent within this range.',
            },
            child: switch (_section) {
              _ReportSection.growth => _buildGrowth(signupsInRange),
              _ReportSection.moderation => _buildModeration(logsInRange),
              _ReportSection.platformActivity => _buildPlatformActivity(
                activeUserIds,
                activeDaysByUser,
                roleByUserId,
              ),
              _ReportSection.campaigns => _buildCampaigns(
                campaignsInRange,
                applicationsInRange,
              ),
              _ReportSection.support => _buildSupport(supportInRange),
              _ReportSection.broadcasts => _buildBroadcasts(
                announcementsInRange,
              ),
            },
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _isExporting
                  ? null
                  : () => _exportCsv(
                      signupsInRange: signupsInRange,
                      logsInRange: logsInRange,
                      activeUserIds: activeUserIds,
                      activeDaysByUser: activeDaysByUser,
                      roleByUserId: roleByUserId,
                      campaignsInRange: campaignsInRange,
                      applicationsInRange: applicationsInRange,
                      supportInRange: supportInRange,
                      announcementsInRange: announcementsInRange,
                    ),
              icon: _isExporting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: LoadingIndicator(size: 16, color: Colors.white),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text('Export ${_section.label} CSV'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGrowth(List<UserSignup> signupsInRange) {
    if (signupsInRange.isEmpty) {
      return _emptyText('No new signups in this range.');
    }
    return Column(
      children: signupsInRange
          .map(
            (s) => _UserListRow(
              userId: s.userId,
              role: s.role,
              trailing: s.createdAt == null ? null : _fmtDate(s.createdAt!),
            ),
          )
          .toList(),
    );
  }

  Widget _buildModeration(List<AuditLogEntry> logsInRange) {
    if (logsInRange.isEmpty) {
      return _emptyText('No admin actions in this range.');
    }
    return Column(
      children: logsInRange
          .map(
            (l) => _listTile(
              title: _actionLabel(l.action),
              subtitle:
                  '${l.targetName.isEmpty ? '—' : l.targetName} · ${l.actorEmail}',
              trailing: l.timestamp == null ? null : _fmtDate(l.timestamp!),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlatformActivity(
    List<String> activeUserIds,
    Map<String, int> activeDaysByUser,
    Map<String, UserRole?> roleByUserId,
  ) {
    if (activeUserIds.isEmpty) return _emptyText('No activity in this range.');
    return Column(
      children: activeUserIds
          .map(
            (userId) => _UserListRow(
              userId: userId,
              role: roleByUserId[userId],
              trailing: '${activeDaysByUser[userId]} day(s) active',
            ),
          )
          .toList(),
    );
  }

  Widget _buildCampaigns(
    List<Campaign> campaignsInRange,
    List<CampaignApplication> applicationsInRange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Campaigns', style: AppTextStyles.titleSmall),
        const SizedBox(height: 4),
        campaignsInRange.isEmpty
            ? _emptyText('No campaigns created in this range.')
            : Column(
                children: campaignsInRange
                    .map(
                      (c) => _listTile(
                        title: c.title,
                        subtitle: c.brandName,
                        trailing: c.status.label,
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 20),
        Text('Applications', style: AppTextStyles.titleSmall),
        const SizedBox(height: 4),
        applicationsInRange.isEmpty
            ? _emptyText('No applications submitted in this range.')
            : Column(
                children: applicationsInRange
                    .map(
                      (a) => _listTile(
                        title: a.creatorName,
                        subtitle: a.campaignTitle,
                        trailing: a.status.label,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildSupport(List<SupportChat> supportInRange) {
    if (supportInRange.isEmpty) {
      return _emptyText('No tickets opened or resolved in this range.');
    }
    return Column(
      children: supportInRange
          .map(
            (s) => _listTile(
              title: s.userName,
              subtitle: s.createdAt == null
                  ? s.status.label
                  : '${s.status.label} · opened ${_fmtDate(s.createdAt!)}',
              trailing: _isOverdue(s) ? 'Overdue' : null,
            ),
          )
          .toList(),
    );
  }

  Widget _buildBroadcasts(List<Announcement> announcementsInRange) {
    if (announcementsInRange.isEmpty) {
      return _emptyText('No broadcasts sent in this range.');
    }
    return Column(
      children: announcementsInRange
          .map((a) => _BroadcastReportRow(announcement: a))
          .toList(),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStart,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text('From: ${_fmtDate(_start)}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEnd,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text('To: ${_fmtDate(_end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<_ReportSection>(
            initialValue: _section,
            decoration: const InputDecoration(labelText: 'Report'),
            items: _ReportSection.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _section = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyText(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AdminColors.textSecondary(context),
      ),
    );
  }

  Widget _listTile({
    required String title,
    String? subtitle,
    String? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
        trailing: trailing == null
            ? null
            : Text(
                trailing,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: trailing == 'Overdue' ? AppColors.error : null,
                ),
              ),
      ),
    );
  }

  Future<void> _exportCsv({
    required List<UserSignup> signupsInRange,
    required List<AuditLogEntry> logsInRange,
    required List<String> activeUserIds,
    required Map<String, int> activeDaysByUser,
    required Map<String, UserRole?> roleByUserId,
    required List<Campaign> campaignsInRange,
    required List<CampaignApplication> applicationsInRange,
    required List<SupportChat> supportInRange,
    required List<Announcement> announcementsInRange,
  }) async {
    setState(() => _isExporting = true);
    try {
      final rows = <String>[];
      switch (_section) {
        case _ReportSection.growth:
          rows.add('Role,Signed up');
          for (final s in signupsInRange) {
            rows.add(
              '${_csvEscape(s.role?.label ?? '—')},'
              '${_csvEscape(s.createdAt == null ? '—' : _fmtDate(s.createdAt!))}',
            );
          }
        case _ReportSection.moderation:
          rows.add('Action,Target,Actor,When');
          for (final l in logsInRange) {
            rows.add(
              '${_csvEscape(_actionLabel(l.action))},${_csvEscape(l.targetName)},'
              '${_csvEscape(l.actorEmail)},'
              '${_csvEscape(l.timestamp == null ? '—' : _fmtDate(l.timestamp!))}',
            );
          }
        case _ReportSection.platformActivity:
          rows.add('Role,Days active in range');
          for (final userId in activeUserIds) {
            rows.add(
              '${_csvEscape(roleByUserId[userId]?.label ?? '—')},'
              '${activeDaysByUser[userId]}',
            );
          }
        case _ReportSection.campaigns:
          rows.add('Type,Title,Other party,Status');
          for (final c in campaignsInRange) {
            rows.add(
              'Campaign,${_csvEscape(c.title)},${_csvEscape(c.brandName)},'
              '${_csvEscape(c.status.label)}',
            );
          }
          for (final a in applicationsInRange) {
            rows.add(
              'Application,${_csvEscape(a.campaignTitle)},${_csvEscape(a.creatorName)},'
              '${_csvEscape(a.status.label)}',
            );
          }
        case _ReportSection.support:
          rows.add('User,Status,Opened,Overdue');
          for (final s in supportInRange) {
            rows.add(
              '${_csvEscape(s.userName)},${_csvEscape(s.status.label)},'
              '${_csvEscape(s.createdAt == null ? '—' : _fmtDate(s.createdAt!))},'
              '${_isOverdue(s) ? 'Yes' : 'No'}',
            );
          }
        case _ReportSection.broadcasts:
          rows.add('Title,Sent,Seen by');
          final totalCreators = await ref.read(
            totalCreatorsCountProvider.future,
          );
          for (final a in announcementsInRange) {
            final sentAt = a.createdAt;
            final seen = sentAt == null
                ? 0
                : await ref.read(
                    announcementSeenCountProvider(
                      sentAt.millisecondsSinceEpoch,
                    ).future,
                  );
            rows.add(
              '${_csvEscape(a.title)},'
              '${_csvEscape(sentAt == null ? '—' : _fmtDate(sentAt))},'
              '${_csvEscape('$seen of $totalCreators creators')}',
            );
          }
      }

      downloadCsv(
        'collabsy-${_section.name}-${_dateKey(_start)}-to-${_dateKey(_end)}.csv',
        rows.join('\n'),
      );
      if (mounted) AppSnackbar.showSuccess(context, 'Report exported.');
    } catch (error) {
      if (mounted) {
        AppSnackbar.showError(context, "Couldn't export the report.");
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// A signed-up or active user resolved to a real name — Instagram-name
/// fallback for creators (see `creatorDisplayNameFor`), display name/email
/// fallback for brands — since [UserSignup]/`dailyActivity` only carry a
/// uid, not an identity.
class _UserListRow extends ConsumerWidget {
  const _UserListRow({required this.userId, required this.role, this.trailing});

  final String userId;
  final UserRole? role;
  final String? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProfileByIdProvider(userId));
    final instagram = role == UserRole.creator
        ? ref.watch(instagramAccountForUserProvider(userId)).value
        : null;

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        final name = role == UserRole.creator
            ? creatorDisplayNameFor(user, instagram)
            : (user.displayName?.isNotEmpty == true
                  ? user.displayName!
                  : (user.email ?? user.phone ?? 'Brand'));
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: ProfileAvatar(
              avatarUrl: instagram?.profilePictureUrl ?? user.avatarUrl,
              fallbackIcon: role == UserRole.creator
                  ? Icons.person
                  : Icons.storefront,
              radius: 16,
            ),
            title: Text(name, style: AppTextStyles.bodyMedium),
            subtitle: Text(
              role?.label ?? 'Unknown role',
              style: AppTextStyles.bodySmall.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
            trailing: trailing == null
                ? null
                : Text(
                    trailing!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text('Loading…'),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _BroadcastReportRow extends ConsumerWidget {
  const _BroadcastReportRow({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentAt = announcement.createdAt;
    final seenAsync = sentAt == null
        ? const AsyncValue<int>.data(0)
        : ref.watch(
            announcementSeenCountProvider(sentAt.millisecondsSinceEpoch),
          );
    final totalCreatorsAsync = ref.watch(totalCreatorsCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(announcement.title, style: AppTextStyles.bodyMedium),
        subtitle: Text(
          sentAt == null ? '—' : _fmtDate(sentAt),
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
        trailing: Text(
          seenAsync.when(
            data: (seen) => totalCreatorsAsync.when(
              data: (total) => 'Seen by $seen of $total',
              loading: () => 'Seen by $seen',
              error: (error, stackTrace) => 'Seen by $seen',
            ),
            loading: () => 'Loading…',
            error: (error, stackTrace) => '—',
          ),
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

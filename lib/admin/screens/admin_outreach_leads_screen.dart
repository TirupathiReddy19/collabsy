import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../shared/models/lead.dart';
import '../providers/admin_leads_providers.dart';
import '../utils/csv_download.dart';
import '../widgets/admin_row_skeleton.dart';
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

String _fmtDate(DateTime? date) {
  if (date == null) return '—';
  return '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

bool _inRange(DateTime? value, DateTime start, DateTime endExclusive) {
  if (value == null) return false;
  return !value.isBefore(start) && value.isBefore(endExclusive);
}

String _dateKey(DateTime day) =>
    '${day.year}'
    '${day.month.toString().padLeft(2, '0')}'
    '${day.day.toString().padLeft(2, '0')}';

/// A lead that hasn't been clicked yet needs a follow-up once it's been
/// sitting this long since the link was generated. A lead that was
/// clicked but never signed up needs one once it's been this long since
/// the click — except once the intern has actually logged a follow-up
/// send (`lastFollowUpSentAt` set), at which point it drops out of the
/// bucket for good. Mirrors `intern_home_screen.dart`'s `_needsFollowUp`.
const _followUpNoClickAfter = Duration(days: 3);
const _followUpNoSignupAfter = Duration(days: 7);

bool _needsFollowUp(Lead lead) {
  if (lead.lastFollowUpSentAt != null) return false;
  final now = DateTime.now();
  if (lead.status == 'linkGenerated' && lead.createdAt != null) {
    return now.difference(lead.createdAt!) >= _followUpNoClickAfter;
  }
  if (lead.status == 'clicked' && lead.clickedAt != null) {
    return now.difference(lead.clickedAt!) >= _followUpNoSignupAfter;
  }
  return false;
}

enum _StatusFilter {
  all('All statuses'),
  needsFollowUp('Needs follow-up'),
  linkGenerated('Link generated'),
  clicked('Clicked'),
  signedUp('Signed up'),
  onboardingComplete('Onboarding complete');

  const _StatusFilter(this.label);
  final String label;
}

String _statusLabel(String status) => switch (status) {
  'clicked' => 'Clicked',
  'signedUp' => 'Signed up',
  'onboardingComplete' => 'Onboarding complete',
  _ => 'Link generated',
};

Color _statusColor(BuildContext context, String status) => switch (status) {
  'clicked' => AppColors.info,
  'signedUp' => Colors.purple,
  'onboardingComplete' => AppColors.success,
  _ => AdminColors.textSecondary(context),
};

String _csvEscape(String value) => '"${value.replaceAll('"', '""')}"';

/// Cross-intern tracking view over `leads` — mirrors `admin_reports_screen
/// .dart`'s date-range + filter + CSV-export shape. Every intern's own
/// tool only shows their own leads (see `intern_home_screen.dart`); this is
/// the only place the full outreach funnel (clicked/signedUp/onboarding
/// complete) is visible across everyone.
class AdminOutreachLeadsScreen extends ConsumerStatefulWidget {
  const AdminOutreachLeadsScreen({super.key});

  @override
  ConsumerState<AdminOutreachLeadsScreen> createState() =>
      _AdminOutreachLeadsScreenState();
}

class _AdminOutreachLeadsScreenState
    extends ConsumerState<AdminOutreachLeadsScreen> {
  late DateTime _start;
  late DateTime _end;
  _StatusFilter _statusFilter = _StatusFilter.all;

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

  List<Lead> _filter(List<Lead> leads) {
    return leads.where((lead) {
      if (!_inRange(lead.createdAt, _start, _endExclusive)) return false;
      switch (_statusFilter) {
        case _StatusFilter.all:
          return true;
        case _StatusFilter.needsFollowUp:
          return _needsFollowUp(lead);
        default:
          return lead.status == _statusFilter.name;
      }
    }).toList();
  }

  void _exportCsv(List<Lead> leads) {
    final rows = <String>['Handle,Intern,Status,Created,Clicks,Signed up'];
    for (final lead in leads) {
      rows.add(
        '${_csvEscape(lead.handle)},${_csvEscape(lead.internEmail)},'
        '${_csvEscape(_statusLabel(lead.status))},'
        '${_csvEscape(_fmtDate(lead.createdAt))},'
        '${lead.clickCount},'
        '${_csvEscape(lead.signedUpAt == null ? '—' : _fmtDate(lead.signedUpAt))}',
      );
    }
    downloadCsv(
      'collabsy-outreach-leads-${_dateKey(_start)}-to-${_dateKey(_end)}.csv',
      rows.join('\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(allLeadsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Outreach Leads',
          subtitle:
              'Intern cold-outreach tracking — clicked, signed up, '
              'onboarding complete',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: leadsAsync.when(
              loading: () => AdminListSkeleton(
                rowBuilder: (_) => const AdminPlainRowSkeleton(),
              ),
              error: (error, stackTrace) => Text(
                "Couldn't load leads: $error",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              data: (allLeads) {
                final leads = _filter(allLeads);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                                  icon: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                  ),
                                  label: Text('From: ${_fmtDate(_start)}'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickEnd,
                                  icon: const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                  ),
                                  label: Text('To: ${_fmtDate(_end)}'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<_StatusFilter>(
                            initialValue: _statusFilter,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                            ),
                            items: _StatusFilter.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _statusFilter = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${leads.length} lead${leads.length == 1 ? '' : 's'}',
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                        IntrinsicWidth(
                          child: OutlinedButton.icon(
                            onPressed: leads.isEmpty
                                ? null
                                : () => _exportCsv(leads),
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Export CSV'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (leads.isEmpty)
                      Text(
                        'No leads in this range.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AdminColors.textSecondary(context),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (final (index, lead) in leads.indexed)
                            StaggeredFadeIn(
                              key: ValueKey(lead.handle),
                              delay: Duration(
                                milliseconds: (index * 40).clamp(0, 400),
                              ),
                              child: _LeadRow(lead: lead),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadRow extends StatelessWidget {
  const _LeadRow({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${lead.handle}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${lead.internEmail} · ${_fmtDate(lead.createdAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AdminColors.textSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${lead.clickCount} click${lead.clickCount == 1 ? '' : 's'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
          ),
          if (_needsFollowUp(lead)) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Follow up',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(context, lead.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _statusLabel(lead.status),
              style: AppTextStyles.bodySmall.copyWith(
                color: _statusColor(context, lead.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

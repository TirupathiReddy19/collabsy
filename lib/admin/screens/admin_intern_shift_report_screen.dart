import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../providers/admin_intern_shift_report_providers.dart';
import '../theme/admin_colors.dart';
import '../widgets/admin_row_skeleton.dart';
import '../widgets/admin_top_bar.dart';

const _shiftTargetHours = 4;
const _shiftMessageTarget = 200;

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

/// One row per intern for a given day — hours actually spent with the
/// outreach tool's tab focused (see
/// `lib/intern/screens/intern_home_screen.dart`) plus messages sent that
/// day, against the 4h / 250-message shift targets. Merges
/// `internShiftStats` (hours) with a `leads` count (messages) since an
/// intern who just started their shift may have sent messages before
/// their first shift-stat tick lands.
class AdminInternShiftReportScreen extends ConsumerStatefulWidget {
  const AdminInternShiftReportScreen({super.key});

  @override
  ConsumerState<AdminInternShiftReportScreen> createState() =>
      _AdminInternShiftReportScreenState();
}

class _AdminInternShiftReportScreenState
    extends ConsumerState<AdminInternShiftReportScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(
        () => _selectedDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(
      allInternShiftStatsForDateProvider(_selectedDate),
    );
    final countsAsync = ref.watch(
      internMessageCountsForDateProvider(_selectedDate),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Intern Shift Report',
          subtitle:
              'Hours actually spent in the tool (tab-focused time only) '
              'and messages sent, per intern per day',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            0,
          ),
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(_fmtDate(_selectedDate)),
          ),
        ),
        Expanded(
          child: statsAsync.when(
            loading: () => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.md,
              ),
              child: AdminListSkeleton(
                rowBuilder: (_) => const AdminIconRowSkeleton(),
              ),
            ),
            error: (error, _) => Center(child: Text('Failed to load: $error')),
            data: (stats) {
              final counts = countsAsync.value ?? const {};

              final internIds = <String>{
                ...stats.map((s) => s.internId),
                ...counts.keys,
              }..removeWhere((id) => id.isEmpty);

              final rows =
                  internIds.map((internId) {
                      final stat = stats
                          .where((s) => s.internId == internId)
                          .cast<InternShiftStat?>()
                          .firstWhere((s) => true, orElse: () => null);
                      final count = counts[internId];
                      return (
                        internId: internId,
                        internEmail:
                            stat?.internEmail ?? count?.internEmail ?? internId,
                        activeSeconds: stat?.activeSeconds ?? 0,
                        messagesSent: count?.count ?? 0,
                      );
                    }).toList()
                    ..sort((a, b) => a.internEmail.compareTo(b.internEmail));

              if (rows.isEmpty) {
                return const EmptyState(
                  icon: Icons.timer_outlined,
                  title: 'No activity on this day',
                  subtitle:
                      'No intern signed in or sent messages on this date.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: rows.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => StaggeredFadeIn(
                  key: ValueKey(rows[index].internId),
                  delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
                  child: _InternShiftRow(
                    internEmail: rows[index].internEmail,
                    activeSeconds: rows[index].activeSeconds,
                    messagesSent: rows[index].messagesSent,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InternShiftRow extends StatelessWidget {
  const _InternShiftRow({
    required this.internEmail,
    required this.activeSeconds,
    required this.messagesSent,
  });

  final String internEmail;
  final int activeSeconds;
  final int messagesSent;

  @override
  Widget build(BuildContext context) {
    final hours = activeSeconds ~/ 3600;
    final minutes = (activeSeconds % 3600) ~/ 60;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            internEmail,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Row(
            children: [
              Expanded(
                child: _ShiftMetric(
                  label: '${hours}h ${minutes}m of ${_shiftTargetHours}h shift',
                  fraction: activeSeconds / (_shiftTargetHours * 3600),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ShiftMetric(
                  label: '$messagesSent of $_shiftMessageTarget sent',
                  fraction: messagesSent / _shiftMessageTarget,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShiftMetric extends StatelessWidget {
  const _ShiftMetric({required this.label, required this.fraction});

  final String label;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AdminColors.border(context),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

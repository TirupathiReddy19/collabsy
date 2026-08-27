import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/admin_crash_analytics_providers.dart';
import '../theme/admin_colors.dart';
import 'admin_analytics_charts.dart';

/// Brand-recognizable platform colors — deliberately distinct from
/// [AppColors.creator]/[AppColors.brand] (which mean the Creator/Brand
/// *user role* everywhere else in this admin portal) so a reader never
/// confuses "Android crash" with "Creator role" at a glance.
const _androidColor = Color(0xFF34A853);
const _iosColor = Color(0xFF636366);

/// The Firebase project this dashboard belongs to — used only to deep-link
/// a crash issue straight into the Crashlytics console.
const _firebaseProjectId = 'collabsy-mobile-applicaation';
const _androidBundleId = 'online.collabsy.app';
const _iosBundleId = 'online.collabsy.app';

String _crashlyticsIssueUrl(String platform, String issueId) {
  final appId = platform == 'ANDROID'
      ? 'android:$_androidBundleId'
      : 'ios:$_iosBundleId';
  return 'https://console.firebase.google.com/project/$_firebaseProjectId'
      '/crashlytics/app/$appId/issues/$issueId';
}

String _fmtRelative(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

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

String _fmtDay(DateTime day) => '${_months[day.month - 1]} ${day.day}';

/// Fatal-crash dashboard pulled live from Crashlytics' BigQuery export (see
/// `getCrashAnalytics` Cloud Function) — the one section on this screen
/// that isn't backed by Firestore, since Crashlytics data doesn't live
/// there. Shows a clear setup message instead of an empty chart until the
/// BigQuery link is turned on and has actually exported at least one crash.
class AdminCrashAnalyticsSection extends StatelessWidget {
  const AdminCrashAnalyticsSection({
    super.key,
    required this.data,
    required this.days,
  });

  final AsyncValue<CrashAnalytics> data;

  /// The day-range currently selected above this section — used to size
  /// the trend chart's x-axis and to label the KPI row.
  final int days;

  @override
  Widget build(BuildContext context) {
    return data.when(
      data: (crash) => _Loaded(crash: crash, days: days),
      loading: () => const AdminCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, _) => AdminCard(
        child: Text(
          "Couldn't load crash analytics: $error",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.crash, required this.days});

  final CrashAnalytics crash;
  final int days;

  @override
  Widget build(BuildContext context) {
    if (crash.trend.isEmpty && crash.topIssues.isEmpty) {
      return AdminCard(
        child: Text(
          'No crash data yet. This needs the Crashlytics → BigQuery '
          'export turned on in Firebase Console (Project Settings → '
          'Integrations), and it can take a few hours after that for the '
          'first export to run.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
      );
    }

    final byPlatform = <String, int>{};
    for (final entry in crash.trend) {
      byPlatform[entry.platform] =
          (byPlatform[entry.platform] ?? 0) + entry.count;
    }
    final totalCrashes = byPlatform.values.fold(0, (a, b) => a + b);
    final totalInstalls = crash.topIssues.fold(
      0,
      (sum, issue) => sum + issue.affectedInstalls,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KpiRow(
          crash: crash,
          days: days,
          totalCrashes: totalCrashes,
          totalInstalls: totalInstalls,
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 780;
            final trendChart = AdminCard(
              child: _CrashTrendChart(trend: crash.trend, days: days),
            );
            final platformSplit = AdminCard(
              child: _PlatformSplit(
                byPlatform: byPlatform,
                total: totalCrashes,
              ),
            );
            if (!wide) {
              return Column(
                children: [
                  trendChart,
                  const SizedBox(height: 20),
                  platformSplit,
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: trendChart),
                  const SizedBox(width: 20),
                  Expanded(child: platformSplit),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('Top crash issues', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        if (crash.topIssues.isEmpty)
          AdminCard(
            child: Text(
              'No fatal crashes in this window.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
          )
        else
          AdminCard(
            child: Column(
              children: [
                for (final (index, issue) in crash.topIssues.indexed) ...[
                  if (index > 0) const Divider(height: 24),
                  _IssueRow(issue: issue),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Top-of-page stat strip — the four numbers an admin actually scans for
/// first, before drilling into the chart or the issue list below.
class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.crash,
    required this.days,
    required this.totalCrashes,
    required this.totalInstalls,
  });

  final CrashAnalytics crash;
  final int days;
  final int totalCrashes;
  final int totalInstalls;

  /// Splits the window in half and compares late-half vs early-half crash
  /// volume — a cheap trend signal that needs no extra query, since
  /// [crash].trend already covers the whole window.
  (double percent, bool isUp)? _trendDelta() {
    if (crash.trend.isEmpty) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final midpoint = today.subtract(Duration(days: days ~/ 2));
    var early = 0;
    var late = 0;
    for (final entry in crash.trend) {
      final day = DateTime(entry.day.year, entry.day.month, entry.day.day);
      if (day.isBefore(midpoint)) {
        early += entry.count;
      } else {
        late += entry.count;
      }
    }
    if (early == 0 && late == 0) return null;
    if (early == 0) return (100, true);
    final percent = ((late - early) / early) * 100;
    return (percent.abs(), percent >= 0);
  }

  @override
  Widget build(BuildContext context) {
    final delta = _trendDelta();
    final uniqueIssues = crash.topIssues.length;
    final platformCount = {for (final e in crash.trend) e.platform}.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final cardWidth =
            (constraints.maxWidth - (perRow - 1) * 16) / perRow;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'Fatal crashes · ${days}d',
                value: '$totalCrashes',
                icon: Icons.bug_report_outlined,
                color: AppColors.error,
                trailing: delta == null
                    ? null
                    : _TrendPill(percent: delta.$1, isUp: delta.$2),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'Installs impacted',
                value: '$totalInstalls',
                icon: Icons.phone_iphone,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'Unique issues',
                value: uniqueIssues >= 20 ? '20+' : '$uniqueIssues',
                icon: Icons.report_gmailerrorred_outlined,
                color: AppColors.purple,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'Platforms affected',
                value: '$platformCount',
                icon: Icons.devices_other,
                color: AppColors.info,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AdminColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.percent, required this.isUp});

  final double percent;
  final bool isUp;

  @override
  Widget build(BuildContext context) {
    // More crashes than before is bad (red, up-arrow); fewer is good
    // (green, down-arrow) — the opposite polarity of most "up is good"
    // dashboard pills, worth being explicit about via color + icon rather
    // than trusting the direction alone.
    final color = isUp ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${percent.round()}%',
            style: AppTextStyles.micro.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily stacked bars (Android + iOS) over the selected window — the trend
/// data was already being fetched for the KPI totals but previously thrown
/// away after summing; this is what actually shows the shape of it.
class _CrashTrendChart extends StatelessWidget {
  const _CrashTrendChart({required this.trend, required this.days});

  final List<DailyCrashCount> trend;
  final int days;

  static const _barAreaHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayList = List.generate(
      days,
      (i) => today.subtract(Duration(days: days - 1 - i)),
    );

    final androidCounts = {for (final d in dayList) d: 0};
    final iosCounts = {for (final d in dayList) d: 0};
    for (final entry in trend) {
      final day = DateTime(entry.day.year, entry.day.month, entry.day.day);
      if (!androidCounts.containsKey(day)) continue;
      if (entry.platform == 'ANDROID') {
        androidCounts[day] = androidCounts[day]! + entry.count;
      } else {
        iosCounts[day] = iosCounts[day]! + entry.count;
      }
    }

    final maxCount = dayList
        .map((d) => androidCounts[d]! + iosCounts[d]!)
        .fold(0, (a, b) => a > b ? a : b);
    final scale = maxCount == 0 ? 0.0 : _barAreaHeight / maxCount;
    // Thin out x-axis labels once there are too many bars to caption
    // every single one legibly.
    final labelStride = (dayList.length / 10).ceil().clamp(1, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fatal crashes over time', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: const [
            LegendDot(color: _androidColor, label: 'Android'),
            SizedBox(width: 16),
            LegendDot(color: _iosColor, label: 'iOS'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: _barAreaHeight + 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, day) in dayList.indexed)
                Expanded(
                  child: Tooltip(
                    message:
                        '${_fmtDay(day)}\n'
                        '${androidCounts[day]} Android · '
                        '${iosCounts[day]} iOS',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (iosCounts[day]! > 0)
                            AdminAnimatedBar(
                              height: iosCounts[day]! * scale,
                              color: _iosColor,
                              delay: Duration(
                                milliseconds: (index * 25).clamp(0, 600),
                              ),
                            ),
                          if (androidCounts[day]! > 0)
                            AdminAnimatedBar(
                              height: androidCounts[day]! * scale,
                              color: _androidColor,
                              borderRadius: iosCounts[day] == 0
                                  ? const BorderRadius.vertical(
                                      top: Radius.circular(3),
                                    )
                                  : null,
                              delay: Duration(
                                milliseconds: (index * 25).clamp(0, 600),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            index % labelStride == 0 ? '${day.day}' : '',
                            style: AppTextStyles.micro.copyWith(
                              color: AdminColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Platform breakdown as proportional bars, each annotated with its share
/// of the total — a plain count list previously left the reader to do
/// that division themselves.
class _PlatformSplit extends StatelessWidget {
  const _PlatformSplit({required this.byPlatform, required this.total});

  final Map<String, int> byPlatform;
  final int total;

  @override
  Widget build(BuildContext context) {
    final entries = byPlatform.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('By platform', style: AppTextStyles.titleSmall),
        const SizedBox(height: 16),
        for (final (index, entry) in entries.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      entry.key == 'ANDROID' ? Icons.android : Icons.apple,
                      size: 16,
                      color: entry.key == 'ANDROID'
                          ? _androidColor
                          : _iosColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key == 'ANDROID' ? 'Android' : 'iOS',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${entry.value} '
                      '(${total == 0 ? 0 : (entry.value / total * 100).round()}%)',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fraction = total == 0 ? 0.0 : entry.value / total;
                    return Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AdminColors.background(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AdminAnimatedBar(
                          width: constraints.maxWidth * fraction,
                          height: 8,
                          color: entry.key == 'ANDROID'
                              ? _androidColor
                              : _iosColor,
                          borderRadius: BorderRadius.circular(4),
                          delay: Duration(
                            milliseconds: (index * 80).clamp(0, 400),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Crash severity, inferred from how far it's actually spread — a fatal hit
/// on one device reads very differently to an admin than the same crash
/// landing on a dozen.
enum _Severity { critical, warning, minor }

_Severity _severityOf(TopCrashIssue issue) {
  if (issue.affectedInstalls >= 5 || issue.eventCount >= 20) {
    return _Severity.critical;
  }
  if (issue.affectedInstalls >= 2 || issue.eventCount >= 5) {
    return _Severity.warning;
  }
  return _Severity.minor;
}

(Color, String) _severityStyle(BuildContext context, _Severity severity) =>
    switch (severity) {
      _Severity.critical => (AppColors.error, 'Critical'),
      _Severity.warning => (AppColors.warning, 'Warning'),
      _Severity.minor => (AdminColors.textHint(context), 'Minor'),
    };

class _IssueRow extends StatelessWidget {
  const _IssueRow({required this.issue});

  final TopCrashIssue issue;

  @override
  Widget build(BuildContext context) {
    final severity = _severityOf(issue);
    final (severityColor, severityLabel) = _severityStyle(context, severity);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          issue.platform == 'ANDROID' ? Icons.android : Icons.apple,
          size: 20,
          color: issue.platform == 'ANDROID' ? _androidColor : _iosColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      severityLabel,
                      style: AppTextStyles.micro.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      issue.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${issue.eventCount} event${issue.eventCount == 1 ? '' : 's'} '
                '· ${issue.affectedInstalls} install'
                '${issue.affectedInstalls == 1 ? '' : 's'} affected '
                '· last seen ${_fmtRelative(issue.lastSeenAt)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Open in Crashlytics',
          icon: const Icon(Icons.open_in_new, size: 18),
          onPressed: () => launchUrl(
            Uri.parse(_crashlyticsIssueUrl(issue.platform, issue.issueId)),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}

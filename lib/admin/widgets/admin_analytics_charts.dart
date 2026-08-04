import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/user_role.dart';
import '../providers/admin_analytics_providers.dart';
import '../theme/admin_colors.dart';

/// A single chart bar that grows in from zero the first time it mounts
/// (and re-animates smoothly whenever its size changes afterward) instead
/// of snapping straight to its final size — used by every bar in this
/// file, vertical or horizontal. [delay] staggers bars across a chart so
/// they grow in left-to-right/top-to-bottom rather than all at once.
class _AnimatedBar extends StatefulWidget {
  const _AnimatedBar({
    this.width,
    this.height,
    required this.color,
    this.borderRadius,
    this.delay = Duration.zero,
  });

  final double? width;
  final double? height;
  final Color color;
  final BorderRadius? borderRadius;
  final Duration delay;

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar> {
  double? _width;
  double? _height;

  @override
  void initState() {
    super.initState();
    _width = widget.width == null ? null : 0;
    _height = widget.height == null ? null : 0;
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      setState(() {
        _width = widget.width;
        _height = widget.height;
      });
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      setState(() {
        _width = widget.width;
        _height = widget.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: widget.borderRadius,
      ),
    );
  }
}

/// Shared chart widgets used by both the Platform Analytics screen (full
/// 14-day detail) and the Dashboard's condensed overview — extracted so
/// neither has to duplicate the bar-drawing logic.
class AdminCard extends StatelessWidget {
  const AdminCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: child,
    );
  }
}

/// Stacked daily bars — Creator signups (orange) below, Brand signups
/// (blue) stacked on top — over the trailing 14 days.
class DailySignupsChart extends StatelessWidget {
  const DailySignupsChart({super.key, required this.signups, this.days});

  final List<UserSignup> signups;

  /// Overrides the trailing-14-days default with a caller-picked range
  /// (e.g. the Dashboard's date-range filter).
  final List<DateTime>? days;

  static const _barAreaHeight = 120.0;

  static const _months = [
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

  static String _fmtDay(DateTime day) => '${_months[day.month - 1]} ${day.day}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days =
        this.days ??
        List.generate(14, (i) => today.subtract(Duration(days: 13 - i)));

    final creatorCounts = {for (final day in days) day: 0};
    final brandCounts = {for (final day in days) day: 0};

    for (final signup in signups) {
      final createdAt = signup.createdAt;
      if (createdAt == null) continue;
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      if (!creatorCounts.containsKey(day)) continue;
      if (signup.role == UserRole.creator) {
        creatorCounts[day] = creatorCounts[day]! + 1;
      } else if (signup.role == UserRole.brand) {
        brandCounts[day] = brandCounts[day]! + 1;
      }
    }

    final maxCount = days
        .map((d) => creatorCounts[d]! + brandCounts[d]!)
        .fold(0, (a, b) => a > b ? a : b);
    final scale = maxCount == 0 ? 0.0 : _barAreaHeight / maxCount;

    return Column(
      children: [
        Row(
          children: const [
            LegendDot(color: AppColors.creator, label: 'Creators'),
            SizedBox(width: 16),
            LegendDot(color: AppColors.brand, label: 'Brands'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: _barAreaHeight + 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, day) in days.indexed)
                Expanded(
                  child: Tooltip(
                    message:
                        '${_fmtDay(day)}\n'
                        '${creatorCounts[day]} creator'
                        '${creatorCounts[day] == 1 ? '' : 's'} · '
                        '${brandCounts[day]} brand'
                        '${brandCounts[day] == 1 ? '' : 's'}',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (brandCounts[day]! > 0)
                            _AnimatedBar(
                              height: brandCounts[day]! * scale,
                              color: AppColors.brand,
                              delay: Duration(
                                milliseconds: (index * 25).clamp(0, 600),
                              ),
                            ),
                          if (creatorCounts[day]! > 0)
                            _AnimatedBar(
                              height: creatorCounts[day]! * scale,
                              color: AppColors.creator,
                              borderRadius: brandCounts[day] == 0
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
                            '${day.day}',
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

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AdminColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

/// Stacked daily bars — same layout as [DailySignupsChart] — split into
/// Creator/Brand active counts by joining each `dailyActivity` entry's
/// [DailyActivityEntry.userId] against [roleByUserId] (built from the
/// signups data, since `dailyActivity` docs don't carry role themselves).
class DailyActiveUsersChart extends StatelessWidget {
  const DailyActiveUsersChart({
    super.key,
    required this.activity,
    required this.roleByUserId,
    this.days,
  });

  final List<DailyActivityEntry> activity;
  final Map<String, UserRole?> roleByUserId;

  /// Overrides the trailing-14-days default with a caller-picked range
  /// (e.g. the Dashboard's date-range filter).
  final List<DateTime>? days;

  static const _barAreaHeight = 120.0;

  static String _dateKey(DateTime day) =>
      '${day.year}'
      '${day.month.toString().padLeft(2, '0')}'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days =
        this.days ??
        List.generate(14, (i) => today.subtract(Duration(days: 13 - i)));

    final dayByKey = {for (final day in days) _dateKey(day): day};
    final creatorCounts = {for (final day in days) day: 0};
    final brandCounts = {for (final day in days) day: 0};
    final otherCounts = {for (final day in days) day: 0};
    for (final entry in activity) {
      final day = dayByKey[entry.date];
      if (day == null) continue;
      switch (roleByUserId[entry.userId]) {
        case UserRole.creator:
          creatorCounts[day] = creatorCounts[day]! + 1;
        case UserRole.brand:
          brandCounts[day] = brandCounts[day]! + 1;
        case UserRole.admin:
        case null:
          // Admin sign-ins or a user whose role hasn't loaded/resolved yet
          // (e.g. the signups stream is still catching up) — still real
          // activity, just not attributable to either portal.
          otherCounts[day] = otherCounts[day]! + 1;
      }
    }

    final maxCount = days
        .map((d) => creatorCounts[d]! + brandCounts[d]! + otherCounts[d]!)
        .fold(0, (a, b) => a > b ? a : b);
    final scale = maxCount == 0 ? 0.0 : _barAreaHeight / maxCount;

    return Column(
      children: [
        Row(
          children: [
            const LegendDot(color: AppColors.creator, label: 'Creators'),
            const SizedBox(width: 16),
            const LegendDot(color: AppColors.brand, label: 'Brands'),
            const SizedBox(width: 16),
            LegendDot(color: AdminColors.textHint(context), label: 'Other'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: _barAreaHeight + 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, day) in days.indexed)
                Expanded(
                  child: Tooltip(
                    message:
                        '${day.day}/${day.month}\n'
                        '${creatorCounts[day]} creator'
                        '${creatorCounts[day] == 1 ? '' : 's'} · '
                        '${brandCounts[day]} brand'
                        '${brandCounts[day] == 1 ? '' : 's'}'
                        '${otherCounts[day]! > 0 ? ' · ${otherCounts[day]} other' : ''}',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (otherCounts[day]! > 0)
                            _AnimatedBar(
                              height: otherCounts[day]! * scale,
                              color: AdminColors.textHint(context),
                              delay: Duration(
                                milliseconds: (index * 25).clamp(0, 600),
                              ),
                            ),
                          if (brandCounts[day]! > 0)
                            _AnimatedBar(
                              height: brandCounts[day]! * scale,
                              color: AppColors.brand,
                              delay: Duration(
                                milliseconds: (index * 25).clamp(0, 600),
                              ),
                            ),
                          if (creatorCounts[day]! > 0)
                            _AnimatedBar(
                              height: creatorCounts[day]! * scale,
                              color: AppColors.creator,
                              borderRadius:
                                  brandCounts[day] == 0 && otherCounts[day] == 0
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
                            '${day.day}',
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

/// Horizontal proportional bars — one row per label, width scaled against
/// the largest count in the set.
class AdminBarList extends StatelessWidget {
  const AdminBarList({super.key, required this.counts, required this.color});

  final Map<String, int> counts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.values.fold(0, (a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final (index, entry) in counts.entries.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    entry.key,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fraction = maxCount == 0
                          ? 0.0
                          : entry.value / maxCount;
                      return Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AdminColors.background(context),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          _AnimatedBar(
                            width: constraints.maxWidth * fraction,
                            height: 8,
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            delay: Duration(
                              milliseconds: (index * 60).clamp(0, 500),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${entry.value}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

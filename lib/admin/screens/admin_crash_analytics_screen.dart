import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/admin_crash_analytics_providers.dart';
import '../widgets/admin_crash_analytics_section.dart';
import '../widgets/admin_top_bar.dart';

const _rangeOptions = [7, 14, 30];

class AdminCrashAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminCrashAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminCrashAnalyticsScreen> createState() =>
      _AdminCrashAnalyticsScreenState();
}

class _AdminCrashAnalyticsScreenState
    extends ConsumerState<AdminCrashAnalyticsScreen> {
  int _days = 14;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(crashAnalyticsProvider(_days));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'Crash Analytics',
          subtitle: 'Fatal crashes reported to Crashlytics, from BigQuery',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (final option in _rangeOptions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$option days'),
                          selected: _days == option,
                          selectedColor: AppColors.error.withValues(
                            alpha: 0.15,
                          ),
                          onSelected: (_) => setState(() => _days = option),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AdminCrashAnalyticsSection(data: data, days: _days),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

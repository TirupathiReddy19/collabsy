import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

/// Placeholder for sidebar sections not built yet — keeps the whole
/// sidebar navigable today while each screen gets filled in.
class AdminComingSoonScreen extends StatelessWidget {
  const AdminComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTopBar(title: title),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction_outlined,
                  size: 40,
                  color: AdminColors.textHint(context),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Not built yet',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AdminColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

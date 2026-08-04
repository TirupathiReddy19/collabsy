import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../theme/admin_colors.dart';

/// Matches the Figma `AdminTopBar` — title/subtitle on the left, an
/// optional action slot on the right. Shared across every admin screen.
class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AdminColors.textSecondary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            // `IntrinsicWidth` forces each action to size itself against a
            // bounded dry-layout pass — without it, a Material button (e.g.
            // OutlinedButton) placed here as a bare Row child can be handed
            // an infinite-width constraint and crash the whole screen's
            // layout instead of just failing to render its own icon/label.
            for (final action in actions!) ...[
              IntrinsicWidth(child: action),
              const SizedBox(width: 8),
            ],
          ],
        ],
      ),
    );
  }
}

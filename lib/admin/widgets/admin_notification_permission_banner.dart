import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../services/browser_notification_service.dart';

/// Prompts staff to enable desktop notifications — shown above the routed
/// content in `AdminShell` until the browser's permission is granted,
/// denied, or the banner is dismissed for this tab.
///
/// Deliberately not auto-requested on page load: Chrome only shows the
/// real permission popup in response to a genuine user gesture, so
/// [BrowserNotificationService.requestPermission] is only ever called
/// from this banner's own button.
class AdminNotificationPermissionBanner extends StatefulWidget {
  const AdminNotificationPermissionBanner({super.key});

  @override
  State<AdminNotificationPermissionBanner> createState() =>
      _AdminNotificationPermissionBannerState();
}

class _AdminNotificationPermissionBannerState
    extends State<AdminNotificationPermissionBanner> {
  bool _dismissed = false;
  bool _requesting = false;

  Future<void> _enable() async {
    setState(() => _requesting = true);
    await BrowserNotificationService.requestPermission();
    if (!mounted) return;
    setState(() => _requesting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || !BrowserNotificationService.needsPermissionPrompt) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.infoLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enable desktop notifications to hear about new reviews, '
              'campaigns, and reports as they come in.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
            ),
          ),
          TextButton(
            onPressed: _requesting ? null : _enable,
            child: Text(_requesting ? 'Requesting…' : 'Enable'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.info,
            tooltip: 'Dismiss',
            onPressed: () => setState(() => _dismissed = true),
          ),
        ],
      ),
    );
  }
}

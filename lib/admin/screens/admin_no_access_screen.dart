import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_text_styles.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../models/staff_login_event.dart';
import '../providers/admin_auth_providers.dart';
import '../providers/admin_staff_login_event_providers.dart';
import '../theme/admin_colors.dart';

/// Shown to a staff account that's been created but has no features toggled
/// on yet — a defensive fallback so a misconfigured account sees a clear
/// message instead of the router bouncing it in a loop.
class AdminNoAccessScreen extends ConsumerWidget {
  const AdminNoAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAccount = ref.watch(currentStaffAccountProvider).value;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: AdminColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No features assigned yet',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your account doesn\'t have access to any section yet. '
              'Contact your admin to get features assigned.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AdminColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                if (staffAccount != null) {
                  await ref
                      .read(adminStaffLoginEventRepositoryProvider)
                      .logEvent(
                        uid: staffAccount.uid,
                        email: staffAccount.email,
                        roleName: staffAccount.roleName,
                        type: StaffLoginEventType.logout,
                      );
                }
                await ref.read(authRepositoryProvider).signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

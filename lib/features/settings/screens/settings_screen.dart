import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/models/user_role.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _legalBaseUrl = 'https://collabsy-mobile-applicaation.web.app';

  Future<void> _togglePush(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    await ref
        .read(authControllerProvider.notifier)
        .setPushNotificationsEnabled(value);
    if (!context.mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't update this setting.");
    }
  }

  Future<void> _confirmAndDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final role = ref.read(currentProfileProvider).value?.role;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteAccountDialog(role: role),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!context.mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't delete your account.");
    }
    // On success there's nothing else to do here — the router's own
    // auth-state-change redirect takes it from here, same as sign-out.
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            StaggeredFadeIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push notifications'),
                    subtitle: const Text(
                      'New applications, accept/reject updates, messages, and '
                      'deliverable reviews.',
                    ),
                    value: profile?.pushNotificationsEnabled ?? true,
                    onChanged: isLoading
                        ? null
                        : (value) => _togglePush(context, ref, value),
                  ),
                ],
              ),
            ),
            if (profile?.role == UserRole.creator)
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('Account', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Connected accounts'),
                      subtitle: const Text(
                        'Link your Instagram to your profile.',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => context.push(AppRoutes.connectedAccounts),
                    ),
                  ],
                ),
              ),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Privacy & Safety', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Blocked accounts'),
                    subtitle: const Text('Manage the users you have blocked.'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => context.push(AppRoutes.blockedAccounts),
                  ),
                ],
              ),
            ),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 270),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Legal', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => _openUrl('$_legalBaseUrl/privacy/'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Terms of Service'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => _openUrl('$_legalBaseUrl/terms/'),
                  ),
                ],
              ),
            ),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Danger Zone',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Delete account',
                      style: TextStyle(color: AppColors.error),
                    ),
                    subtitle: const Text(
                      'Permanently deletes your account and profile. This '
                      "can't be undone.",
                    ),
                    trailing: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onTap: isLoading
                        ? null
                        : () => _confirmAndDeleteAccount(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Requires typing "DELETE" before the confirm button enables — friction
/// against an accidental tap, without a full password-reauth flow (the
/// `deleteAccount` Cloud Function uses the Admin SDK, so there's no
/// `requires-recent-login` constraint to satisfy).
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.role});

  final UserRole? role;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warning = widget.role == UserRole.brand
        ? 'This permanently deletes your account, profile, and all of your '
              "campaigns (and the applications filed against them). Messages "
              "you're part of stay visible to the other side, but you won't "
              "be able to sign back in."
        : 'This permanently deletes your account and profile. Applications '
              "and messages you're part of stay visible to the other side, "
              "but you won't be able to sign back in.";
    return AlertDialog(
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$warning\n\nType DELETE to confirm.'),
          const SizedBox(height: 16),
          AppTextField(
            controller: _controller,
            hintText: 'DELETE',
            onChanged: (value) =>
                setState(() => _matches = value.trim() == 'DELETE'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

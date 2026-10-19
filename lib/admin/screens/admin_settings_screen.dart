import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/update_gate/app_version_check.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../models/audit_log.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../providers/admin_settings_providers.dart';
import '../theme/admin_colors.dart';
import '../widgets/admin_top_bar.dart';

/// The two Firestore config docs `redirectLead`/`redirectBrandLead` (Cloud
/// Functions) already depend on — message template, coming-soon toggle,
/// store URLs — had no admin UI at all before this screen; they were only
/// ever editable by hand in the Firestore console.
class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(
          title: 'System Settings',
          subtitle:
              'Outreach tool configuration — DM copy, store links, and '
              'the coming-soon page.',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StaggeredFadeIn(child: _EmailVerificationCard()),
                    StaggeredFadeIn(
                      child: _ForceUpdateGateCard(
                        configAsync: ref.watch(appVersionConfigProvider),
                        onSaved: () => ref.invalidate(appVersionConfigProvider),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    StaggeredFadeIn(
                      child: _ConfigCard(
                        title: 'Creator Outreach',
                        docId: outreachLinksConfigDocId,
                        targetName: 'Creator Outreach',
                        configAsync: ref.watch(outreachLinksConfigProvider),
                        onSaved: () =>
                            ref.invalidate(outreachLinksConfigProvider),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 60),
                      child: _ConfigCard(
                        title: 'Brand Outreach',
                        docId: brandOutreachLinksConfigDocId,
                        targetName: 'Brand Outreach',
                        configAsync: ref.watch(
                          brandOutreachLinksConfigProvider,
                        ),
                        onSaved: () =>
                            ref.invalidate(brandOutreachLinksConfigProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfigCard extends ConsumerStatefulWidget {
  const _ConfigCard({
    required this.title,
    required this.docId,
    required this.targetName,
    required this.configAsync,
    required this.onSaved,
  });

  final String title;
  final String docId;
  final String targetName;
  final AsyncValue<Map<String, dynamic>?> configAsync;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ConfigCard> createState() => _ConfigCardState();
}

class _ConfigCardState extends ConsumerState<_ConfigCard> {
  final _messageController = TextEditingController();
  final _androidController = TextEditingController();
  final _iosController = TextEditingController();
  bool _comingSoonEnabled = true;
  bool _seeded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _maybeSeed();
  }

  @override
  void didUpdateWidget(covariant _ConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeSeed();
  }

  // Only seeds once, the first time the config finishes loading — after
  // that, the controllers hold whatever the admin is actively editing, so
  // a later rebuild (e.g. from the sibling card saving) must never
  // overwrite in-progress edits.
  void _maybeSeed() {
    if (_seeded || widget.configAsync.isLoading) return;
    _seeded = true;
    final data = widget.configAsync.value;
    _messageController.text = data?['messageTemplate'] as String? ?? '';
    _androidController.text = data?['androidStoreUrl'] as String? ?? '';
    _iosController.text = data?['iosStoreUrl'] as String? ?? '';
    _comingSoonEnabled = data?['comingSoonEnabled'] as bool? ?? true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _androidController.dispose();
    _iosController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(adminSettingsRepositoryProvider)
          .updateConfig(widget.docId, {
            'messageTemplate': _messageController.text.trim(),
            'comingSoonEnabled': _comingSoonEnabled,
            'androidStoreUrl': _androidController.text.trim(),
            'iosStoreUrl': _iosController.text.trim(),
          });
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
            action: AuditLogAction.outreachSettingsUpdated,
            targetId: widget.docId,
            targetName: widget.targetName,
          );
      widget.onSaved();
      if (!mounted) return;
      AppSnackbar.showSuccess(context, '${widget.title} settings saved.');
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't save settings.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
          Text(widget.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (!_seeded && widget.configAsync.isLoading)
            const _CardSkeleton()
          else if (widget.configAsync.hasError)
            Text(
              "Couldn't load settings.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            )
          else ...[
            AppTextField(
              controller: _messageController,
              label: 'Message template',
              hintText: "Hi! I think you'd be a great fit... {{link}}",
              maxLines: 5,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 4),
            Text(
              '{{link}} is replaced with the real tracking link.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Switch(
                  value: _comingSoonEnabled,
                  onChanged: _isSaving
                      ? null
                      : (value) => setState(() => _comingSoonEnabled = value),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Show coming-soon page',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'What visitors see before the app is live on the '
                        'app stores. Turn off once it is.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AdminColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _androidController,
              label: 'Android Play Store URL',
              hintText: 'https://play.google.com/store/apps/details?id=...',
              keyboardType: TextInputType.url,
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            AppTextField(
              controller: _iosController,
              label: 'iOS App Store URL',
              hintText: 'https://apps.apple.com/app/...',
              keyboardType: TextInputType.url,
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: 'Save changes',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ],
      ),
    );
  }
}

/// E1: `isAdmin()` (firestore.rules) will eventually also require
/// `email_verified` on the admin's token — blocked until the real
/// `admin@collabsy.online` account actually verifies its email, which
/// nothing in this app could previously trigger (a password reset email
/// is a different Firebase mechanism and doesn't set `emailVerified`).
/// Shown only to whoever is actually signed in with an unverified email;
/// hidden entirely once verified.
class _EmailVerificationCard extends ConsumerStatefulWidget {
  const _EmailVerificationCard();

  @override
  ConsumerState<_EmailVerificationCard> createState() =>
      _EmailVerificationCardState();
}

class _EmailVerificationCardState
    extends ConsumerState<_EmailVerificationCard> {
  bool _isSending = false;

  Future<void> _send(User user) async {
    setState(() => _isSending = true);
    try {
      await user.sendEmailVerification();
      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        'Verification email sent to ${user.email}.',
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        "Couldn't send the verification email. Try again shortly.",
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    if (user == null || user.emailVerified) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: AdminColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email not verified', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "${user.email} hasn't been verified yet. Click below, then "
              'open the email and follow the link.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AdminColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: 'Send verification email',
              isLoading: _isSending,
              onPressed: _isSending ? null : () => _send(user),
            ),
          ],
        ),
      ),
    );
  }
}

/// The force-update gate (`config/appVersion`, read by `checkAppVersion` —
/// see `app_version_check.dart`). Blank by default: the gate fails open
/// with no doc, so builds below any minimum set here get blocked, and
/// everyone else is unaffected. Raising a minimum is a one-way door for
/// whoever's still on an older build — they're hard-blocked the next time
/// they open the app — so this is deliberately a manual, reviewed save
/// rather than something set automatically at release time.
class _ForceUpdateGateCard extends ConsumerStatefulWidget {
  const _ForceUpdateGateCard({required this.configAsync, required this.onSaved});

  final AsyncValue<Map<String, dynamic>?> configAsync;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ForceUpdateGateCard> createState() =>
      _ForceUpdateGateCardState();
}

class _ForceUpdateGateCardState extends ConsumerState<_ForceUpdateGateCard> {
  final _androidMinController = TextEditingController();
  final _iosMinController = TextEditingController();
  final _androidUrlController = TextEditingController();
  final _iosUrlController = TextEditingController();
  final _messageController = TextEditingController();
  bool _seeded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _maybeSeed();
  }

  @override
  void didUpdateWidget(covariant _ForceUpdateGateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeSeed();
  }

  void _maybeSeed() {
    if (_seeded || widget.configAsync.isLoading) return;
    _seeded = true;
    final data = widget.configAsync.value;
    _androidMinController.text = (data?['minBuildAndroid'] as int?)
            ?.toString() ??
        '';
    _iosMinController.text = (data?['minBuildIos'] as int?)?.toString() ?? '';
    _androidUrlController.text = data?['androidStoreUrl'] as String? ??
        'https://play.google.com/store/apps/details?id=online.collabsy.app';
    _iosUrlController.text = data?['iosStoreUrl'] as String? ??
        'https://apps.apple.com/in/app/collabsy/id6808197823';
    _messageController.text = data?['message'] as String? ??
        defaultUpdateMessage;
  }

  @override
  void dispose() {
    _androidMinController.dispose();
    _iosMinController.dispose();
    _androidUrlController.dispose();
    _iosUrlController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final androidMin = int.tryParse(_androidMinController.text.trim());
    final iosMin = int.tryParse(_iosMinController.text.trim());
    if (androidMin == null || iosMin == null) {
      AppSnackbar.showError(
        context,
        'Minimum build numbers must be whole numbers.',
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(adminSettingsRepositoryProvider).updateConfig(
        appVersionConfigDocId,
        {
          'minBuildAndroid': androidMin,
          'minBuildIos': iosMin,
          'androidStoreUrl': _androidUrlController.text.trim(),
          'iosStoreUrl': _iosUrlController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );
      await ref.read(adminAuditLogRepositoryProvider).log(
            actorEmail: ref.read(currentAdminEmailProvider) ?? adminEmail,
            action: AuditLogAction.appVersionGateUpdated,
            targetId: appVersionConfigDocId,
            targetName: 'Android $androidMin / iOS $iosMin',
          );
      widget.onSaved();
      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        'Force-update gate saved: Android min build $androidMin, '
        'iOS min build $iosMin.',
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't save the force-update gate.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Force-update gate', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Anyone below the minimum build gets hard-blocked the next '
            'time they open the app — no gradual rollout. Only save this '
            "once you're confident the new build is stable.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AdminColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!_seeded && widget.configAsync.isLoading)
            const _CardSkeleton()
          else if (widget.configAsync.hasError)
            Text(
              "Couldn't load the current gate settings.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _androidMinController,
                    label: 'Android minimum build',
                    hintText: '31',
                    keyboardType: TextInputType.number,
                    enabled: !_isSaving,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: AppTextField(
                    controller: _iosMinController,
                    label: 'iOS minimum build',
                    hintText: '31',
                    keyboardType: TextInputType.number,
                    enabled: !_isSaving,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            AppTextField(
              controller: _androidUrlController,
              label: 'Android Play Store URL',
              keyboardType: TextInputType.url,
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            AppTextField(
              controller: _iosUrlController,
              label: 'iOS App Store URL',
              keyboardType: TextInputType.url,
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            AppTextField(
              controller: _messageController,
              label: 'Message shown on the update screen',
              maxLines: 3,
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: 'Save force-update gate',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(height: 96),
        SizedBox(height: AppSpacing.md),
        Skeleton(height: 48),
        SizedBox(height: AppSpacing.md),
        Skeleton(height: 56),
        SizedBox(height: AppSpacing.sm + 4),
        Skeleton(height: 56),
        SizedBox(height: AppSpacing.md),
        Skeleton(height: 56),
      ],
    );
  }
}

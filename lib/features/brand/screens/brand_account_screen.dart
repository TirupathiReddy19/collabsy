import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/avatar_picker.dart';
import '../../../core/utils/campaign_categories.dart';
import '../../../core/utils/company_size_options.dart';
import '../../../core/utils/india_regions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/linkedin_icon.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../shared/widgets/multi_select_picker_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/shared/change_email_sheet.dart';
import '../../auth/shared/change_phone_sheet.dart';
import '../models/brand_profile.dart';
import '../providers/brand_profile_providers.dart';

class BrandAccountScreen extends ConsumerStatefulWidget {
  const BrandAccountScreen({super.key});

  @override
  ConsumerState<BrandAccountScreen> createState() => _BrandAccountScreenState();
}

class _BrandAccountScreenState extends ConsumerState<BrandAccountScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _changeAvatar() async {
    final file = await pickAvatarImage(context);
    if (file == null || !mounted) return;
    setState(() => _isUploadingAvatar = true);
    await ref.read(authControllerProvider.notifier).uploadAvatar(file);
    if (!mounted) return;
    setState(() => _isUploadingAvatar = false);
    if (ref.read(authControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't update your photo. Please try again.",
      );
    }
  }

  /// [save] performs the actual write and returns whether it succeeded —
  /// callers check their own controller's error state, since different
  /// fields save through different controllers (brand profile vs. the
  /// shared auth controller for the person's own name).
  Future<void> _saveField(
    Future<bool> Function() save, {
    required String successMessage,
  }) async {
    final success = await save();
    if (!mounted) return;
    if (!success) {
      AppSnackbar.showError(context, "Couldn't save. Please try again.");
      return;
    }
    ref.invalidate(ownBrandProfileProvider);
    AppSnackbar.showSuccess(context, successMessage);
  }

  Future<bool> _updateBrandProfile({
    String? companyName,
    String? designation,
    String? bio,
    List<String>? categories,
    String? website,
    String? companySize,
    String? linkedinUrl,
    String? stateName,
    String? city,
  }) async {
    await ref
        .read(brandProfileControllerProvider.notifier)
        .updateProfile(
          companyName: companyName,
          designation: designation,
          bio: bio,
          categories: categories,
          website: website,
          companySize: companySize,
          linkedinUrl: linkedinUrl,
          stateName: stateName,
          city: city,
        );
    return !ref.read(brandProfileControllerProvider).hasError;
  }

  Future<void> _editTextField({
    required String title,
    required String initialValue,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    required Future<bool> Function(String value) onSave,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditTextFieldSheet(
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
    if (result == null) return;
    await _saveField(() => onSave(result), successMessage: 'Updated.');
  }

  Future<void> _editCategories(BrandProfile? profile) async {
    final result = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) => MultiSelectPickerScreen(
          title: 'Industries',
          options: campaignCategories,
          initialSelected: Set.of(profile?.categories ?? const []),
        ),
      ),
    );
    if (result == null) return;
    await _saveField(
      () => _updateBrandProfile(categories: result.toList()),
      successMessage: 'Industries updated.',
    );
  }

  Future<void> _editCompanySize(BrandProfile? profile) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: companySizeOptions
              .map(
                (size) => ListTile(
                  title: Text(size),
                  trailing: profile?.companySize == size
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(size),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (result == null) return;
    await _saveField(
      () => _updateBrandProfile(companySize: result),
      successMessage: 'Company size updated.',
    );
  }

  Future<void> _editLocation(BrandProfile? profile) async {
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditLocationSheet(
        initialState: profile?.state,
        initialCity: profile?.city ?? '',
      ),
    );
    if (result == null) return;
    await _saveField(
      () => _updateBrandProfile(stateName: result.$1, city: result.$2),
      successMessage: 'Location updated.',
    );
  }

  Future<void> _launch(String? url, {String scheme = ''}) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(scheme.isEmpty ? url : '$scheme$url');
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    final brandProfile = ref.watch(ownBrandProfileProvider).value;
    final isLoading = ref.watch(brandProfileControllerProvider).isLoading;

    final missingDetails =
        (brandProfile?.companyName ?? '').isEmpty ||
        brandProfile?.categories.isEmpty != false ||
        (brandProfile?.website ?? '').isEmpty ||
        (brandProfile?.linkedinUrl ?? '').isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.screenHorizontal),
          children: [
            StaggeredFadeIn(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    padding: const EdgeInsets.all(AppSpacing.card),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileAvatar(
                              avatarUrl: profile?.avatarUrl,
                              fallbackIcon: Icons.storefront,
                              onEdit: _changeAvatar,
                              isUploading: _isUploadingAvatar,
                            ),
                            const Spacer(),
                            _QuickAction(
                              icon: Icons.call_outlined,
                              onTap: profile?.phone == null
                                  ? null
                                  : () =>
                                        _launch(profile!.phone, scheme: 'tel:'),
                            ),
                            const SizedBox(width: 8),
                            _QuickAction(
                              icon: Icons.email_outlined,
                              onTap: profile?.email == null
                                  ? null
                                  : () => _launch(
                                      profile!.email,
                                      scheme: 'mailto:',
                                    ),
                            ),
                            const SizedBox(width: 8),
                            _QuickAction(
                              iconWidget: const LinkedInIcon(
                                size: 18,
                                fontSize: 12,
                                monochrome: true,
                              ),
                              onTap: (brandProfile?.linkedinUrl ?? '').isEmpty
                                  ? null
                                  : () => _launch(brandProfile!.linkedinUrl),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile?.displayName ?? 'Brand',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (brandProfile?.designation ?? '').isEmpty
                              ? 'Add current job title'
                              : brandProfile!.designation!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              color: AppColors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (brandProfile?.companyName ?? '').isEmpty
                                  ? 'Add your company name'
                                  : brandProfile!.companyName!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (missingDetails)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.card),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Company details missing',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _editTextField(
                              title: 'Company name',
                              initialValue: brandProfile?.companyName ?? '',
                              hintText: 'Your company name',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Enter your company name'
                                  : null,
                              onSave: (value) =>
                                  _updateBrandProfile(companyName: value),
                            ),
                            child: const Text('Add now'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                children: [
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 90),
                    child: Card(
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.badge_outlined,
                            title: 'Personal details',
                            subtitle: [
                              profile?.displayName,
                              profile?.phone,
                            ].whereType<String>().join(' • '),
                            isLoading: isLoading,
                            onTap: () => _editTextField(
                              title: 'Full name',
                              initialValue: profile?.displayName ?? '',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Enter your name'
                                  : null,
                              onSave: (value) async {
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .updateDisplayName(value);
                                return !ref
                                    .read(authControllerProvider)
                                    .hasError;
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.call_outlined,
                            title: 'Phone number',
                            subtitle: profile?.phone,
                            placeholder: 'Add your phone number',
                            isLoading: isLoading,
                            onTap: () async {
                              final changed = await ChangePhoneSheet.show(
                                context,
                              );
                              if (changed == true) {
                                ref.invalidate(currentProfileProvider);
                              }
                            },
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            iconWidget: const LinkedInIcon(
                              size: 40,
                              fontSize: 18,
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Color(0xFF0A66C2),
                            ),
                            title: 'My LinkedIn',
                            subtitle: brandProfile?.linkedinUrl,
                            placeholder: 'Add your LinkedIn profile',
                            isLoading: isLoading,
                            onTap: () => _editTextField(
                              title: 'LinkedIn profile',
                              initialValue: brandProfile?.linkedinUrl ?? '',
                              hintText: 'https://linkedin.com/in/you',
                              keyboardType: TextInputType.url,
                              validator: Validators.linkedinUrl,
                              onSave: (value) =>
                                  _updateBrandProfile(linkedinUrl: value),
                            ),
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.business_outlined,
                            title: 'Current organization',
                            subtitle: brandProfile?.companyName,
                            placeholder: 'Add your company name',
                            isLoading: isLoading,
                            onTap: () => _editTextField(
                              title: 'Company name',
                              initialValue: brandProfile?.companyName ?? '',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Enter your company name'
                                  : null,
                              onSave: (value) =>
                                  _updateBrandProfile(companyName: value),
                            ),
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.mail_outline,
                            title: 'Work email',
                            subtitle: profile?.email,
                            isLoading: isLoading,
                            onTap: () async {
                              final changed = await ChangeEmailSheet.show(
                                context,
                              );
                              if (changed == true) {
                                ref.invalidate(currentProfileProvider);
                              }
                            },
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.work_outline,
                            title: 'Current job title',
                            subtitle: brandProfile?.designation,
                            placeholder: 'Add your current title/position',
                            isLoading: isLoading,
                            onTap: () => _editTextField(
                              title: 'Your designation',
                              initialValue: brandProfile?.designation ?? '',
                              hintText: 'e.g. Marketing Manager',
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Enter your designation'
                                  : null,
                              onSave: (value) =>
                                  _updateBrandProfile(designation: value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 180),
                    child: Card(
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.public,
                            title: 'Website',
                            subtitle: brandProfile?.website,
                            placeholder: 'Add your company website',
                            isLoading: isLoading,
                            onTap: () => _editTextField(
                              title: 'Company website',
                              initialValue: brandProfile?.website ?? '',
                              hintText: 'https://yourbrand.com',
                              keyboardType: TextInputType.url,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Enter your website'
                                  : null,
                              onSave: (value) =>
                                  _updateBrandProfile(website: value),
                            ),
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.groups_outlined,
                            title: 'Company size',
                            subtitle: brandProfile?.companySize,
                            placeholder: 'Select company size',
                            isLoading: isLoading,
                            onTap: () => _editCompanySize(brandProfile),
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            subtitle: [brandProfile?.city, brandProfile?.state]
                                .whereType<String>()
                                .where((s) => s.isNotEmpty)
                                .join(', '),
                            placeholder: 'Add your city and state',
                            isLoading: isLoading,
                            onTap: () => _editLocation(brandProfile),
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.category_outlined,
                            title: 'Industries',
                            subtitle: brandProfile?.categories.join(', '),
                            placeholder: 'Select your industries',
                            isLoading: isLoading,
                            onTap: () => _editCategories(brandProfile),
                          ),
                          const Divider(height: 1),
                          _DetailRow(
                            icon: Icons.notes_outlined,
                            title: 'Bio',
                            subtitle: brandProfile?.bio,
                            placeholder: 'Tell creators about your brand',
                            isLoading: isLoading,
                            onTap: () => _editTextField(
                              title: 'Bio',
                              initialValue: brandProfile?.bio ?? '',
                              hintText: 'Tell creators a bit about your brand',
                              maxLines: 4,
                              onSave: (value) =>
                                  _updateBrandProfile(bio: value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 270),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text('Settings'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(AppRoutes.settings),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Sign out',
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          borderColor: AppColors.border,
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .signOut(),
                        ),
                      ],
                    ),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({this.icon, this.iconWidget, required this.onTap})
    : assert(icon != null || iconWidget != null);

  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: iconWidget ?? Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.placeholder,
    this.onTap,
    this.isLoading = false,
  }) : assert(icon != null || iconWidget != null);

  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;
  final String? placeholder;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final hasValue = subtitle != null && subtitle!.isNotEmpty;
    return ListTile(
      leading:
          iconWidget ??
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
      title: Text(title, style: AppTextStyles.titleSmall),
      subtitle: Text(
        hasValue ? subtitle! : (placeholder ?? '—'),
        style: AppTextStyles.bodySmall.copyWith(
          color: hasValue ? AppColors.textSecondary : AppColors.textHint,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: isLoading ? null : onTap,
    );
  }
}

/// Owns its [TextEditingController] for the sheet's own widget lifetime
/// instead of the calling method's synchronous flow — the bottom sheet's
/// closing animation can still be rendering this field after
/// `showModalBottomSheet` returns, so disposing the controller from the
/// caller right away crashes with "used after being disposed".
class _EditTextFieldSheet extends StatefulWidget {
  const _EditTextFieldSheet({
    required this.title,
    required this.initialValue,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final String title;
  final String initialValue;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  State<_EditTextFieldSheet> createState() => _EditTextFieldSheetState();
}

class _EditTextFieldSheetState extends State<_EditTextFieldSheet> {
  late final _controller = TextEditingController(text: widget.initialValue);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            AppTextField(
              controller: _controller,
              hintText: widget.hintText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              autofocus: true,
              validator: widget.validator,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Save',
              onPressed: () {
                if (_formKey.currentState?.validate() ?? true) {
                  Navigator.of(context).pop(_controller.text.trim());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Same rationale as [_EditTextFieldSheet] — the city controller must be
/// owned and disposed by the sheet's own lifecycle, not the caller's.
class _EditLocationSheet extends StatefulWidget {
  const _EditLocationSheet({this.initialState, required this.initialCity});

  final String? initialState;
  final String initialCity;

  @override
  State<_EditLocationSheet> createState() => _EditLocationSheetState();
}

class _EditLocationSheetState extends State<_EditLocationSheet> {
  late String? _selectedState = widget.initialState;
  late final _cityController = TextEditingController(text: widget.initialCity);

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            items: indianStates
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => setState(() => _selectedState = value),
            decoration: const InputDecoration(labelText: 'State'),
          ),
          const SizedBox(height: 12),
          AppTextField(controller: _cityController, label: 'City'),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Save',
            onPressed: () {
              if (_selectedState == null ||
                  _cityController.text.trim().isEmpty) {
                return;
              }
              Navigator.of(
                context,
              ).pop((_selectedState!, _cityController.text.trim()));
            },
          ),
        ],
      ),
    );
  }
}

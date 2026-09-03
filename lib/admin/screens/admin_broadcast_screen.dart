import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/campaign_categories.dart';
import '../../core/utils/company_size_options.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../features/announcements/providers/announcements_providers.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/brand/models/brand_profile.dart';
import '../../features/brand/providers/brand_profile_providers.dart';
import '../../features/creator/models/creator_profile.dart';
import '../../features/creator/providers/creator_profile_providers.dart';
import '../../features/settings/models/instagram_account.dart';
import '../../features/settings/providers/instagram_providers.dart';
import '../../shared/models/announcement.dart';
import '../../shared/utils/announcement_audience.dart';
import '../models/audit_log.dart';
import '../providers/admin_audit_log_providers.dart';
import '../providers/admin_auth_providers.dart';
import '../providers/admin_broadcast_providers.dart';
import '../providers/admin_dashboard_providers.dart';
import '../utils/admin_dialog.dart';
import '../utils/creator_display_name.dart';
import '../widgets/admin_top_bar.dart';
import '../theme/admin_colors.dart';

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

String _fmtDate(DateTime? time) {
  if (time == null) return '—';
  return '${_months[time.month - 1]} ${time.day}, ${time.year}';
}

String _creatorLabel(CreatorProfile profile, InstagramAccount? instagram) {
  final name = profile.displayName;
  if (name != null && name.isNotEmpty) return name;
  final username = instagram?.username;
  if (username != null && username.isNotEmpty) return '@$username';
  return profile.id;
}

String _brandLabel(BrandProfile profile) {
  final name = profile.companyName;
  return name != null && name.isNotEmpty ? name : profile.id;
}

/// How many creators actually match a set of targeting criteria — the
/// Broadcast screen's live "~N creators match" preview while composing,
/// and each past broadcast's "seen by N of **M**" denominator once
/// `targetType != 'all'`.
int _matchingCreatorCount({
  required List<CreatorProfile> creators,
  required Map<String, InstagramAccount?> instagramByUid,
  required String targetType,
  List<String>? targetCategories,
  int? targetMinFollowers,
  int? targetMaxFollowers,
  String? targetCreatorId,
}) {
  if (targetType == 'all') return creators.length;
  return creators
      .where(
        (c) => matchesAudience(
          targetType: targetType,
          targetCategories: targetCategories,
          targetMinFollowers: targetMinFollowers,
          targetMaxFollowers: targetMaxFollowers,
          targetCreatorId: targetCreatorId,
          creatorId: c.id,
          creatorCategories: c.categories,
          creatorFollowers: instagramByUid[c.id]?.followersCount,
        ),
      )
      .length;
}

/// How many brands actually match a set of targeting criteria — the Brand
/// counterpart of [_matchingCreatorCount].
int _matchingBrandCount({
  required List<BrandProfile> brands,
  required String targetType,
  List<String>? targetCategories,
  String? targetCompanySize,
  String? targetBrandId,
}) {
  if (targetType == 'all') return brands.length;
  return brands
      .where(
        (b) => matchesBrandAudience(
          targetType: targetType,
          targetCategories: targetCategories,
          targetCompanySize: targetCompanySize,
          targetBrandId: targetBrandId,
          brandId: b.id,
          brandCategories: b.categories,
          brandCompanySize: b.companySize,
        ),
      )
      .length;
}

String _audienceDescription(Announcement announcement) {
  if (announcement.audience == 'brand') {
    switch (announcement.targetType) {
      case 'brand':
        return 'To: ${announcement.targetBrandName ?? 'one brand'}';
      case 'category':
        final categories = announcement.targetCategories ?? const [];
        return categories.isEmpty
            ? 'Industry'
            : 'Industry: ${categories.join(', ')}';
      case 'companySize':
        final size = announcement.targetCompanySize;
        return size == null ? 'Company size' : 'Company size: $size';
      default:
        return 'All Brands';
    }
  }
  switch (announcement.targetType) {
    case 'creator':
      return 'To: ${announcement.targetCreatorName ?? 'one creator'}';
    case 'category':
      final categories = announcement.targetCategories ?? const [];
      return categories.isEmpty ? 'Niche' : 'Niche: ${categories.join(', ')}';
    case 'followerRange':
      final min = announcement.targetMinFollowers;
      final max = announcement.targetMaxFollowers;
      if (min != null && max != null) return 'Followers: $min–$max';
      if (min != null) return 'Followers: $min+';
      if (max != null) return 'Followers: up to $max';
      return 'Follower range';
    default:
      return 'All Creators';
  }
}

/// Sends a one-way broadcast to every Creator or every Brand — shows up in
/// their Messages tab as a "Collabsy Team" thread (see
/// [lib/features/announcements]), not the Notifications feed. A single
/// shared `announcements` doc, not one per recipient.
class AdminBroadcastScreen extends ConsumerStatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  ConsumerState<AdminBroadcastScreen> createState() =>
      _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends ConsumerState<AdminBroadcastScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _creatorSearchController = TextEditingController();
  final _brandSearchController = TextEditingController();
  final _minFollowersController = TextEditingController();
  final _maxFollowersController = TextEditingController();
  bool _isSending = false;

  // 'creator' | 'brand' — which side this broadcast goes to. Changing it
  // resets `_targetType` to 'all', since 'creator'/'followerRange' only
  // make sense for Creators and 'brand'/'companySize' only for Brands.
  String _audienceRole = 'creator';
  String _targetType = 'all';
  CreatorProfile? _selectedCreator;
  BrandProfile? _selectedBrand;
  // Reused for both Creator "content category" and Brand "industry" — both
  // draw from the same `campaignCategories` list (see
  // `brand_details_screen.dart`'s industry step).
  final Set<String> _selectedCategories = {};
  String? _selectedCompanySize;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _creatorSearchController.dispose();
    _brandSearchController.dispose();
    _minFollowersController.dispose();
    _maxFollowersController.dispose();
    super.dispose();
  }

  void _setAudienceRole(String role) {
    setState(() {
      _audienceRole = role;
      _targetType = 'all';
      _selectedCreator = null;
      _selectedBrand = null;
      _selectedCategories.clear();
      _selectedCompanySize = null;
      _creatorSearchController.clear();
      _brandSearchController.clear();
      _minFollowersController.clear();
      _maxFollowersController.clear();
    });
  }

  String _composeAudienceDescription(InstagramAccount? selectedInstagram) {
    if (_audienceRole == 'brand') {
      switch (_targetType) {
        case 'brand':
          return 'To: ${_selectedBrand != null ? _brandLabel(_selectedBrand!) : 'one brand'}';
        case 'category':
          return _selectedCategories.isEmpty
              ? 'Industry'
              : 'Industry: ${_selectedCategories.join(', ')}';
        case 'companySize':
          return _selectedCompanySize == null
              ? 'Company size'
              : 'Company size: $_selectedCompanySize';
        default:
          return 'All Brands';
      }
    }
    switch (_targetType) {
      case 'creator':
        return 'To: ${_selectedCreator != null ? _creatorLabel(_selectedCreator!, selectedInstagram) : 'one creator'}';
      case 'category':
        return _selectedCategories.isEmpty
            ? 'Niche'
            : 'Niche: ${_selectedCategories.join(', ')}';
      case 'followerRange':
        final min = int.tryParse(_minFollowersController.text.trim());
        final max = int.tryParse(_maxFollowersController.text.trim());
        if (min != null && max != null) return 'Followers: $min–$max';
        if (min != null) return 'Followers: $min+';
        if (max != null) return 'Followers: up to $max';
        return 'Follower range';
      default:
        return 'All Creators';
    }
  }

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;
    if (_audienceRole == 'creator' &&
        _targetType == 'creator' &&
        _selectedCreator == null) {
      return;
    }
    if (_audienceRole == 'brand' &&
        _targetType == 'brand' &&
        _selectedBrand == null) {
      return;
    }

    final minFollowers = int.tryParse(_minFollowersController.text.trim());
    final maxFollowers = int.tryParse(_maxFollowersController.text.trim());

    InstagramAccount? selectedInstagram;
    String audienceLabel;

    if (_audienceRole == 'creator') {
      final creators =
          ref.read(creatorDirectoryProvider).value ?? const <CreatorProfile>[];
      final instagramByUid = {
        for (final account
            in ref.read(allInstagramAccountsProvider).value ??
                const <InstagramAccount>[])
          account.id: account,
      };
      final matchCount = _matchingCreatorCount(
        creators: creators,
        instagramByUid: instagramByUid,
        targetType: _targetType,
        targetCategories: _selectedCategories.toList(),
        targetMinFollowers: minFollowers,
        targetMaxFollowers: maxFollowers,
        targetCreatorId: _selectedCreator?.id,
      );
      selectedInstagram = _selectedCreator == null
          ? null
          : instagramByUid[_selectedCreator!.id];
      audienceLabel = switch (_targetType) {
        'creator' =>
          _selectedCreator == null
              ? 'this creator'
              : _creatorLabel(_selectedCreator!, selectedInstagram),
        _ => '$matchCount creator${matchCount == 1 ? '' : 's'}',
      };
    } else {
      final brands =
          ref.read(brandDirectoryProvider).value ?? const <BrandProfile>[];
      final matchCount = _matchingBrandCount(
        brands: brands,
        targetType: _targetType,
        targetCategories: _selectedCategories.toList(),
        targetCompanySize: _selectedCompanySize,
        targetBrandId: _selectedBrand?.id,
      );
      audienceLabel = switch (_targetType) {
        'brand' =>
          _selectedBrand == null ? 'this brand' : _brandLabel(_selectedBrand!),
        _ => '$matchCount brand${matchCount == 1 ? '' : 's'}',
      };
    }

    final confirmed = await showAdminDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send to $audienceLabel?'),
        content: Text(
          'This message will appear in the Messages tab of $audienceLabel'
          ':\n\n"$title"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSending = true);
    try {
      final actorEmail = ref.read(currentAdminEmailProvider) ?? adminEmail;
      await ref
          .read(announcementsRepositoryProvider)
          .create(
            title: title,
            body: body,
            audience: _audienceRole,
            createdBy: actorEmail,
            targetType: _targetType,
            targetCategories: _targetType == 'category'
                ? _selectedCategories.toList()
                : null,
            targetMinFollowers:
                _audienceRole == 'creator' && _targetType == 'followerRange'
                ? minFollowers
                : null,
            targetMaxFollowers:
                _audienceRole == 'creator' && _targetType == 'followerRange'
                ? maxFollowers
                : null,
            targetCreatorId:
                _audienceRole == 'creator' && _targetType == 'creator'
                ? _selectedCreator?.id
                : null,
            targetCreatorName:
                _audienceRole == 'creator' && _targetType == 'creator'
                ? _creatorLabel(_selectedCreator!, selectedInstagram)
                : null,
            targetBrandId: _audienceRole == 'brand' && _targetType == 'brand'
                ? _selectedBrand?.id
                : null,
            targetBrandName: _audienceRole == 'brand' && _targetType == 'brand'
                ? _brandLabel(_selectedBrand!)
                : null,
            targetCompanySize:
                _audienceRole == 'brand' && _targetType == 'companySize'
                ? _selectedCompanySize
                : null,
          );
      await ref
          .read(adminAuditLogRepositoryProvider)
          .log(
            actorEmail: actorEmail,
            action: AuditLogAction.broadcastSent,
            targetId: _audienceRole == 'creator'
                ? (_targetType == 'creator' ? (_selectedCreator?.id ?? '') : '')
                : (_targetType == 'brand' ? (_selectedBrand?.id ?? '') : ''),
            targetName:
                '$title (${_composeAudienceDescription(selectedInstagram)})',
          );
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Broadcast sent to $audienceLabel.');
      _titleController.clear();
      _bodyController.clear();
      _creatorSearchController.clear();
      _brandSearchController.clear();
      _minFollowersController.clear();
      _maxFollowersController.clear();
      setState(() {
        _targetType = 'all';
        _selectedCreator = null;
        _selectedBrand = null;
        _selectedCategories.clear();
        _selectedCompanySize = null;
      });
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't send the broadcast.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _sendButtonLabel(int matchCount) {
    if (_audienceRole == 'brand') {
      return switch (_targetType) {
        'brand' => 'Send to brand',
        _ when _targetType != 'all' =>
          'Send to $matchCount brand${matchCount == 1 ? '' : 's'}',
        _ => 'Send to all Brands',
      };
    }
    return switch (_targetType) {
      'creator' => 'Send to creator',
      _ when _targetType != 'all' =>
        'Send to $matchCount creator${matchCount == 1 ? '' : 's'}',
      _ => 'Send to all Creators',
    };
  }

  @override
  Widget build(BuildContext context) {
    final creators =
        ref.watch(creatorDirectoryProvider).value ?? const <CreatorProfile>[];
    final instagramByUid = {
      for (final account
          in ref.watch(allInstagramAccountsProvider).value ??
              const <InstagramAccount>[])
        account.id: account,
    };
    final minFollowers = int.tryParse(_minFollowersController.text.trim());
    final maxFollowers = int.tryParse(_maxFollowersController.text.trim());
    final creatorMatchCount = _matchingCreatorCount(
      creators: creators,
      instagramByUid: instagramByUid,
      targetType: _targetType,
      targetCategories: _selectedCategories.toList(),
      targetMinFollowers: minFollowers,
      targetMaxFollowers: maxFollowers,
      targetCreatorId: _selectedCreator?.id,
    );
    final creatorSearchQuery = _creatorSearchController.text
        .trim()
        .toLowerCase();
    final creatorSearchResults = creatorSearchQuery.isEmpty
        ? const <CreatorProfile>[]
        : creators
              .where(
                (c) => _creatorLabel(
                  c,
                  instagramByUid[c.id],
                ).toLowerCase().contains(creatorSearchQuery),
              )
              .take(6)
              .toList();

    final brands =
        ref.watch(brandDirectoryProvider).value ?? const <BrandProfile>[];
    final brandMatchCount = _matchingBrandCount(
      brands: brands,
      targetType: _targetType,
      targetCategories: _selectedCategories.toList(),
      targetCompanySize: _selectedCompanySize,
      targetBrandId: _selectedBrand?.id,
    );
    final brandSearchQuery = _brandSearchController.text.trim().toLowerCase();
    final brandSearchResults = brandSearchQuery.isEmpty
        ? const <BrandProfile>[]
        : brands
              .where(
                (b) => _brandLabel(b).toLowerCase().contains(brandSearchQuery),
              )
              .take(6)
              .toList();

    final matchCount = _audienceRole == 'brand'
        ? brandMatchCount
        : creatorMatchCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminTopBar(title: 'Broadcast Message'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.card),
                    decoration: BoxDecoration(
                      color: AdminColors.surface(context),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AdminColors.border(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send a broadcast message',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Appears as a "Collabsy Team" message in the '
                          'Messages tab of whichever recipients you target '
                          'below, plus a push notification. One-way — '
                          "they can't reply.",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AdminColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _titleController,
                          label: 'Title',
                          hintText: 'e.g. New feature: Verified badges',
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _bodyController,
                          label: 'Message',
                          hintText: 'Write the broadcast message…',
                          maxLines: 5,
                        ),
                        const SizedBox(height: 24),
                        Text('Recipients', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Creators'),
                              selected: _audienceRole == 'creator',
                              onSelected: (_) => _setAudienceRole('creator'),
                            ),
                            ChoiceChip(
                              label: const Text('Brands'),
                              selected: _audienceRole == 'brand',
                              onSelected: (_) => _setAudienceRole('brand'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Audience', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        if (_audienceRole == 'creator') ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('All Creators'),
                                selected: _targetType == 'all',
                                onSelected: (_) =>
                                    setState(() => _targetType = 'all'),
                              ),
                              ChoiceChip(
                                label: const Text('Specific creator'),
                                selected: _targetType == 'creator',
                                onSelected: (_) =>
                                    setState(() => _targetType = 'creator'),
                              ),
                              ChoiceChip(
                                label: const Text('Niche'),
                                selected: _targetType == 'category',
                                onSelected: (_) =>
                                    setState(() => _targetType = 'category'),
                              ),
                              ChoiceChip(
                                label: const Text('Follower range'),
                                selected: _targetType == 'followerRange',
                                onSelected: (_) => setState(
                                  () => _targetType = 'followerRange',
                                ),
                              ),
                            ],
                          ),
                          if (_targetType == 'creator') ...[
                            const SizedBox(height: 12),
                            if (_selectedCreator != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _creatorLabel(
                                        _selectedCreator!,
                                        instagramByUid[_selectedCreator!.id],
                                      ),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => setState(() {
                                        _selectedCreator = null;
                                        _creatorSearchController.clear();
                                      }),
                                      child: const Icon(Icons.close, size: 16),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              AppTextField(
                                controller: _creatorSearchController,
                                label: 'Search creator',
                                hintText: 'Name or Instagram handle…',
                                onChanged: (_) => setState(() {}),
                              ),
                              for (final result in creatorSearchResults)
                                ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _creatorLabel(
                                      result,
                                      instagramByUid[result.id],
                                    ),
                                  ),
                                  onTap: () => setState(() {
                                    _selectedCreator = result;
                                    _creatorSearchController.clear();
                                  }),
                                ),
                            ],
                          ],
                          if (_targetType == 'category') ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: campaignCategories.map((category) {
                                final selected = _selectedCategories.contains(
                                  category,
                                );
                                return FilterChip(
                                  label: Text(category),
                                  selected: selected,
                                  onSelected: (value) => setState(() {
                                    if (value) {
                                      _selectedCategories.add(category);
                                    } else {
                                      _selectedCategories.remove(category);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                          ],
                          if (_targetType == 'followerRange') ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    controller: _minFollowersController,
                                    label: 'Min followers',
                                    hintText: 'e.g. 1000',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppTextField(
                                    controller: _maxFollowersController,
                                    label: 'Max followers',
                                    hintText: 'e.g. 50000',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_targetType != 'all' &&
                              _targetType != 'creator') ...[
                            const SizedBox(height: 8),
                            Text(
                              '~$matchCount creator${matchCount == 1 ? '' : 's'} '
                              'match right now.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AdminColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ] else ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('All Brands'),
                                selected: _targetType == 'all',
                                onSelected: (_) =>
                                    setState(() => _targetType = 'all'),
                              ),
                              ChoiceChip(
                                label: const Text('Specific brand'),
                                selected: _targetType == 'brand',
                                onSelected: (_) =>
                                    setState(() => _targetType = 'brand'),
                              ),
                              ChoiceChip(
                                label: const Text('Industry'),
                                selected: _targetType == 'category',
                                onSelected: (_) =>
                                    setState(() => _targetType = 'category'),
                              ),
                              ChoiceChip(
                                label: const Text('Company size'),
                                selected: _targetType == 'companySize',
                                onSelected: (_) =>
                                    setState(() => _targetType = 'companySize'),
                              ),
                            ],
                          ),
                          if (_targetType == 'brand') ...[
                            const SizedBox(height: 12),
                            if (_selectedBrand != null)
                              _SelectedBrandChip(
                                brand: _selectedBrand!,
                                onRemove: () => setState(() {
                                  _selectedBrand = null;
                                  _brandSearchController.clear();
                                }),
                              )
                            else ...[
                              AppTextField(
                                controller: _brandSearchController,
                                label: 'Search brand',
                                hintText: 'Company name…',
                                onChanged: (_) => setState(() {}),
                              ),
                              for (final result in brandSearchResults)
                                _BrandSearchResultTile(
                                  brand: result,
                                  onTap: () => setState(() {
                                    _selectedBrand = result;
                                    _brandSearchController.clear();
                                  }),
                                ),
                            ],
                          ],
                          if (_targetType == 'category') ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: campaignCategories.map((category) {
                                final selected = _selectedCategories.contains(
                                  category,
                                );
                                return FilterChip(
                                  label: Text(category),
                                  selected: selected,
                                  onSelected: (value) => setState(() {
                                    if (value) {
                                      _selectedCategories.add(category);
                                    } else {
                                      _selectedCategories.remove(category);
                                    }
                                  }),
                                );
                              }).toList(),
                            ),
                          ],
                          if (_targetType == 'companySize') ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: companySizeOptions.map((size) {
                                final selected = _selectedCompanySize == size;
                                return ChoiceChip(
                                  label: Text(size),
                                  selected: selected,
                                  onSelected: (_) => setState(
                                    () => _selectedCompanySize = size,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          if (_targetType != 'all' &&
                              _targetType != 'brand') ...[
                            const SizedBox(height: 8),
                            Text(
                              '~$matchCount brand${matchCount == 1 ? '' : 's'} '
                              'match right now.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AdminColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: _isSending ? null : _send,
                            child: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: LoadingIndicator(
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_sendButtonLabel(matchCount)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Past broadcasts', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  const _PastBroadcastsList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The signed-in contact's name for a brand, e.g. "Jane Doe" — looked up
/// from `users/{uid}.displayName`, which is deliberately NOT the same as
/// `BrandProfile.companyName` (see that model's doc comment). Used so the
/// admin can tell brands with similar/identical company names apart, and
/// see who they're actually about to message, before sending.
class _BrandSearchResultTile extends ConsumerWidget {
  const _BrandSearchResultTile({required this.brand, required this.onTap});

  final BrandProfile brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactName = ref
        .watch(appUserProfileByIdProvider(brand.id))
        .value
        ?.displayName;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(_brandLabel(brand)),
      subtitle: contactName != null && contactName.isNotEmpty
          ? Text(contactName)
          : null,
      onTap: onTap,
    );
  }
}

class _SelectedBrandChip extends ConsumerWidget {
  const _SelectedBrandChip({required this.brand, required this.onRemove});

  final BrandProfile brand;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactName = ref
        .watch(appUserProfileByIdProvider(brand.id))
        .value
        ?.displayName;
    final label = contactName != null && contactName.isNotEmpty
        ? '${_brandLabel(brand)} · $contactName'
        : _brandLabel(brand);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(onTap: onRemove, child: const Icon(Icons.close, size: 16)),
        ],
      ),
    );
  }
}

class _PastBroadcastsList extends ConsumerWidget {
  const _PastBroadcastsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(allAnnouncementsProvider);

    return announcementsAsync.when(
      data: (announcements) {
        if (announcements.isEmpty) {
          return Text(
            'No broadcasts sent yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AdminColors.textSecondary(context),
            ),
          );
        }
        return Column(
          children: announcements
              .map((a) => _BroadcastRow(announcement: a))
              .toList(),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) => Text(
        "Couldn't load past broadcasts.",
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _BroadcastRow extends ConsumerWidget {
  const _BroadcastRow({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentAt = announcement.createdAt;
    final seenAsync = sentAt == null
        ? const AsyncValue<int>.data(0)
        : ref.watch(
            announcementSeenCountProvider(sentAt.millisecondsSinceEpoch),
          );

    final isBrandAudience = announcement.audience == 'brand';
    final recipientNoun = isBrandAudience ? 'brand' : 'creator';

    final int? matchingCount;
    if (announcement.targetType == 'all' || announcement.targetType.isEmpty) {
      matchingCount = null; // falls back to totalRecipientsAsync below
    } else if (announcement.targetType == 'creator' ||
        announcement.targetType == 'brand') {
      matchingCount = 1;
    } else if (isBrandAudience) {
      final brands =
          ref.watch(brandDirectoryProvider).value ?? const <BrandProfile>[];
      matchingCount = _matchingBrandCount(
        brands: brands,
        targetType: announcement.targetType,
        targetCategories: announcement.targetCategories,
        targetCompanySize: announcement.targetCompanySize,
        targetBrandId: announcement.targetBrandId,
      );
    } else {
      final creators =
          ref.watch(creatorDirectoryProvider).value ?? const <CreatorProfile>[];
      final instagramByUid = {
        for (final account
            in ref.watch(allInstagramAccountsProvider).value ??
                const <InstagramAccount>[])
          account.id: account,
      };
      matchingCount = _matchingCreatorCount(
        creators: creators,
        instagramByUid: instagramByUid,
        targetType: announcement.targetType,
        targetCategories: announcement.targetCategories,
        targetMinFollowers: announcement.targetMinFollowers,
        targetMaxFollowers: announcement.targetMaxFollowers,
        targetCreatorId: announcement.targetCreatorId,
      );
    }
    final totalRecipientsAsync = isBrandAudience
        ? ref.watch(totalBrandsCountProvider)
        : ref.watch(totalCreatorsCountProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AdminColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AdminColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  announcement.title,
                  style: AppTextStyles.titleSmall,
                ),
              ),
              Text(
                _fmtDate(sentAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AdminColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _audienceDescription(announcement),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            announcement.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: sentAt == null
                ? null
                : () => _showSeenByDialog(context, sentAt, isBrandAudience),
            child: Text(
              seenAsync.when(
                data: (seen) => matchingCount != null
                    ? 'Seen by $seen of $matchingCount ${recipientNoun}s'
                    : totalRecipientsAsync.when(
                        data: (total) =>
                            'Seen by $seen of $total ${recipientNoun}s',
                        loading: () => 'Seen by $seen ${recipientNoun}s',
                        error: (error, stackTrace) =>
                            'Seen by $seen ${recipientNoun}s',
                      ),
                loading: () => 'Checking who has seen this…',
                error: (error, stackTrace) => "Couldn't load seen count",
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSeenByDialog(
    BuildContext context,
    DateTime sentAt,
    bool isBrandAudience,
  ) {
    showAdminDialog(
      context: context,
      builder: (context) =>
          _SeenByDialog(sentAt: sentAt, isBrandAudience: isBrandAudience),
    );
  }
}

class _SeenByDialog extends ConsumerWidget {
  const _SeenByDialog({required this.sentAt, required this.isBrandAudience});

  final DateTime sentAt;
  final bool isBrandAudience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdsAsync = ref.watch(
      announcementSeenUserIdsProvider(sentAt.millisecondsSinceEpoch),
    );

    return AlertDialog(
      title: const Text('Seen by'),
      content: SizedBox(
        width: 360,
        child: userIdsAsync.when(
          data: (userIds) {
            if (userIds.isEmpty) {
              return const Text('No one has seen this yet.');
            }
            return SizedBox(
              height: 320,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: userIds.length,
                itemBuilder: (context, index) => _SeenByRow(
                  userId: userIds[index],
                  isBrandAudience: isBrandAudience,
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: LoadingIndicator()),
          ),
          error: (error, stackTrace) =>
              const Text("Couldn't load who has seen this."),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SeenByRow extends ConsumerWidget {
  const _SeenByRow({required this.userId, required this.isBrandAudience});

  final String userId;
  final bool isBrandAudience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProfileByIdProvider(userId));
    final instagram = isBrandAudience
        ? null
        : ref.watch(instagramAccountForUserProvider(userId)).value;

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return ListTile(
          dense: true,
          leading: ProfileAvatar(
            avatarUrl: instagram?.profilePictureUrl ?? user.avatarUrl,
            fallbackIcon: isBrandAudience ? Icons.storefront : Icons.person,
            radius: 16,
          ),
          title: Text(
            isBrandAudience
                ? (user.displayName?.isNotEmpty == true
                      ? user.displayName!
                      : 'Unnamed brand')
                : creatorDisplayNameFor(user, instagram),
          ),
        );
      },
      loading: () => const ListTile(
        dense: true,
        leading: SizedBox(
          width: 32,
          height: 32,
          child: LoadingIndicator(size: 16),
        ),
        title: Text('Loading…'),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

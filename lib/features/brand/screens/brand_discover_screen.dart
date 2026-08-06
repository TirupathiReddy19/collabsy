import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/campaign_categories.dart';
import '../../../core/utils/india_regions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../shared/models/verification_status.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../../shared/widgets/multi_select_picker_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../creator/models/creator_profile.dart';
import '../../creator/providers/creator_profile_providers.dart';
import '../../settings/providers/instagram_providers.dart';

class BrandDiscoverScreen extends ConsumerWidget {
  const BrandDiscoverScreen({super.key});

  List<CreatorProfile> _applyFilters(
    List<CreatorProfile> creators, {
    required Set<String> categories,
    required Set<String> states,
    required Set<String> languages,
  }) {
    return creators.where((creator) {
      if (categories.isNotEmpty &&
          !creator.categories.any(categories.contains)) {
        return false;
      }
      if (states.isNotEmpty &&
          (creator.state == null || !states.contains(creator.state))) {
        return false;
      }
      if (languages.isNotEmpty && !creator.languages.any(languages.contains)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Compact chip label — "English" for one, "English +2" for several,
  /// rather than joining the full list (which overflows the chip once more
  /// than a couple of items are selected).
  String _chipLabel(String fallback, Set<String> selected) {
    if (selected.isEmpty) return fallback;
    if (selected.length == 1) return selected.first;
    return '${selected.first} +${selected.length - 1}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(creatorDirectoryProvider);
    final categories = ref.watch(discoverCategoryFilterProvider);
    final states = ref.watch(discoverStateFilterProvider);
    final languages = ref.watch(discoverLanguageFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Creators')),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _FilterChip(
                    label: _chipLabel('Niche', categories),
                    selected: categories.isNotEmpty,
                    onTap: () => _pickMultiple(
                      context,
                      title: 'Niche',
                      options: campaignCategories,
                      current: categories,
                      onPicked: (value) => ref
                          .read(discoverCategoryFilterProvider.notifier)
                          .set(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _chipLabel('State', states),
                    selected: states.isNotEmpty,
                    onTap: () => _pickMultiple(
                      context,
                      title: 'States',
                      options: indianStates,
                      current: states,
                      onPicked: (value) => ref
                          .read(discoverStateFilterProvider.notifier)
                          .set(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _chipLabel('Language', languages),
                    selected: languages.isNotEmpty,
                    onTap: () => _pickMultiple(
                      context,
                      title: 'Languages',
                      options: indianLanguages,
                      current: languages,
                      onPicked: (value) => ref
                          .read(discoverLanguageFilterProvider.notifier)
                          .set(value),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: directory.when(
                data: (creators) {
                  final filtered = _applyFilters(
                    creators,
                    categories: categories,
                    states: states,
                    languages: languages,
                  );
                  if (filtered.isEmpty) {
                    return const Center(
                      child: EmptyState(
                        icon: Icons.person_search_outlined,
                        title: 'No creators match yet',
                        subtitle: 'Try a different filter, or check back soon.',
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final creator = filtered[index];
                      return StaggeredFadeIn(
                        key: ValueKey(creator.id),
                        delay: Duration(
                          milliseconds: (index * 40).clamp(0, 400),
                        ),
                        child: _CreatorCard(
                          creator: creator,
                          onTap: () => context.push(
                            AppRoutes.creatorPublicProfilePath(creator.id),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, stackTrace) => const Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: "Couldn't load creators",
                    subtitle: 'Please try again in a moment.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// All three filters (category/state/language) are multi-select — a full
  /// page rather than a bottom sheet, since tapping shouldn't close it
  /// after each choice.
  Future<void> _pickMultiple(
    BuildContext context, {
    required String title,
    required List<String> options,
    required Set<String> current,
    required ValueChanged<Set<String>> onPicked,
  }) async {
    final result = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (context) => MultiSelectPickerScreen(
          title: title,
          options: options,
          initialSelected: current,
        ),
      ),
    );
    if (result != null) onPicked(result);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      onPressed: onTap,
      backgroundColor: selected ? AppColors.primaryLight : AppColors.surface,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: selected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      avatar: Icon(
        Icons.arrow_drop_down,
        color: selected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
    );
  }
}

class _CreatorCard extends ConsumerWidget {
  const _CreatorCard({required this.creator, required this.onTap});

  final CreatorProfile creator;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `creatorProfiles` is watched unfiltered (see watchDirectory) — this
    // is what keeps a deleted or suspended account from ever showing up
    // here, since `users/{uid}` is the one doc that's actually guaranteed
    // to be gone (or flagged) the moment an account stops being active.
    final profileAsync = ref.watch(appUserProfileByIdProvider(creator.id));
    final owningProfile = profileAsync.value;
    if (profileAsync.isLoading ||
        owningProfile == null ||
        owningProfile.suspended ||
        creator.verificationStatus != VerificationStatus.approved) {
      return const SizedBox.shrink();
    }

    final instagram = ref
        .watch(instagramAccountForUserProvider(creator.id))
        .value;
    final avatarUrl = instagram?.profilePictureUrl;
    final creatorName = creatorDisplayName(creator.displayName, instagram);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Row(
            children: [
              ProfileAvatar(
                avatarUrl: avatarUrl,
                fallbackIcon: Icons.person,
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            creatorName,
                            style: AppTextStyles.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (creator.verificationStatus ==
                            VerificationStatus.approved) ...[
                          const SizedBox(width: 4),
                          const VerifiedBadge(
                            variant: VerifiedBadgeVariant.creator,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (creator.categories.isNotEmpty)
                          creator.categories.join(', '),
                        if (creator.city != null) creator.city!,
                      ].join(' · '),
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

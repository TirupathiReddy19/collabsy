import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/greeting.dart';
import '../../../core/widgets/contact_links_card.dart';
import '../../../core/widgets/count_up_stat.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/profile_completeness_card.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../../../core/utils/campaign_categories.dart';
import '../../../shared/utils/creator_display_name.dart';
import '../../auth/providers/auth_providers.dart';
import '../../campaigns/models/application_status.dart';
import '../../campaigns/models/campaign.dart';
import '../../campaigns/models/campaign_status.dart';
import '../../campaigns/providers/campaigns_providers.dart';
import '../../creator/models/creator_profile.dart';
import '../../creator/providers/creator_profile_providers.dart';
import '../../notifications/widgets/notification_bell.dart';
import '../../settings/providers/instagram_providers.dart';
import '../providers/brand_profile_providers.dart';

final _cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(20),
  side: const BorderSide(color: AppColors.border),
);

/// Brand portal home — the real dashboard (reach trend, active campaigns,
/// top creators) lands once campaigns exist in a later milestone. For now
/// this shows the real signed-in profile plus a live campaign-activity card.
class BrandHomeScreen extends ConsumerWidget {
  const BrandHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final brandProfile = ref.watch(ownBrandProfileProvider).value;

    final profileItems = <(String, bool)>[
      ('Company name', (brandProfile?.companyName ?? '').isNotEmpty),
      ('Designation', (brandProfile?.designation ?? '').isNotEmpty),
      ('Website', (brandProfile?.website ?? '').isNotEmpty),
      ('LinkedIn', (brandProfile?.linkedinUrl ?? '').isNotEmpty),
      ('Categories', brandProfile?.categories.isNotEmpty ?? false),
    ];

    final myCampaignCategories = <String>{
      for (final c in ref.watch(brandCampaignsProvider).value ?? const [])
        ...c.categories,
    };
    final allCreators = ref.watch(creatorDirectoryProvider).value ?? const [];
    final matchingCreators = myCampaignCategories.isEmpty
        ? const <CreatorProfile>[]
        : allCreators
              .where((c) => c.categories.any(myCampaignCategories.contains))
              .toList();
    final recommendedCreators =
        (matchingCreators.isEmpty ? allCreators : matchingCreators)
            .take(5)
            .toList();

    final greetingCard = Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Row(
          children: [
            ProfileAvatar(
              avatarUrl: profile.value?.avatarUrl,
              fallbackIcon: Icons.storefront,
              radius: AppSpacing.avatarMd / 2,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: profile.when(
                data: (value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value?.displayName ?? 'Brand',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      timeBasedGreeting(),
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                loading: () => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 80, height: 12),
                    SizedBox(height: 6),
                    Skeleton(width: 120, height: 16),
                  ],
                ),
                error: (error, stackTrace) => Text(
                  'Could not load your profile',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
            timeBasedGreetingIcon(color: AppColors.primary),
          ],
        ),
      ),
    );

    final profileCard = ProfileCompletenessCard(
      userId: profile.value?.id ?? '',
      items: profileItems,
      cardShape: _cardShape,
      onTap: () => context.go(AppRoutes.brandAccount),
    );

    final discoverCard = recommendedCreators.isEmpty
        ? null
        : Card(
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            shape: _cardShape,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.card,
                AppSpacing.card,
                AppSpacing.card,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Creators to discover',
                        style: AppTextStyles.titleSmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.brandDiscover),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedCreators.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _MiniCreatorCard(creator: recommendedCreators[index]),
                    ),
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Collabsy',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help & Support',
            onPressed: () => context.push(AppRoutes.support),
          ),
          const NotificationBell(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            StaggeredFadeIn(child: greetingCard),
            const SizedBox(height: AppSpacing.xl),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 120),
              child: _CampaignStatsCard(brandId: profile.value?.id),
            ),
            const SizedBox(height: AppSpacing.xl),
            const StaggeredFadeIn(
              delay: Duration(milliseconds: 240),
              child: _CategoriesCard(),
            ),
            const SizedBox(height: AppSpacing.xl),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 360),
              child: profileCard,
            ),
            if (discoverCard != null) ...[
              const SizedBox(height: AppSpacing.xl),
              StaggeredFadeIn(
                delay: const Duration(milliseconds: 480),
                child: discoverCard,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            StaggeredFadeIn(
              delay: const Duration(milliseconds: 600),
              child: const ContactLinksCard(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Home dashboard's campaign-activity card — a "post a campaign" call
/// to action when the brand has none active yet, or a swipeable deck (one
/// page per active campaign) once they do, since a single aggregate number
/// can't show per-campaign applicant/pending counts.
class _CampaignStatsCard extends ConsumerWidget {
  const _CampaignStatsCard({required this.brandId});

  final String? brandId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(brandCampaignsProvider);
    final campaigns = campaignsAsync.value ?? const <Campaign>[];
    final active = campaigns
        .where((c) => c.status == CampaignStatus.active)
        .toList();
    // Distinguishes "hasn't posted anything yet" from "has posted, still
    // waiting on admin review" — telling a brand to "post your first
    // campaign" when they already have one pending is exactly the
    // confusing state this avoids.
    final pendingReview = campaigns
        .where((c) => c.status == CampaignStatus.underReview)
        .toList();

    if (active.isEmpty || brandId == null) {
      final hasPending = pendingReview.isNotEmpty;
      return Card(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: _cardShape,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Column(
            children: [
              Icon(
                hasPending
                    ? Icons.hourglass_top_outlined
                    : Icons.campaign_outlined,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                hasPending
                    ? 'Campaign under review'
                    : 'No active campaigns yet',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                hasPending
                    ? 'Usually takes 15–30 minutes. '
                          "We'll let you know once it's approved and live."
                    : 'Post your first campaign and start getting applications '
                          'from creators.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (!hasPending) ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Post a campaign',
                  icon: Icons.add,
                  onPressed: () => context.push(AppRoutes.createCampaign),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Keyed on the actual set of active campaign ids — without this,
    // Flutter can't tell a genuinely different campaign set from "the same
    // deck, rebuilt" and tries to reuse the old PageController while a new
    // PageView is also attaching to it (crashes with "ScrollController
    // attached to multiple scroll views"). A stable key forces a clean
    // unmount+remount instead, so the old controller always finishes
    // disposing before a new one is created.
    return _ActiveCampaignsDeck(
      key: ValueKey(active.map((c) => c.id).join(',')),
      campaigns: active,
      brandId: brandId!,
    );
  }
}

class _ActiveCampaignsDeck extends StatefulWidget {
  const _ActiveCampaignsDeck({
    super.key,
    required this.campaigns,
    required this.brandId,
  });

  final List<Campaign> campaigns;
  final String brandId;

  @override
  State<_ActiveCampaignsDeck> createState() => _ActiveCampaignsDeckState();
}

class _ActiveCampaignsDeckState extends State<_ActiveCampaignsDeck> {
  late final _pageController = PageController(viewportFraction: 0.94);
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Active campaigns', style: AppTextStyles.titleSmall),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${widget.campaigns.length}',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (widget.campaigns.length > 1) ...[
                  const Spacer(),
                  Icon(
                    Icons.swipe_outlined,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe',
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.campaigns.length > 1)
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.primary,
                    onPressed: _page == 0 ? null : () => _goToPage(_page - 1),
                  ),
                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.campaigns.length,
                      onPageChanged: (index) => setState(() => _page = index),
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            var distance = 0.0;
                            if (_pageController.hasClients &&
                                _pageController.position.haveDimensions) {
                              distance =
                                  ((_pageController.page ?? _page.toDouble()) -
                                          index)
                                      .abs();
                            } else {
                              distance = (_page - index).abs().toDouble();
                            }
                            final scale = (1 - distance * 0.08).clamp(0.9, 1.0);
                            final opacity = (1 - distance * 0.5).clamp(
                              0.4,
                              1.0,
                            );
                            return Transform.scale(
                              scale: scale,
                              child: Opacity(opacity: opacity, child: child),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _CampaignStatPage(
                              campaign: widget.campaigns[index],
                              brandId: widget.brandId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.campaigns.length > 1)
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.primary,
                    onPressed: _page == widget.campaigns.length - 1
                        ? null
                        : () => _goToPage(_page + 1),
                  ),
              ],
            ),
            if (widget.campaigns.length > 1) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.campaigns.length, (index) {
                  final isActive = index == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CampaignStatPage extends ConsumerWidget {
  const _CampaignStatPage({required this.campaign, required this.brandId});

  final Campaign campaign;
  final String brandId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications =
        ref.watch(campaignApplicationsProvider(campaign.id, brandId)).value ??
        const [];
    final pending = applications
        .where((a) => a.status == ApplicationStatus.pending)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          campaign.title,
          style: AppTextStyles.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CountUpStat(label: 'Total applicants', value: applications.length),
            CountUpStat(
              label: 'Pending review',
              value: pending,
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}

const _categoriesPerPage = 8;

IconData _categoryIcon(String category) => switch (category) {
  'Fashion' => Icons.checkroom_outlined,
  'Beauty' => Icons.face_retouching_natural_outlined,
  'Food' => Icons.restaurant_outlined,
  'Travel' => Icons.travel_explore_outlined,
  'Tech' => Icons.memory_outlined,
  'Gaming' => Icons.sports_esports_outlined,
  'Fitness' => Icons.fitness_center_outlined,
  'Lifestyle' => Icons.self_improvement_outlined,
  'Home & Decor' => Icons.chair_outlined,
  'Parenting' => Icons.child_care_outlined,
  'Finance' => Icons.currency_rupee,
  'Education' => Icons.school_outlined,
  'Entertainment' => Icons.movie_outlined,
  'Automotive' => Icons.directions_car_outlined,
  'Health & Wellness' => Icons.health_and_safety_outlined,
  _ => Icons.category_outlined,
};

/// A paginated grid of creator categories a brand can tap to jump straight
/// into Discover pre-filtered — mirrors the reference "Creator categories"
/// section (icon-in-box tiles, two rows per page, swipeable with dots).
class _CategoriesCard extends StatefulWidget {
  const _CategoriesCard();

  @override
  State<_CategoriesCard> createState() => _CategoriesCardState();
}

class _CategoriesCardState extends State<_CategoriesCard> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <List<String>>[];
    for (var i = 0; i < campaignCategories.length; i += _categoriesPerPage) {
      pages.add(
        campaignCategories.sublist(
          i,
          (i + _categoriesPerPage).clamp(0, campaignCategories.length),
        ),
      );
    }

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Creator categories', style: AppTextStyles.titleSmall),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppRoutes.brandDiscover),
                  child: const Text('View all'),
                ),
              ],
            ),
            SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, pageIndex) {
                  final items = pages[pageIndex];
                  final firstRow = items.take(4).toList();
                  final secondRow = items.skip(4).take(4).toList();
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: firstRow
                            .map(
                              (category) => _CategoryTile(category: category),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: secondRow
                            .map(
                              (category) => _CategoryTile(category: category),
                            )
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (pages.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (index) {
                  final isActive = index == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        ref.read(discoverCategoryFilterProvider.notifier).set({category});
        context.go(AppRoutes.brandDiscover);
      },
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(_categoryIcon(category), color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              category,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.micro,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCreatorCard extends ConsumerWidget {
  const _MiniCreatorCard({required this.creator});

  final CreatorProfile creator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instagram = ref
        .watch(instagramAccountForUserProvider(creator.id))
        .value;
    final avatarUrl = instagram?.profilePictureUrl;
    final creatorName = creatorDisplayName(creator.displayName, instagram);

    return SizedBox(
      width: 150,
      child: Card(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              context.push(AppRoutes.creatorPublicProfilePath(creator.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatar(
                  avatarUrl: avatarUrl,
                  fallbackIcon: Icons.person,
                  radius: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  creatorName,
                  style: AppTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (creator.categories.isNotEmpty)
                  Text(
                    creator.categories.take(2).join(', '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

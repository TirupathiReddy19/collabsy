import 'package:flutter/material.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/campaign_request_form.dart';
import '../widgets/hero_backdrop.dart';
import '../widgets/hover_lift.dart';
import '../widgets/scroll_reveal_fade.dart';
import '../widgets/step_icon.dart';
import '../widgets/waitlist_cta_button.dart';
import '../widgets/website_bullet_item.dart';
import '../widgets/website_section.dart';
import '../widgets/website_section_heading.dart';

const _services = [
  (
    Icons.campaign_outlined,
    'Influencer Marketing Campaigns',
    'Connect with the right influencers to drive sales and conversions '
        'for your D2C brand.',
  ),
  (
    Icons.movie_creation_outlined,
    'UGC Content Creation',
    'High-quality user-generated content that resonates with your target '
        'audience and boosts ROI.',
  ),
  (
    Icons.handshake_outlined,
    'Brand Collaborations',
    'Strategic partnerships that align with your brand values and drive '
        'measurable results.',
  ),
  (
    Icons.map_outlined,
    'Campaign Strategy & Execution',
    'End-to-end campaign management focused on performance and '
        'conversions.',
  ),
  (
    Icons.insights_outlined,
    'Performance Tracking & Optimization',
    'Real-time analytics and continuous optimization to maximize ROI.',
  ),
];

const _managedSteps = [
  (
    '01',
    'Understand your brand goals',
    'We analyze your objectives, target market, and sales goals to '
        'shape a tailored strategy.',
  ),
  (
    '02',
    'Build a custom campaign plan',
    'A data-driven plan focused on conversions and measurable results, '
        'with budget allocated for maximum ROI.',
  ),
  (
    '03',
    'Execute with targeted creators',
    'We select micro-influencers (10K–50K) and run a content-first, '
        'performance-driven campaign.',
  ),
  (
    '04',
    'Track results and optimize',
    'Conversion tracking, ROI reporting, and ongoing optimization as the '
        'campaign runs.',
  ),
];

class WebsiteBrandsScreen extends StatelessWidget {
  WebsiteBrandsScreen({super.key});

  final _formSectionKey = GlobalKey();

  void _scrollToForm(BuildContext context) {
    final target = _formSectionKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

    return Column(
      children: [
        ColoredBox(
          color: AppColors.primaryLight,
          child: Stack(
            children: [
              const HeroBackdrop(),
              WebsiteSection(
          child: Column(
            children: [
              Text(
                'Get sales, not just views',
                textAlign: TextAlign.center,
                style: isWide
                    ? AppTextStyles.displayLarge.copyWith(fontSize: 44)
                    : AppTextStyles.displayLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'Whether you want hands-on control or a team to run it '
                  'end to end, Collabsy has a path for your D2C brand.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
              ),
            ],
          ),
        ),
        WebsiteSection(
          child: Column(
            children: [
              ScrollRevealFade(
                child: const WebsiteSectionHeading(
                  title: 'Two ways to work with Collabsy',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  SizedBox(
                    width: 460,
                    child: ScrollRevealFade(
                      child: const HoverLift(
                        borderRadius: AppRadius.xxl,
                        child: _SelfServeCard(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 460,
                    child: ScrollRevealFade(
                      delay: const Duration(milliseconds: 80),
                      child: HoverLift(
                        borderRadius: AppRadius.xxl,
                        child: _ManagedCard(
                          onGetPlan: () => _scrollToForm(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        WebsiteSection(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              ScrollRevealFade(
                child: const WebsiteSectionHeading(
                  eyebrow: 'Managed campaigns',
                  title: 'What our team handles for you',
                  subtitle:
                      'Comprehensive influencer marketing solutions designed '
                      'to drive sales and ROI for D2C brands.',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  for (final (index, (icon, title, body)) in _services.indexed)
                    ScrollRevealFade(
                      delay: Duration(milliseconds: index * 60),
                      child: SizedBox(
                        width: 320,
                        child: HoverLift(
                          borderRadius: AppRadius.xl,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StepIcon(icon: icon),
                                const SizedBox(height: 12),
                                Text(title, style: AppTextStyles.titleLarge),
                                const SizedBox(height: 6),
                                Text(
                                  body,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        WebsiteSection(
          child: Column(
            children: [
              ScrollRevealFade(
                child: const WebsiteSectionHeading(
                  eyebrow: 'How it works',
                  title: 'Our proven 4-step process',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  for (final (index, (number, title, body)) in _managedSteps.indexed)
                    ScrollRevealFade(
                      delay: Duration(milliseconds: index * 80),
                      child: SizedBox(
                      width: 240,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            number,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.brand.withValues(alpha: 0.35),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(title, style: AppTextStyles.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            body,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        WebsiteSection(
          key: _formSectionKey,
          backgroundColor: AppColors.primaryLight,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: const CampaignRequestForm(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelfServeCard extends StatelessWidget {
  const _SelfServeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'SELF-SERVE',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.brand,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Use the platform yourself', style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.md),
          const WebsiteBulletItem(
            'Post campaigns and set your own budget and requirements',
          ),
          const WebsiteBulletItem(
            'Browse verified micro-influencers (10K–50K followers)',
          ),
          const WebsiteBulletItem(
            'Review applications and message creators directly',
          ),
          const WebsiteBulletItem('Full control, no management fee'),
          const SizedBox(height: AppSpacing.md),
          const WaitlistCtaButton(),
        ],
      ),
    );
  }
}

class _ManagedCard extends StatelessWidget {
  const _ManagedCard({required this.onGetPlan});

  final VoidCallback onGetPlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'MANAGED',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Let us run it for you', style: AppTextStyles.heading1),
          const SizedBox(height: AppSpacing.md),
          const WebsiteBulletItem(
            'Our team plans, sources creators, and executes the full '
            'campaign',
          ),
          const WebsiteBulletItem(
            'Content-first strategy focused on Reels and short-form video',
          ),
          const WebsiteBulletItem(
            'Real-time performance tracking and optimization',
          ),
          const WebsiteBulletItem(
            'Custom pricing based on your campaign size — no fixed rate '
            'card, ask us for a plan',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onGetPlan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text('Get Free Campaign Plan'),
            ),
          ),
        ],
      ),
    );
  }
}

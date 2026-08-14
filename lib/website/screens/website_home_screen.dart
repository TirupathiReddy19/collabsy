import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/waitlist_cta_button.dart';
import '../widgets/website_bullet_item.dart';
import '../widgets/website_section.dart';
import '../widgets/website_section_heading.dart';

const _howItWorks = [
  (
    Icons.person_add_alt_1_outlined,
    'Create your profile',
    'Creators connect Instagram and set up a profile; Brands describe '
        "what they're looking for.",
  ),
  (
    Icons.search_rounded,
    'Discover a match',
    'Brands browse verified micro-influencers; Creators browse open '
        'campaigns in their niche.',
  ),
  (
    Icons.chat_bubble_outline_rounded,
    'Talk it through',
    'Apply, chat, and agree on deliverables directly — no middleman '
        'reading your messages.',
  ),
  (
    Icons.trending_up_rounded,
    'Collaborate & grow',
    'Run the campaign, build a track record, and do it again with your '
        'next match.',
  ),
];

class WebsiteHomeScreen extends StatelessWidget {
  const WebsiteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Hero(),
        WebsiteSection(
          child: Column(
            children: [
              const WebsiteSectionHeading(
                eyebrow: 'How it works',
                title: 'From first message to finished campaign',
                subtitle:
                    'The same four steps, whichever side of the table '
                    "you're on.",
              ),
              const SizedBox(height: AppSpacing.xl),
              const _HowItWorksGrid(),
            ],
          ),
        ),
        WebsiteSection(
          backgroundColor: AppColors.primaryLight,
          child: const _AudienceSplit(),
        ),
        WebsiteSection(
          child: Column(
            children: [
              Text(
                'Why Collabsy',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  "We're just getting started, so instead of borrowed "
                  "logos and made-up numbers, here's what actually guides "
                  'how we build this.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _PrinciplesGrid(),
            ],
          ),
        ),
        WebsiteSection(
          backgroundColor: AppColors.textPrimary,
          child: Column(
            children: [
              Text(
                'Ready to get started?',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Creators and Brands both start the same way — join the '
                'waitlist and we\'ll bring you in as we roll out.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(width: 280, child: WaitlistCtaButton()),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

    return WebsiteSection(
      child: Column(
        children: [
          Text(
            'Where Creators and Brands\nactually get work done',
            textAlign: TextAlign.center,
            style: isWide
                ? AppTextStyles.displayLarge.copyWith(
                    fontSize: 48,
                    height: 1.15,
                  )
                : AppTextStyles.displayLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              'Collabsy connects D2C brands with micro-influencers for '
              'campaigns that convert — discover, apply, chat, and '
              'collaborate, all in one place.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: FilledButton(
                  onPressed: () => context.go('/creators'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text('For Creators'),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedButton(
                  onPressed: () => context.go('/brands'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text('For Brands'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HowItWorksGrid extends StatelessWidget {
  const _HowItWorksGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        for (final (icon, title, body) in _howItWorks)
          SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(height: 14),
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
      ],
    );
  }
}

class _AudienceSplit extends StatelessWidget {
  const _AudienceSplit();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      children: [
        SizedBox(
          width: 460,
          child: _AudienceCard(
            title: 'For Creators',
            color: AppColors.creator,
            bullets: const [
              'Discover paid campaigns from real D2C brands',
              'Apply in a tap, chat with brands directly',
              'Get verified and build a trustworthy profile',
            ],
            ctaLabel: 'Explore for Creators',
            onTap: () => context.go('/creators'),
          ),
        ),
        SizedBox(
          width: 460,
          child: _AudienceCard(
            title: 'For Brands',
            color: AppColors.brand,
            bullets: const [
              'Browse verified micro-influencers (10K–50K followers)',
              'Post a campaign or apply for a managed one',
              'Review applications and message creators directly',
            ],
            ctaLabel: 'Explore for Brands',
            onTap: () => context.go('/brands'),
          ),
        ),
      ],
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({
    required this.title,
    required this.color,
    required this.bullets,
    required this.ctaLabel,
    required this.onTap,
  });

  final String title;
  final Color color;
  final List<String> bullets;
  final String ctaLabel;
  final VoidCallback onTap;

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
          Text(title, style: AppTextStyles.heading1.copyWith(color: color)),
          const SizedBox(height: AppSpacing.md),
          for (final bullet in bullets) WebsiteBulletItem(bullet),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ctaLabel, style: AppTextStyles.link),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _principles = [
  (
    Icons.trending_up_rounded,
    'Built for conversions',
    'Every feature is designed around real campaign outcomes, not vanity '
        'metrics.',
  ),
  (
    Icons.groups_outlined,
    'Micro-influencers, real trust',
    "We're built around creators with 10K–50K followers — smaller, more "
        'engaged audiences.',
  ),
  (
    Icons.verified_outlined,
    'Verified on both sides',
    'Creators and Brands are both reviewed before they can post or apply, '
        'so conversations stay genuine.',
  ),
];

class _PrinciplesGrid extends StatelessWidget {
  const _PrinciplesGrid();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        for (final (icon, title, body) in _principles)
          SizedBox(
            width: 300,
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

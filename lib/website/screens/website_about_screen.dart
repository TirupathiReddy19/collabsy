import 'package:flutter/material.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/hero_backdrop.dart';
import '../widgets/hover_lift.dart';
import '../widgets/scroll_reveal_fade.dart';
import '../widgets/step_icon.dart';
import '../widgets/website_section.dart';
import '../widgets/website_section_heading.dart';

const _values = [
  (
    Icons.trending_up_rounded,
    'Sales over vanity metrics',
    'Every feature we build is judged by whether it moves a real campaign '
        'closer to a conversion — not by follower counts or impressions.',
  ),
  (
    Icons.groups_outlined,
    'Micro-influencers, real trust',
    'We believe smaller, more engaged audiences (10K–50K) build more '
        'trust with buyers than reach alone ever could.',
  ),
  (
    Icons.handshake_outlined,
    'Direct relationships',
    "Creators and Brands talk to each other, not through us. We build the "
        'tools; you build the relationship.',
  ),
  (
    Icons.verified_outlined,
    'Verified, not anonymous',
    'Both sides are reviewed before they can post a campaign or apply to '
        "one, so who you're talking to is who they say they are.",
  ),
];

class WebsiteAboutScreen extends StatelessWidget {
  const WebsiteAboutScreen({super.key});

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
                      'Why we built Collabsy',
                      textAlign: TextAlign.center,
                      style: isWide
                          ? AppTextStyles.displayLarge.copyWith(fontSize: 44)
                          : AppTextStyles.displayLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        WebsiteSection(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Influencer marketing in India runs on two broken '
                  'defaults: brands paying for reach they can\'t trace to a '
                  'single sale, and creators fielding cold DMs from brands '
                  "they've never heard of. Collabsy exists to fix both "
                  'sides of that at once.',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'We started with D2C brands who wanted campaigns judged '
                  'on sales, not screenshots — and built a platform where '
                  'Creators and Brands can find each other directly, verify '
                  'who they\'re working with, and run a campaign end to '
                  'end without either side guessing.',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "We're early. Rather than fill this page with client "
                  "logos we haven't earned yet, here's what we're actually "
                  'optimizing for as we build.',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        WebsiteSection(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              ScrollRevealFade(
                child: const WebsiteSectionHeading(title: 'What we optimize for'),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  for (final (index, (icon, title, body)) in _values.indexed)
                    ScrollRevealFade(
                      delay: Duration(milliseconds: index * 80),
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
      ],
    );
  }
}

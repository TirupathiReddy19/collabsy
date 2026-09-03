import 'package:flutter/material.dart';

import '../../core/theme/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/hero_backdrop.dart';
import '../widgets/hover_lift.dart';
import '../widgets/scroll_reveal_fade.dart';
import '../widgets/waitlist_cta_button.dart';
import '../widgets/website_bullet_item.dart';
import '../widgets/website_section.dart';
import '../widgets/website_section_heading.dart';

const _creatorSteps = [
  (
    '01',
    'Create your profile',
    'Sign up and connect your Instagram Business account — your follower '
        'count and recent posts show up automatically.',
  ),
  (
    '02',
    'Browse open campaigns',
    'Filter by niche and category to find D2C brands looking for someone '
        'like you.',
  ),
  (
    '03',
    'Apply and chat',
    'Apply in a tap, then talk deliverables, timelines, and compensation '
        'directly with the brand in-app.',
  ),
  (
    '04',
    'Collaborate and grow',
    'Deliver the campaign, build a track record, and keep discovering '
        'your next collaboration.',
  ),
];

class WebsiteCreatorsScreen extends StatelessWidget {
  const WebsiteCreatorsScreen({super.key});

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
                      'Turn your influence into\nreal brand partnerships',
                      textAlign: TextAlign.center,
                      style: isWide
                          ? AppTextStyles.displayLarge.copyWith(fontSize: 44)
                          : AppTextStyles.displayLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Text(
                        'Collabsy connects you with D2C brands looking for '
                        'creators like you — discover campaigns, apply, and '
                        'work directly with brands you actually want to '
                        'collaborate with.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SizedBox(width: 260, child: WaitlistCtaButton()),
                  ],
                ),
              ),
            ],
          ),
        ),
        WebsiteSection(
          child: Wrap(
            spacing: 48,
            runSpacing: 32,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              SizedBox(
                width: 460,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why creators use Collabsy',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const WebsiteBulletItem(
                      'Discover paid campaigns from real D2C brands, filtered '
                      'by your niche',
                    ),
                    const WebsiteBulletItem(
                      'Apply in a tap — no lengthy pitch decks or cold DMs',
                    ),
                    const WebsiteBulletItem(
                      'Chat and agree on deliverables and compensation '
                      'directly with the brand',
                    ),
                    const WebsiteBulletItem(
                      'A verified profile that builds trust with every brand '
                      'you apply to',
                    ),
                    const WebsiteBulletItem(
                      'Built around micro-influencers (10K–50K) — your '
                      'engaged audience is the point, not just reach',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 460,
                child: HoverLift(
                  borderRadius: AppRadius.xxl,
                  child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.creator.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    border: Border.all(
                      color: AppColors.creator.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.creator,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'How compensation works',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Collabsy helps you discover and connect with '
                        "brands — any agreement on deliverables or "
                        "compensation is worked out directly between you "
                        "and the brand, the same way it would be if they'd "
                        'reached out to you directly.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
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
                  eyebrow: 'How it works',
                  title: 'Four steps to your next collaboration',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  for (final (index, (number, title, body)) in _creatorSteps.indexed)
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
                                color: AppColors.creator.withValues(alpha: 0.35),
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
          backgroundColor: AppColors.textPrimary,
          child: Column(
            children: [
              Text(
                'Ready to find your next brand partner?',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Join the waitlist and we'll let you know the moment "
                "you're in.",
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

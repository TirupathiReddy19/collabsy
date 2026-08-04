import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_slide.dart';

const _slides = [
  OnboardingSlideData(
    emoji: '🔍',
    title: 'Discover the right partners',
    description:
        'Browse and filter to find creators and campaigns that are '
        'actually a fit for each other.',
  ),
  OnboardingSlideData(
    emoji: '🤝',
    title: 'Collaborate with confidence',
    description:
        'Chat, manage deliverables, and track every campaign in one place.',
  ),
  OnboardingSlideData(
    emoji: '📈',
    title: 'Grow together',
    description:
        'Track applications, deliverables, and campaign progress every '
        'step of the way.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(localStorageServiceProvider).setHasSeenOnboarding(true);
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    final index = ref.read(onboardingPageIndexProvider);
    if (index == _slides.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = ref.watch(onboardingPageIndexProvider);
    final isLastSlide = activeIndex == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenVertical,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) =>
                      ref.read(onboardingPageIndexProvider.notifier).set(index),
                  itemBuilder: (context, index) =>
                      OnboardingSlide(data: _slides[index]),
                ),
              ),
              OnboardingIndicator(
                count: _slides.length,
                activeIndex: activeIndex,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: isLastSlide ? 'Get Started' : 'Continue',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

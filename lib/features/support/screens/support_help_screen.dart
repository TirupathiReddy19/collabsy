import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/models/user_role.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/support_chat_providers.dart';

class _Faq {
  const _Faq(this.question, this.answer);

  final String question;
  final String answer;
}

const _creatorFaqs = [
  _Faq(
    'How do I apply to a campaign?',
    'Open the campaign from Browse Campaigns and tap Apply. The brand will '
        'review your application and accept or reject it.',
  ),
  _Faq(
    'How do I connect my Instagram account?',
    'Go to your profile\'s Connected Accounts screen and tap Connect '
        'Instagram — this uses Instagram\'s own login, we never see your '
        'password.',
  ),
  _Faq(
    'Can I withdraw an application after applying?',
    'Yes — open the application from My Applications and tap Withdraw. '
        'This isn\'t possible once the brand has already accepted it.',
  ),
  _Faq(
    'How do I get paid for a completed campaign?',
    'Once the brand approves your submitted deliverable, payment follows '
        'the terms shown on that campaign.',
  ),
];

const _brandFaqs = [
  _Faq(
    'Why is my campaign stuck in "Under Review"?',
    'Every new campaign is checked by our team before it goes live — this '
        'usually takes 15–30 minutes.',
  ),
  _Faq(
    'Why was my brand profile not verified?',
    'We check your website and LinkedIn before approving a brand account. '
        'Make sure both are filled in and publicly accessible, then contact '
        'support if it\'s still pending after a day.',
  ),
  _Faq(
    'How do I review a creator\'s application?',
    'Open the campaign from All Campaigns and go to its Applications tab '
        'to accept or reject each one.',
  ),
  _Faq(
    'Can I edit a campaign after publishing it?',
    'Yes, from the campaign\'s detail screen — changing it back to active '
        'from Under Review or Rejected is the only thing reserved for our '
        'review team.',
  ),
];

/// Shown before the actual support chat — a quick FAQ pass meant to answer
/// the most common questions without needing to wait on a reply. Content is
/// scoped to the signed-in account's own role (a creator never sees brand
/// -only questions and vice versa). "Contact Support" resumes the user's
/// still-open ticket if one exists, otherwise starts a fresh one.
class SupportHelpScreen extends ConsumerStatefulWidget {
  const SupportHelpScreen({super.key});

  @override
  ConsumerState<SupportHelpScreen> createState() => _SupportHelpScreenState();
}

class _SupportHelpScreenState extends ConsumerState<SupportHelpScreen> {
  bool _isStarting = false;

  Future<void> _contactSupport() async {
    setState(() => _isStarting = true);
    try {
      final ticketId = await ref
          .read(supportChatControllerProvider.notifier)
          .startOrResumeTicket();
      if (!mounted || ticketId == null) return;
      context.push(AppRoutes.supportChatPath(ticketId));
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't start a support ticket.");
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentProfileProvider).value?.role;
    final faqs = role == UserRole.brand ? _brandFaqs : _creatorFaqs;

    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                children: [
                  Text('Common questions', style: AppTextStyles.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  for (final faq in faqs)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          faq.question,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faq.answer,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.supportHistory),
                      child: const Text('View your past tickets'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: PrimaryButton(
                text: 'Still need help? Contact support',
                isLoading: _isStarting,
                onPressed: _isStarting ? null : _contactSupport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/providers/auth_providers.dart';
import '../../campaigns/models/application_status.dart';
import '../../campaigns/models/campaign.dart';
import '../../campaigns/models/campaign_status.dart';
import '../../campaigns/models/compensation_type.dart';
import '../../campaigns/models/deliverable.dart';
import '../../campaigns/models/deliverable_status.dart';
import '../../campaigns/providers/campaigns_providers.dart';
import '../../chat/providers/chat_providers.dart';
import '../../notifications/models/notification_type.dart';
import '../../notifications/providers/notifications_providers.dart';

class CreatorCampaignDetailScreen extends ConsumerStatefulWidget {
  const CreatorCampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<CreatorCampaignDetailScreen> createState() =>
      _CreatorCampaignDetailScreenState();
}

class _CreatorCampaignDetailScreenState
    extends ConsumerState<CreatorCampaignDetailScreen> {
  @override
  void initState() {
    super.initState();
    // A view is a provider write, so it has to wait until after this build
    // completes — Riverpod disallows modifying a provider during initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final creatorId = ref.read(authRepositoryProvider).currentUser?.uid;
      if (creatorId == null) return;
      ref
          .read(campaignControllerProvider.notifier)
          .recordView(campaignId: widget.campaignId, creatorId: creatorId);
    });
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    Campaign campaign,
  ) async {
    final agreed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ApplyAgreementSheet(campaign: campaign),
    );
    if (agreed != true) return;
    if (!context.mounted) return;
    await ref
        .read(campaignControllerProvider.notifier)
        .applyToCampaign(
          campaignId: widget.campaignId,
          campaignTitle: campaign.title,
          brandId: campaign.brandId,
          agreedDeliverablesSummary: _deliverablesLabel(campaign),
          agreedBudget: campaign.budget,
        );
    if (!context.mounted) return;
    if (ref.read(campaignControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't submit your application. Please try again.",
      );
      return;
    }
    AppSnackbar.showSuccess(context, 'Application submitted.');
  }

  Future<void> _messageBrand(
    BuildContext context,
    WidgetRef ref,
    Campaign campaign,
  ) async {
    final chatController = ref.read(chatControllerProvider.notifier);
    final chatId = await chatController.startChatAsCreator(
      brandId: campaign.brandId,
      brandName: campaign.brandName,
    );
    if (!context.mounted) return;
    if (ref.read(chatControllerProvider).hasError || chatId == null) {
      AppSnackbar.showError(
        context,
        "Couldn't start the chat. Please try again.",
      );
      return;
    }
    // Attaches the campaign so the ONE message the creator sends carries
    // both their note and a tappable "View campaign details" link in the
    // same bubble — a chat thread is just a property of the brand+creator
    // relationship now (no campaign scoping), so without this the brand
    // would have no way to tell which campaign the creator means, or see
    // its full details, from the chat alone.
    ref.read(pendingChatDraftProvider.notifier).set((
      text: "I'm interested in more details about this campaign.",
      campaignId: campaign.id,
    ));
    context.push(AppRoutes.chatDetailPath(chatId));
  }

  Future<void> _submitDeliverable(
    BuildContext context,
    WidgetRef ref,
    Deliverable deliverable,
    Campaign campaign,
  ) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _SubmitDeliverableSheet(),
    );
    if (note == null || note.isEmpty) return;
    if (!context.mounted) return;
    await ref
        .read(deliverableControllerProvider.notifier)
        .submit(deliverableId: deliverable.id, submissionNote: note);
    if (!context.mounted) return;
    if (ref.read(deliverableControllerProvider).hasError) {
      AppSnackbar.showError(context, "Couldn't submit. Please try again.");
      return;
    }
    final creatorName =
        ref.read(currentProfileProvider).value?.displayName ?? 'A creator';
    await ref
        .read(notificationsRepositoryProvider)
        .create(
          userId: campaign.brandId,
          type: NotificationType.deliverableSubmitted,
          title: 'Deliverable submitted',
          body:
              '$creatorName submitted their deliverable for ${campaign.title}',
          referenceType: 'campaign',
          referenceId: campaign.id,
        );
    if (!context.mounted) return;
    AppSnackbar.showSuccess(context, 'Deliverable submitted.');
  }

  @override
  Widget build(BuildContext context) {
    final campaignAsync = ref.watch(campaignByIdProvider(widget.campaignId));
    final isLoading = ref.watch(campaignControllerProvider).isLoading;
    final chatLoading = ref.watch(chatControllerProvider).isLoading;
    final userId = ref.watch(authRepositoryProvider).currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Campaign details')),
      body: SafeArea(
        child: campaignAsync.when(
          data: (campaign) {
            if (campaign == null) {
              return const Center(child: Text('Campaign not found.'));
            }
            final applicationProvider = userId == null
                ? null
                : myApplicationProvider(widget.campaignId, userId);
            final applicationAsync = applicationProvider == null
                ? null
                : ref.watch(applicationProvider);

            // Backfills a chat for an application that was accepted before
            // this feature existed — safe to run every time since
            // ensureActiveChat is a no-op once a chat is already active.
            if (applicationProvider != null) {
              ref.listen(applicationProvider, (previous, next) {
                final application = next.value;
                if (application?.status == ApplicationStatus.accepted) {
                  ref
                      .read(chatRepositoryProvider)
                      .ensureActiveChatAsCreator(
                        creatorId: application!.creatorId,
                        creatorName: application.creatorName,
                        brandId: campaign.brandId,
                        brandName: campaign.brandName,
                      );
                }
              });
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              children: [
                InkWell(
                  onTap: () => context.push(
                    AppRoutes.brandPublicProfilePath(campaign.brandId),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.storefront, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.brandName,
                              style: AppTextStyles.titleSmall,
                            ),
                            if (campaign.postedAgoLabel.isNotEmpty)
                              Text(
                                'Posted ${campaign.postedAgoLabel}',
                                style: AppTextStyles.micro.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _CampaignStatusChip(status: campaign.status),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(campaign.title, style: AppTextStyles.heading1),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: chatLoading
                      ? null
                      : () => _messageBrand(context, ref, campaign),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text('Message ${campaign.brandName}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                if (campaign.goal != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Looking for',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(campaign.goal!, style: AppTextStyles.titleSmall),
                ],
                const SizedBox(height: 20),
                Text('Highlights', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HighlightChip(
                      icon: Icons.campaign_outlined,
                      label: 'Brand',
                      value: campaign.brandName,
                    ),
                    _HighlightChip(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: campaign.categoriesLabel,
                    ),
                    if (campaign.creatorsNeeded != null)
                      _HighlightChip(
                        icon: Icons.groups_outlined,
                        label: 'No. of creators',
                        value: '${campaign.creatorsNeeded} creators',
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('About the campaign', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(campaign.description, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 24),
                Text('Key details', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.card),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: campaign.categoriesLabel,
                        ),
                        _DetailRow(
                          icon: Icons.public,
                          label: 'Platform',
                          value: 'Instagram · ${_followerRangeLabel(campaign)}',
                        ),
                        _DetailRow(
                          icon: Icons.groups_outlined,
                          label: 'No. of creators',
                          value: campaign.creatorsNeeded == null
                              ? 'Not specified'
                              : '${campaign.creatorsNeeded} creators',
                        ),
                        _DetailRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'Deliverables',
                          value: _deliverablesLabel(campaign),
                        ),
                        _DetailRow(
                          icon:
                              campaign.compensationType ==
                                  CompensationType.barter
                              ? Icons.handshake_outlined
                              : Icons.currency_rupee,
                          label: 'Compensation',
                          value:
                              campaign.compensationType ==
                                  CompensationType.barter
                              ? (campaign.barterDescription ?? 'Barter')
                              : campaign.compensationLabel,
                        ),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Open to creators from',
                          value: campaign.targetLocationsLabel,
                        ),
                        if (campaign.locationLabel.isNotEmpty)
                          _DetailRow(
                            icon: Icons.place_outlined,
                            label: 'Campaign location',
                            value: campaign.locationLabel,
                          ),
                        _DetailRow(
                          icon: Icons.event_outlined,
                          label: 'Timeline',
                          value: campaign.timelineLabel,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Activity on this post', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActivityStat(
                        label: 'Total views',
                        value: '${campaign.engagement}',
                      ),
                    ),
                    Expanded(
                      child: _ActivityStat(
                        label: 'Posted on',
                        value: campaign.createdAt == null
                            ? '—'
                            : _formatShortDate(campaign.createdAt!),
                      ),
                    ),
                    Expanded(
                      child: _ActivityStat(
                        label: 'Expires on',
                        value: campaign.endDate == null
                            ? '—'
                            : _formatShortDate(campaign.endDate!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (applicationAsync != null)
                  applicationAsync.when(
                    data: (application) {
                      if (application != null) {
                        if (application.status == ApplicationStatus.accepted &&
                            userId != null) {
                          return _DeliverableSection(
                            applicationId: application.id,
                            creatorId: userId,
                            onSubmit: (deliverable) => _submitDeliverable(
                              context,
                              ref,
                              deliverable,
                              campaign,
                            ),
                          );
                        }
                        return _AlreadyApplied(status: application.status);
                      }
                      return PrimaryButton(
                        text: 'Apply to this campaign',
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () => _apply(context, ref, campaign),
                      );
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, stackTrace) => const Text(
                      "Couldn't check your application status. Please try again.",
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text("Couldn't load this campaign.")),
        ),
      ),
    );
  }
}

String _followerRangeLabel(Campaign campaign) {
  final min = campaign.minFollowers;
  final max = campaign.maxFollowers;
  if (min == null && max == null) return 'Any followers';
  if (max == null) return '$min+ followers';
  if (min == null) return 'Up to $max followers';
  return '$min – $max followers';
}

String _deliverablesLabel(Campaign campaign) {
  final parts = <String>[campaign.deliverableType.label];
  if (campaign.instagramStoryCount > 0) {
    parts.add('${campaign.instagramStoryCount} Instagram Story');
  }
  if (campaign.instagramPostCount > 0) {
    parts.add('${campaign.instagramPostCount} Instagram Post');
  }
  return parts.join(' · ');
}

String _formatShortDate(DateTime date) =>
    '${date.day}/${date.month}/${date.year}';

class _CampaignStatusChip extends StatelessWidget {
  const _CampaignStatusChip({required this.status});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CampaignStatus.active => AppColors.success,
      CampaignStatus.underReview => AppColors.info,
      CampaignStatus.paused => AppColors.warning,
      CampaignStatus.rejected => AppColors.error,
      CampaignStatus.closed => AppColors.textHint,
      CampaignStatus.draft => AppColors.secondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.micro.copyWith(color: color),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  const _ActivityStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleSmall),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Shown before an application is actually submitted — makes explicit what
/// the creator is agreeing to (deliverables + pricing), so the brand isn't
/// the only side that saw those terms, and a snapshot of them travels with
/// the application (see [CampaignApplication.agreedDeliverablesSummary]).
class _ApplyAgreementSheet extends StatelessWidget {
  const _ApplyAgreementSheet({required this.campaign});

  final Campaign campaign;

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
          Text('Confirm your application', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            'By applying, you agree to deliver the following for this '
            'price if accepted.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.card),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AgreementRow(
                  label: 'Deliverables',
                  value: _deliverablesLabel(campaign),
                ),
                const SizedBox(height: 10),
                _AgreementRow(
                  label: 'Price',
                  value: campaign.compensationLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('No, cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Yes, I agree',
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}

/// Its own StatefulWidget so the controller is created and disposed by the
/// same widget's lifecycle — creating it in the parent and disposing it
/// right after `showModalBottomSheet` returns races the sheet's closing
/// animation, which still holds a listener on it, and crashes with "A
/// TextEditingController was used after being disposed."
class _SubmitDeliverableSheet extends StatefulWidget {
  const _SubmitDeliverableSheet();

  @override
  State<_SubmitDeliverableSheet> createState() =>
      _SubmitDeliverableSheetState();
}

class _SubmitDeliverableSheetState extends State<_SubmitDeliverableSheet> {
  final _controller = TextEditingController();

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Submit your deliverable', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Share a link to the content you posted, so the brand can '
            'review it.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _controller,
            label: 'Link or note',
            hintText: 'https://instagram.com/p/...',
            maxLines: 3,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Submit',
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          ),
        ],
      ),
    );
  }
}

class _AlreadyApplied extends StatelessWidget {
  const _AlreadyApplied({required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'You applied — status: ${status.label}',
        textAlign: TextAlign.center,
        style: AppTextStyles.titleSmall,
      ),
    );
  }
}

/// Shown once a creator's application is accepted — lets them submit proof
/// of the content they posted, or shows the status of a submission already
/// made. [deliverable] is null for a brief moment right after acceptance,
/// until the brand-side backfill/creation finishes.
class _DeliverableSection extends ConsumerWidget {
  const _DeliverableSection({
    required this.applicationId,
    required this.creatorId,
    required this.onSubmit,
  });

  final String applicationId;
  final String creatorId;
  final ValueChanged<Deliverable> onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliverableAsync = ref.watch(
      myDeliverableProvider(applicationId, creatorId),
    );
    return deliverableAsync.when(
      data: (deliverable) {
        if (deliverable == null) {
          return const _AlreadyApplied(status: ApplicationStatus.accepted);
        }
        return switch (deliverable.status) {
          DeliverableStatus.pending => Column(
            children: [
              const _AlreadyApplied(status: ApplicationStatus.accepted),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Submit your deliverable',
                onPressed: () => onSubmit(deliverable),
              ),
            ],
          ),
          DeliverableStatus.submitted => _StatusBanner(
            icon: Icons.hourglass_top,
            color: AppColors.warning,
            message: 'Submitted — awaiting review.',
          ),
          DeliverableStatus.approved => _StatusBanner(
            icon: Icons.check_circle,
            color: AppColors.success,
            message: 'Deliverable approved!',
          ),
        };
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stackTrace) =>
          const _AlreadyApplied(status: ApplicationStatus.accepted),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(message, style: AppTextStyles.titleSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

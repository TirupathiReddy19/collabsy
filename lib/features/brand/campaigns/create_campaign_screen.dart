import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/campaign_categories.dart';
import '../../../core/utils/india_regions.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/searchable_dropdown_field.dart';
import '../../../core/widgets/searchable_multi_select_field.dart';
import '../../campaigns/models/compensation_type.dart';
import '../../campaigns/models/deliverable_type.dart';
import '../../campaigns/providers/campaigns_providers.dart';

const _allIndia = 'All India';

/// 5-step campaign creation wizard for brands: info -> target -> deliverables
/// -> applicant messages -> review & publish. No AI features and no min
/// engagement rate — this app doesn't use AI, and the brief covers that
/// signal well enough on its own.
class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  ConsumerState<CreateCampaignScreen> createState() =>
      _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends ConsumerState<CreateCampaignScreen> {
  final _infoFormKey = GlobalKey<FormState>();
  final _deliverablesFormKey = GlobalKey<FormState>();
  final _messagesFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _minFollowersController = TextEditingController();
  final _maxFollowersController = TextEditingController();
  final _creatorsNeededController = TextEditingController();
  final _budgetController = TextEditingController();
  final _barterDescriptionController = TextEditingController();
  final _briefController = TextEditingController();
  final _acceptanceMessageController = TextEditingController();
  final _rejectionMessageController = TextEditingController();

  int _step = 0;
  String? _goal;
  final Set<String> _categories = {};
  Set<String> _targetLocations = {_allIndia};
  DeliverableType _deliverableType = DeliverableType.collabReel;
  int _instagramStoryCount = 0;
  int _instagramPostCount = 0;
  CompensationType _compensationType = CompensationType.cash;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _minFollowersController.dispose();
    _maxFollowersController.dispose();
    _creatorsNeededController.dispose();
    _budgetController.dispose();
    _barterDescriptionController.dispose();
    _briefController.dispose();
    _acceptanceMessageController.dispose();
    _rejectionMessageController.dispose();
    super.dispose();
  }

  void _continueFromInfo() {
    if (!_infoFormKey.currentState!.validate()) return;
    if (_goal == null) {
      AppSnackbar.showError(context, 'Select a campaign goal');
      return;
    }
    setState(() => _step = 1);
  }

  void _continueFromTarget() {
    if (_categories.isEmpty) {
      AppSnackbar.showError(context, 'Select at least one creator category');
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _continueFromDeliverables() {
    if (!_deliverablesFormKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      AppSnackbar.showError(context, 'Select a campaign timeline');
      return;
    }
    setState(() => _step = 3);
  }

  void _continueFromMessages() {
    if (!_messagesFormKey.currentState!.validate()) return;
    setState(() => _step = 4);
  }

  Future<void> _publish() async {
    await ref
        .read(campaignControllerProvider.notifier)
        .createCampaign(
          title: _titleController.text.trim(),
          description: _briefController.text.trim(),
          categories: _categories.toList(),
          goal: _goal,
          targetLocations: _targetLocations.contains(_allIndia)
              ? const []
              : _targetLocations.toList(),
          minFollowers: int.tryParse(_minFollowersController.text.trim()),
          maxFollowers: int.tryParse(_maxFollowersController.text.trim()),
          creatorsNeeded: int.tryParse(_creatorsNeededController.text.trim()),
          deliverableType: _deliverableType,
          instagramStoryCount: _instagramStoryCount,
          instagramPostCount: _instagramPostCount,
          compensationType: _compensationType,
          budget: _compensationType == CompensationType.cash
              ? int.parse(_budgetController.text.trim())
              : null,
          barterDescription: _compensationType == CompensationType.barter
              ? _barterDescriptionController.text.trim()
              : null,
          startDate: _startDate,
          endDate: _endDate,
          acceptanceMessage: _acceptanceMessageController.text.trim(),
          rejectionMessage: _rejectionMessageController.text.trim(),
        );
    if (!mounted) return;

    if (ref.read(campaignControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't publish the campaign. Please try again.",
      );
      return;
    }

    AppSnackbar.showSuccess(context, 'Campaign published.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(campaignControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('New campaign — Step ${_step + 1} of 5'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 0) {
              context.pop();
            } else {
              setState(() => _step -= 1);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: switch (_step) {
            0 => _InfoStep(
              formKey: _infoFormKey,
              titleController: _titleController,
              goal: _goal,
              isLoading: isLoading,
              onGoalChanged: (value) => setState(() => _goal = value),
              onContinue: _continueFromInfo,
            ),
            1 => _TargetStep(
              categories: _categories,
              targetLocations: _targetLocations,
              minFollowersController: _minFollowersController,
              maxFollowersController: _maxFollowersController,
              creatorsNeededController: _creatorsNeededController,
              isLoading: isLoading,
              onCategoryToggled: (value) => setState(
                () => _categories.contains(value)
                    ? _categories.remove(value)
                    : _categories.add(value),
              ),
              onLocationsChanged: (value) =>
                  setState(() => _targetLocations = value),
              onContinue: _continueFromTarget,
            ),
            2 => _DeliverablesStep(
              formKey: _deliverablesFormKey,
              selectedType: _deliverableType,
              instagramStoryCount: _instagramStoryCount,
              instagramPostCount: _instagramPostCount,
              compensationType: _compensationType,
              budgetController: _budgetController,
              barterDescriptionController: _barterDescriptionController,
              briefController: _briefController,
              startDate: _startDate,
              endDate: _endDate,
              isLoading: isLoading,
              onTypeChanged: (value) =>
                  setState(() => _deliverableType = value),
              onStoryCountChanged: (value) =>
                  setState(() => _instagramStoryCount = value),
              onPostCountChanged: (value) =>
                  setState(() => _instagramPostCount = value),
              onCompensationTypeChanged: (value) =>
                  setState(() => _compensationType = value),
              onPickDateRange: _pickDateRange,
              onContinue: _continueFromDeliverables,
            ),
            3 => _MessagesStep(
              formKey: _messagesFormKey,
              acceptanceMessageController: _acceptanceMessageController,
              rejectionMessageController: _rejectionMessageController,
              isLoading: isLoading,
              onContinue: _continueFromMessages,
            ),
            _ => _ReviewStep(
              title: _titleController.text.trim(),
              brief: _briefController.text.trim(),
              goal: _goal ?? '',
              categories: _categories,
              targetLocations: _targetLocations,
              minFollowers: _minFollowersController.text.trim(),
              maxFollowers: _maxFollowersController.text.trim(),
              creatorsNeeded: _creatorsNeededController.text.trim(),
              deliverableType: _deliverableType,
              instagramStoryCount: _instagramStoryCount,
              instagramPostCount: _instagramPostCount,
              compensationType: _compensationType,
              budget: _budgetController.text.trim(),
              barterDescription: _barterDescriptionController.text.trim(),
              startDate: _startDate,
              endDate: _endDate,
              isLoading: isLoading,
              onPublish: _publish,
            ),
          },
        ),
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  const _InfoStep({
    required this.formKey,
    required this.titleController,
    required this.goal,
    required this.isLoading,
    required this.onGoalChanged,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final String? goal;
  final bool isLoading;
  final ValueChanged<String> onGoalChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Campaign info', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Give creators a clear idea of what this campaign is about.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: titleController,
            label: 'Campaign name',
            hintText: 'Festive Collection Launch',
            enabled: !isLoading,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a campaign name'
                : null,
          ),
          const SizedBox(height: 16),
          SearchableDropdownField(
            label: 'Campaign goal',
            items: campaignGoals,
            selected: goal,
            enabled: !isLoading,
            onChanged: onGoalChanged,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Continue',
            onPressed: isLoading ? null : onContinue,
          ),
        ],
      ),
    );
  }
}

class _TargetStep extends StatelessWidget {
  const _TargetStep({
    required this.categories,
    required this.targetLocations,
    required this.minFollowersController,
    required this.maxFollowersController,
    required this.creatorsNeededController,
    required this.isLoading,
    required this.onCategoryToggled,
    required this.onLocationsChanged,
    required this.onContinue,
  });

  final Set<String> categories;
  final Set<String> targetLocations;
  final TextEditingController minFollowersController;
  final TextEditingController maxFollowersController;
  final TextEditingController creatorsNeededController;
  final bool isLoading;
  final ValueChanged<String> onCategoryToggled;
  final ValueChanged<Set<String>> onLocationsChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target audience', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text(
          'Which creators should see this campaign?',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('Creator categories', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in campaignCategories)
              FilterChip(
                label: Text(category),
                selected: categories.contains(category),
                onSelected: isLoading
                    ? null
                    : (_) => onCategoryToggled(category),
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primaryDark,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: categories.contains(category)
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                ),
                side: BorderSide(
                  color: categories.contains(category)
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SearchableMultiSelectField(
          label: 'Target location',
          items: [_allIndia, ...indianStates],
          selected: targetLocations,
          exclusiveOption: _allIndia,
          enabled: !isLoading,
          onChanged: onLocationsChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: minFollowersController,
                label: 'Min followers',
                hintText: '1000',
                keyboardType: TextInputType.number,
                enabled: !isLoading,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: maxFollowersController,
                label: 'Max followers',
                hintText: '100000',
                keyboardType: TextInputType.number,
                enabled: !isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: creatorsNeededController,
          label: 'Number of creators needed',
          hintText: '50',
          keyboardType: TextInputType.number,
          enabled: !isLoading,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Continue',
          onPressed: isLoading ? null : onContinue,
        ),
      ],
    );
  }
}

class _DeliverablesStep extends StatelessWidget {
  const _DeliverablesStep({
    required this.formKey,
    required this.selectedType,
    required this.instagramStoryCount,
    required this.instagramPostCount,
    required this.compensationType,
    required this.budgetController,
    required this.barterDescriptionController,
    required this.briefController,
    required this.startDate,
    required this.endDate,
    required this.isLoading,
    required this.onTypeChanged,
    required this.onStoryCountChanged,
    required this.onPostCountChanged,
    required this.onCompensationTypeChanged,
    required this.onPickDateRange,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final DeliverableType selectedType;
  final int instagramStoryCount;
  final int instagramPostCount;
  final CompensationType compensationType;
  final TextEditingController budgetController;
  final TextEditingController barterDescriptionController;
  final TextEditingController briefController;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final ValueChanged<DeliverableType> onTypeChanged;
  final ValueChanged<int> onStoryCountChanged;
  final ValueChanged<int> onPostCountChanged;
  final ValueChanged<CompensationType> onCompensationTypeChanged;
  final VoidCallback onPickDateRange;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deliverables', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'What should creators deliver for this campaign?',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Reel type', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          ...DeliverableType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DeliverableOption(
                type: type,
                selected: type == selectedType,
                enabled: !isLoading,
                onTap: () => onTypeChanged(type),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Other deliverables per creator',
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 12),
          _CounterRow(
            label: 'Instagram Story',
            value: instagramStoryCount,
            enabled: !isLoading,
            onChanged: onStoryCountChanged,
          ),
          const SizedBox(height: 8),
          _CounterRow(
            label: 'Instagram Post',
            value: instagramPostCount,
            enabled: !isLoading,
            onChanged: onPostCountChanged,
          ),
          const SizedBox(height: 20),
          Text('Compensation', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: CompensationType.values.map((type) {
              final selected = type == compensationType;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type.label),
                  selected: selected,
                  onSelected: isLoading
                      ? null
                      : (_) => onCompensationTypeChanged(type),
                  selectedColor: AppColors.primaryLight,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (compensationType == CompensationType.cash)
            AppTextField(
              controller: budgetController,
              label: 'Budget per creator (₹)',
              hintText: '500',
              keyboardType: TextInputType.number,
              enabled: !isLoading,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Enter a budget per creator';
                if (int.tryParse(trimmed) == null) return 'Numbers only';
                return null;
              },
            )
          else
            AppTextField(
              controller: barterDescriptionController,
              label: 'What are you offering in exchange?',
              hintText: 'e.g. Free products worth ₹2,000',
              maxLines: 2,
              enabled: !isLoading,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Describe what creators get in return'
                  : null,
            ),
          const SizedBox(height: 16),
          Text('Timeline', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: isLoading ? null : onPickDateRange,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                startDate == null || endDate == null
                    ? 'Select a start and end date'
                    : '${_fmt(startDate!)} – ${_fmt(endDate!)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: startDate == null
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: briefController,
            label: 'Campaign brief',
            hintText: "What do you want creators to do?",
            maxLines: 4,
            enabled: !isLoading,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a campaign brief'
                : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Continue',
            onPressed: isLoading ? null : onContinue,
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
            onPressed: enabled && value > 0 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
            onPressed: enabled ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _DeliverableOption extends StatelessWidget {
  const _DeliverableOption({
    required this.type,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final DeliverableType type;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Text(type.label, style: AppTextStyles.titleSmall),
            if (type == DeliverableType.both) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Popular',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessagesStep extends StatelessWidget {
  const _MessagesStep({
    required this.formKey,
    required this.acceptanceMessageController,
    required this.rejectionMessageController,
    required this.isLoading,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController acceptanceMessageController;
  final TextEditingController rejectionMessageController;
  final bool isLoading;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Applicant messages', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Sent automatically to a creator the moment you accept or '
            'reject their application, so they hear back right away.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: acceptanceMessageController,
            label: 'Message on acceptance',
            hintText: "Congrats! You've been accepted for this campaign.",
            maxLines: 3,
            enabled: !isLoading,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a message for accepted applicants'
                : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: rejectionMessageController,
            label: 'Message on rejection',
            hintText:
                "Thanks for applying — we've gone with another creator "
                'this time.',
            maxLines: 3,
            enabled: !isLoading,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a message for rejected applicants'
                : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Continue',
            onPressed: isLoading ? null : onContinue,
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.title,
    required this.brief,
    required this.goal,
    required this.categories,
    required this.targetLocations,
    required this.minFollowers,
    required this.maxFollowers,
    required this.creatorsNeeded,
    required this.deliverableType,
    required this.instagramStoryCount,
    required this.instagramPostCount,
    required this.compensationType,
    required this.budget,
    required this.barterDescription,
    required this.startDate,
    required this.endDate,
    required this.isLoading,
    required this.onPublish,
  });

  final String title;
  final String brief;
  final String goal;
  final Set<String> categories;
  final Set<String> targetLocations;
  final String minFollowers;
  final String maxFollowers;
  final String creatorsNeeded;
  final DeliverableType deliverableType;
  final int instagramStoryCount;
  final int instagramPostCount;
  final CompensationType compensationType;
  final String budget;
  final String barterDescription;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final VoidCallback onPublish;

  String get _timeline {
    if (startDate == null || endDate == null) return '—';
    return '${_fmt(startDate!)} – ${_fmt(endDate!)}';
  }

  static String _fmt(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String get _followerRange {
    if (minFollowers.isEmpty && maxFollowers.isEmpty) return 'Any';
    if (maxFollowers.isEmpty) return '$minFollowers+';
    if (minFollowers.isEmpty) return 'Up to $maxFollowers';
    return '$minFollowers – $maxFollowers';
  }

  String get _compensationSummary {
    if (compensationType == CompensationType.barter) {
      return barterDescription.isEmpty ? 'Barter' : barterDescription;
    }
    final perCreator = int.tryParse(budget);
    final count = int.tryParse(creatorsNeeded);
    if (perCreator == null || count == null) return '₹$budget per creator';
    return '₹$budget per creator · ₹${perCreator * count} total';
  }

  String get _deliverablesSummary {
    final parts = <String>[deliverableType.label];
    if (instagramStoryCount > 0) {
      parts.add('$instagramStoryCount Instagram Story');
    }
    if (instagramPostCount > 0) {
      parts.add('$instagramPostCount Instagram Post');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & publish', style: AppTextStyles.heading2),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),
                Text(
                  'Campaign brief',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(brief, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                _ReviewRow(label: 'Goal', value: goal),
                _ReviewRow(
                  label: 'Categories',
                  value: categories.isEmpty ? '—' : categories.join(', '),
                ),
                _ReviewRow(
                  label: 'Open to creators from',
                  value: targetLocations.isEmpty
                      ? _allIndia
                      : targetLocations.join(', '),
                ),
                _ReviewRow(label: 'Followers', value: _followerRange),
                _ReviewRow(
                  label: 'Creators needed',
                  value: creatorsNeeded.isEmpty ? '—' : creatorsNeeded,
                ),
                _ReviewRow(label: 'Deliverables', value: _deliverablesSummary),
                _ReviewRow(
                  label: compensationType == CompensationType.barter
                      ? 'Barter'
                      : 'Budget',
                  value: _compensationSummary,
                ),
                _ReviewRow(label: 'Timeline', value: _timeline),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Publish campaign',
          onPressed: isLoading ? null : onPublish,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

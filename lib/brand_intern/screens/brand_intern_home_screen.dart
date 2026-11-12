import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/brand_email_campaign.dart';
import '../../shared/models/brand_lead.dart';
import '../../shared/models/brand_prospect.dart';
import '../../shared/utils/linkedin_url.dart';
import '../providers/brand_intern_campaigns_providers.dart';
import '../providers/brand_intern_leads_providers.dart';
import '../providers/brand_intern_prospects_providers.dart';

const _linkBaseUrl = 'https://collabsy.online/bl/';

const _defaultMessageTemplate =
    "Hi! 👋 I came across your profile and think your brand would be a "
    'great fit for Collabsy — a platform that connects brands with '
    'creators for influencer campaigns. Download the app from the Play '
    'Store or App Store here: {{link}}';

const _defaultMassEmailSubject = 'Partnering with Collabsy';

const _defaultMassEmailBody =
    'Hi there,\n\n'
    "I'm reaching out from Collabsy — a platform that connects brands "
    'with content creators for influencer marketing campaigns. We think '
    'your brand would be a great fit for a collaboration.\n\n'
    'Collabsy makes it easy to discover and work with vetted creators, '
    'run campaigns, and track results, all in one place. Would you be '
    'open to a quick call to explore working together?\n\n'
    'Looking forward to hearing from you.\n\n'
    'Best,\n{{internName}}\nCollabsy';

const _defaultProspectEmailSubject = 'Partnering with {{brandName}} — Collabsy';

const _defaultProspectEmailBody =
    'Hi {{brandName}} team,\n\n'
    "I'm reaching out from Collabsy — a platform that connects brands "
    'with content creators for influencer marketing campaigns. We think '
    '{{brandName}} would be a great fit for a collaboration.\n\n'
    'Collabsy makes it easy to discover and work with vetted creators, '
    'run campaigns, and track results, all in one place. Would you be '
    'open to a quick call to explore working together?\n\n'
    'Looking forward to hearing from you.\n\n'
    'Best,\n{{internName}}\nCollabsy';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _fmtDate(DateTime? time) {
  if (time == null) return '—';
  return '${_months[time.month - 1]} ${time.day}, ${time.year}';
}

/// Short, glanceable "how long ago" for the links list — falls back to a
/// full date once it's more than a week old.
String _relativeTime(DateTime? time) {
  if (time == null) return '—';
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return _fmtDate(time);
}

bool _inRange(DateTime? value, DateTime start, DateTime endExclusive) {
  if (value == null) return false;
  return !value.isBefore(start) && value.isBefore(endExclusive);
}

enum _StatusFilter {
  all('All statuses'),
  linkGenerated('Link sent'),
  clicked('Clicked'),
  signedUp('Signed up'),
  onboardingComplete('Onboarded');

  const _StatusFilter(this.label);
  final String label;
}

String _statusLabel(String status) => switch (status) {
  'clicked' => 'Clicked',
  'signedUp' => 'Signed up',
  'onboardingComplete' => 'Onboarded',
  _ => 'Link sent',
};

Color _statusColor(String status) => switch (status) {
  'clicked' => AppColors.info,
  'signedUp' => AppColors.purple,
  'onboardingComplete' => AppColors.success,
  _ => AppColors.textSecondary,
};

Color _statusBackground(String status) => switch (status) {
  'clicked' => AppColors.infoLight,
  'signedUp' => AppColors.purpleLight,
  'onboardingComplete' => AppColors.successLight,
  _ => AppColors.background,
};

IconData _statusIcon(String status) => switch (status) {
  'clicked' => Icons.touch_app_outlined,
  'signedUp' => Icons.person_add_alt_1_outlined,
  'onboardingComplete' => Icons.check_circle_outline,
  _ => Icons.north_east_outlined,
};

/// The brand outreach tool's only screen (still true in spirit — these are
/// tabs within one route, not separate screens/sub-routes): generate a
/// tracking link for a LinkedIn profile you found yourself, or work through
/// the admin-pushed "My Prospects" reference list from the bulk-imported
/// research pool.
class BrandInternHomeScreen extends ConsumerStatefulWidget {
  const BrandInternHomeScreen({super.key});

  @override
  ConsumerState<BrandInternHomeScreen> createState() =>
      _BrandInternHomeScreenState();
}

class _BrandInternHomeScreenState extends ConsumerState<BrandInternHomeScreen>
    with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  bool _isGenerating = false;
  bool _justCopiedMessage = false;
  BrandLead? _duplicateLead;
  BrandLead? _generatedLead;

  late DateTime _start;
  late DateTime _end;
  _StatusFilter _statusFilter = _StatusFilter.all;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _end = DateTime(today.year, today.month, today.day);
    _start = _end.subtract(const Duration(days: 29));
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  DateTime get _endExclusive => _end.add(const Duration(days: 1));

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: _end,
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _end = picked);
  }

  List<BrandLead> _filterLeads(List<BrandLead> leads) {
    return leads.where((lead) {
      if (!_inRange(lead.createdAt, _start, _endExclusive)) return false;
      if (_statusFilter == _StatusFilter.all) return true;
      return lead.status == _statusFilter.name;
    }).toList();
  }

  Future<void> _generate() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return;
    final handle = normalizeLinkedInUrl(raw);
    if (handle.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _duplicateLead = null;
      _generatedLead = null;
    });

    try {
      final repository = ref.read(brandInternLeadsRepositoryProvider);
      final existing = await repository.fetch(handle);
      if (existing != null) {
        setState(() => _duplicateLead = existing);
        return;
      }

      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) return;

      final config = await ref.read(brandOutreachConfigProvider.future);
      // A saved-but-blank template (the admin form writes '' when its box is
      // left empty) must fall back to the default too, otherwise interns get
      // an empty message with no link in it.
      final customTemplate = config?['messageTemplate'] as String?;
      final template =
          (customTemplate != null && customTemplate.trim().isNotEmpty)
          ? customTemplate
          : _defaultMessageTemplate;
      final link = '$_linkBaseUrl$handle';
      final message = template.replaceAll('{{link}}', link);

      await repository.create(
        handle: handle,
        linkedinUrl: raw,
        internId: user.uid,
        internEmail: user.email ?? '',
        message: message,
      );

      setState(() {
        _generatedLead = (
          handle: handle,
          linkedinUrl: raw,
          internId: user.uid,
          internEmail: user.email ?? '',
          message: message,
          status: 'linkGenerated',
          createdAt: DateTime.now(),
          clickedAt: null,
          clickCount: 0,
          matchedUid: null,
          signedUpAt: null,
          onboardingCompleteAt: null,
        );
        _urlController.clear();
      });
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't generate a link.");
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _copyMessage(String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    if (!mounted) return;
    setState(() => _justCopiedMessage = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justCopiedMessage = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final myLeads =
        ref.watch(myBrandLeadsProvider).value ?? const <BrandLead>[];
    final myProspects =
        ref.watch(myBrandProspectsProvider).value ?? const <BrandProspect>[];
    final signedUpCount = myLeads
        .where(
          (l) => l.status == 'signedUp' || l.status == 'onboardingComplete',
        )
        .length;
    final onboardedCount = myLeads
        .where((l) => l.status == 'onboardingComplete')
        .length;
    final filteredLeads = _filterLeads(myLeads);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            totalLinks: myLeads.length,
            signedUp: signedUpCount,
            onboarded: onboardedCount,
            onSignOut: () => ref.read(authRepositoryProvider).signOut(),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              const Tab(text: 'Generate link'),
              Tab(text: 'My prospects (${myProspects.length})'),
              const Tab(text: 'Bulk email'),
              const Tab(text: 'Dashboard'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GeneratorCard(
                            urlController: _urlController,
                            isGenerating: _isGenerating,
                            onGenerate: _generate,
                            duplicateLead: _duplicateLead,
                            generatedLead: _generatedLead,
                            justCopiedMessage: _justCopiedMessage,
                            onCopyMessage: _copyMessage,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text('My Links', style: AppTextStyles.titleLarge),
                          const SizedBox(height: AppSpacing.md),
                          if (myLeads.isEmpty)
                            const EmptyState(
                              icon: Icons.send_outlined,
                              title: 'No links yet',
                              subtitle:
                                  'Paste a LinkedIn profile above to '
                                  'generate your first one.',
                            )
                          else ...[
                            _LinksFilterCard(
                              start: _start,
                              end: _end,
                              statusFilter: _statusFilter,
                              onPickStart: _pickStart,
                              onPickEnd: _pickEnd,
                              onStatusChanged: (value) =>
                                  setState(() => _statusFilter = value),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (filteredLeads.isEmpty)
                              const EmptyState(
                                icon: Icons.filter_alt_off_outlined,
                                title: 'No links match this filter',
                                subtitle:
                                    'Try widening the date range or '
                                    'status filter above.',
                              )
                            else
                              Column(
                                children: [
                                  for (final (index, lead)
                                      in filteredLeads.indexed)
                                    StaggeredFadeIn(
                                      key: ValueKey(lead.handle),
                                      delay: Duration(
                                        milliseconds: (index * 40).clamp(
                                          0,
                                          400,
                                        ),
                                      ),
                                      child: _LeadRow(lead: lead),
                                    ),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                _ProspectsTab(prospects: myProspects),
                _BulkEmailTab(prospects: myProspects),
                _DashboardTab(leads: myLeads, prospects: myProspects),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "My Prospects" — the reference list an admin has pushed to this intern
/// from the bulk-imported brand research pool. Deliberately no link
/// generation and no click tracking here: just the prospect's details plus
/// an optional one-way "Mark contacted" self-report.
class _ProspectsTab extends ConsumerWidget {
  const _ProspectsTab({required this.prospects});

  final List<BrandProspect> prospects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (prospects.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 48),
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No prospects pushed to you yet',
              subtitle:
                  "When admin assigns you a category from the brand "
                  'research pool, they will show up here.',
            ),
          ),
        ),
      );
    }

    final contactedCount = prospects.where((p) => p.contacted).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$contactedCount of ${prospects.length} contacted',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final (index, prospect) in prospects.indexed)
                StaggeredFadeIn(
                  key: ValueKey(prospect.id),
                  delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
                  child: _ProspectRow(prospect: prospect),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Bulk email" — a dedicated destination for the one-click mass-email
/// blast (`_MassEmailDialog`), separate from "My Prospects" since it's a
/// distinct action (one email to everyone at once) rather than something
/// you'd reach for per-prospect.
class _BulkEmailTab extends ConsumerStatefulWidget {
  const _BulkEmailTab({required this.prospects});

  final List<BrandProspect> prospects;

  @override
  ConsumerState<_BulkEmailTab> createState() => _BulkEmailTabState();
}

class _BulkEmailTabState extends ConsumerState<_BulkEmailTab> {
  /// Which saved campaign (if any) pre-fills the compose dialog's subject
  /// /body — `null` means the generic default template.
  String? _selectedCampaignId;

  /// Doc ids of prospects currently checked — empty by default, so a send
  /// always reflects a deliberate choice rather than "everyone" by
  /// default. Only ids of prospects that actually have an email are ever
  /// added here (see [_selectableIds]), so this always matches what a
  /// send would actually include.
  final Set<String> _selectedIds = {};

  List<BrandProspect> get prospects => widget.prospects;

  List<BrandProspect> get _selectable =>
      prospects.where((p) => p.emails.isNotEmpty).toList();

  Set<String> get _selectableIds => _selectable.map((p) => p.id).toSet();

  void _toggle(String prospectId, bool? checked) {
    setState(() {
      if (checked ?? false) {
        _selectedIds.add(prospectId);
      } else {
        _selectedIds.remove(prospectId);
      }
    });
  }

  void _toggleAll(bool? checked) {
    setState(() {
      if (checked ?? false) {
        _selectedIds
          ..clear()
          ..addAll(_selectableIds);
      } else {
        _selectedIds.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final withEmail = _selectable.length;
    final contacted = prospects.where((p) => p.contacted).length;
    final selectedCount = _selectedIds.length;
    final allSelected =
        withEmail > 0 && _selectedIds.length == _selectableIds.length;
    final someSelected = _selectedIds.isNotEmpty && !allSelected;

    final campaigns = ref.watch(myBrandEmailCampaignsProvider).value ?? const [];
    final selectedCampaign = campaigns
        .cast<BrandEmailCampaign?>()
        .firstWhere((c) => c?.id == _selectedCampaignId, orElse: () => null);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.campaign_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 2),
                        Expanded(
                          child: Text(
                            'Bulk email campaign',
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Check off who should get it below, then send one '
                      'email, Bcc\'d to everyone selected, through your own '
                      'connected mailbox. Nobody sees who else received it.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CampaignPicker(
                      selectedCampaignId: _selectedCampaignId,
                      onChanged: (id) => setState(() => _selectedCampaignId = id),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          _BulkEmailStat(label: 'Prospects', value: prospects.length),
                          _bulkStatDivider(),
                          _BulkEmailStat(label: 'Selected', value: selectedCount),
                          _bulkStatDivider(),
                          _BulkEmailStat(label: 'Already contacted', value: contacted),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      text: selectedCount == 0
                          ? 'Compose bulk email'
                          : 'Compose for $selectedCount selected',
                      icon: Icons.campaign_outlined,
                      onPressed: selectedCount == 0
                          ? null
                          : () => showDialog<void>(
                              context: context,
                              builder: (context) => _MassEmailDialog(
                                prospects: prospects
                                    .where((p) => _selectedIds.contains(p.id))
                                    .toList(),
                                initialSubject: selectedCampaign?.subject,
                                initialBody: selectedCampaign?.body,
                              ),
                            ),
                    ),
                    if (withEmail == 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        prospects.isEmpty
                            ? "You don't have any prospects assigned yet."
                            : "None of your prospects have an email on file.",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (prospects.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Every contact',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: withEmail == 0
                          ? null
                          : () => _toggleAll(!allSelected),
                      child: Text(allSelected ? 'Select none' : 'Select all'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _BulkEmailContactRow(
                        email: 'Email',
                        category: 'Category',
                        sent: null,
                        isHeader: true,
                        checked: allSelected,
                        tristate: someSelected,
                        onChanged: withEmail == 0 ? null : _toggleAll,
                      ),
                      for (final (index, prospect) in prospects.indexed) ...[
                        if (index > 0)
                          const Divider(height: 1, color: AppColors.border),
                        _BulkEmailContactRow(
                          email: prospect.emails.isEmpty
                              ? '—'
                              : prospect.emails.first,
                          category: prospect.category ?? '—',
                          sent: prospect.massEmailSentAt != null,
                          checked: _selectedIds.contains(prospect.id),
                          onChanged: prospect.emails.isEmpty
                              ? null
                              : (checked) => _toggle(prospect.id, checked),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulkStatDivider() => Container(
    width: 1,
    height: 28,
    color: AppColors.border,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
  );
}

class _BulkEmailStat extends StatelessWidget {
  const _BulkEmailStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: AppTextStyles.heading2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Lets an intern pick one of their saved campaigns to prefill the bulk
/// -compose dialog's subject/body, or leave it as a one-off custom
/// message — and jump into managing (creating/editing/deleting) those
/// campaigns without leaving the Bulk Email tab.
class _CampaignPicker extends ConsumerWidget {
  const _CampaignPicker({
    required this.selectedCampaignId,
    required this.onChanged,
  });

  final String? selectedCampaignId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(myBrandEmailCampaignsProvider).value ?? const [];
    // A previously picked campaign may have just been deleted out from
    // under this dropdown — fall back to "Custom message" rather than
    // crash on a value DropdownButtonFormField no longer has an item for.
    final validSelectedId = campaigns.any((c) => c.id == selectedCampaignId)
        ? selectedCampaignId
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            initialValue: validSelectedId,
            decoration: const InputDecoration(
              labelText: 'Campaign',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Custom message')),
              for (final campaign in campaigns)
                DropdownMenuItem(
                  value: campaign.id,
                  child: Text(campaign.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TextButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => const _ManageCampaignsDialog(),
            ),
            icon: const Icon(Icons.edit_note_outlined, size: 18),
            label: const Text('Manage'),
          ),
        ),
      ],
    );
  }
}

class _ManageCampaignsDialog extends ConsumerWidget {
  const _ManageCampaignsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(myBrandEmailCampaignsProvider);

    return AlertDialog(
      title: const Text('Campaigns'),
      content: SizedBox(
        width: 420,
        child: campaignsAsync.when(
          data: (campaigns) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (campaigns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'No saved campaigns yet.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: campaigns.length,
                    separatorBuilder: (context, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) =>
                        _CampaignListTile(campaign: campaigns[index]),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => const _CampaignFormDialog(),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New campaign'),
              ),
            ],
          ),
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const Text('Could not load campaigns.'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _CampaignListTile extends ConsumerWidget {
  const _CampaignListTile({required this.campaign});

  final BrandEmailCampaign campaign;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete campaign?'),
        content: Text('"${campaign.name}" will be gone for good.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(brandInternCampaignsRepositoryProvider)
          .delete(campaign.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        campaign.name,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        campaign.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => _CampaignFormDialog(existing: campaign),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Create (no [existing]) or edit (with [existing]) one saved campaign
/// template.
class _CampaignFormDialog extends ConsumerStatefulWidget {
  const _CampaignFormDialog({this.existing});

  final BrandEmailCampaign? existing;

  @override
  ConsumerState<_CampaignFormDialog> createState() =>
      _CampaignFormDialogState();
}

class _CampaignFormDialogState extends ConsumerState<_CampaignFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _subjectController = TextEditingController(
      text: widget.existing?.subject ?? '',
    );
    _bodyController = TextEditingController(text: widget.existing?.body ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();
    if (name.isEmpty || subject.isEmpty || body.isEmpty) {
      AppSnackbar.showError(context, 'Enter a name, subject, and message.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(brandInternCampaignsRepositoryProvider);
      if (widget.existing != null) {
        await repository.update(
          campaignId: widget.existing!.id,
          name: name,
          subject: subject,
          body: body,
        );
      } else {
        final internId = ref.read(authRepositoryProvider).currentUser?.uid;
        if (internId == null) return;
        await repository.create(
          internId: internId,
          name: name,
          subject: subject,
          body: body,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackbar.showError(context, "Couldn't save the campaign.");
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New campaign' : 'Edit campaign'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Campaign name',
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _subjectController,
              label: 'Subject',
              enabled: !_isSaving,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _bodyController,
              maxLines: 8,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          width: 100,
          height: 40,
          text: 'Save',
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }
}

/// One compact, single-line row in the Bulk Email tab's contact list —
/// email, category, and whether `sendBrandProspectMassEmail` has ever
/// stamped `massEmailSentAt` on this prospect. [sent] is `null` only for
/// the header row, where it renders the column label instead of a pill.
class _BulkEmailContactRow extends StatelessWidget {
  const _BulkEmailContactRow({
    required this.email,
    required this.category,
    required this.sent,
    required this.checked,
    required this.onChanged,
    this.isHeader = false,
    this.tristate = false,
  });

  final String email;
  final String category;
  final bool? sent;
  final bool isHeader;

  /// Whether this row's checkbox is checked — for the header row, this is
  /// "every selectable row is checked" ([_BulkEmailTabState.allSelected]).
  final bool checked;

  /// `true` only for the header row when some (not all) rows below are
  /// checked, so its checkbox renders as a dash instead of a tick.
  final bool tristate;

  /// `null` disables the checkbox — used for a row with no email (nothing
  /// to send to) or the header when nothing is selectable at all.
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isHeader
        ? AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)
        : AppTextStyles.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Checkbox(
              value: tristate ? null : checked,
              tristate: tristate,
              onChanged: onChanged,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              email,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 64,
            child: isHeader
                ? Text('Mail sent', style: labelStyle)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: _YesNoPill(value: sent!),
                  ),
          ),
        ],
      ),
    );
  }
}

class _YesNoPill extends StatelessWidget {
  const _YesNoPill({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final color = value ? AppColors.success : AppColors.textSecondary;
    final background = value ? AppColors.successLight : AppColors.background;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        value ? 'Yes' : 'No',
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// One place that combines both of this intern's outreach funnels — the
/// personally-generated `BrandLead` link funnel (sent -> clicked -> signed
/// up -> onboarded) and the admin-pushed `BrandProspect` pool (assigned ->
/// contacted -> ever included in a bulk send) — rather than leaving them
/// scattered across the header chips and the other tabs' own stat rows.
/// Admin sees the same two groups per intern, all at once, in
/// AdminBrandOutreachReportsScreen.
class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.leads, required this.prospects});

  final List<BrandLead> leads;
  final List<BrandProspect> prospects;

  @override
  Widget build(BuildContext context) {
    final clicked = leads
        .where(
          (l) =>
              l.status == 'clicked' ||
              l.status == 'signedUp' ||
              l.status == 'onboardingComplete',
        )
        .length;
    final signedUp = leads
        .where((l) => l.status == 'signedUp' || l.status == 'onboardingComplete')
        .length;
    final onboarded = leads.where((l) => l.status == 'onboardingComplete').length;

    final contacted = prospects.where((p) => p.contacted).length;
    final bulkEmailed = prospects.where((p) => p.massEmailSentAt != null).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardCard(
                title: 'Outreach links',
                icon: Icons.link_outlined,
                stats: [
                  _BulkEmailStat(label: 'Sent', value: leads.length),
                  _BulkEmailStat(label: 'Clicked', value: clicked),
                  _BulkEmailStat(label: 'Signed up', value: signedUp),
                  _BulkEmailStat(label: 'Onboarded', value: onboarded),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _DashboardCard(
                title: 'Prospect pool',
                icon: Icons.inventory_2_outlined,
                stats: [
                  _BulkEmailStat(label: 'Assigned', value: prospects.length),
                  _BulkEmailStat(label: 'Contacted', value: contacted),
                  _BulkEmailStat(label: 'Bulk emailed', value: bulkEmailed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.stats,
  });

  final String title;
  final IconData icon;
  final List<Widget> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: stats),
        ],
      ),
    );
  }
}

class _ProspectRow extends ConsumerStatefulWidget {
  const _ProspectRow({required this.prospect});

  final BrandProspect prospect;

  @override
  ConsumerState<_ProspectRow> createState() => _ProspectRowState();
}

class _ProspectRowState extends ConsumerState<_ProspectRow> {
  bool _expanded = false;
  bool _isMarking = false;

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    AppSnackbar.showSuccess(context, '$label copied.');
  }

  Future<void> _markContacted() async {
    setState(() => _isMarking = true);
    try {
      await ref
          .read(brandInternProspectsRepositoryProvider)
          .markContacted(widget.prospect.id);
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't mark as contacted.");
    } finally {
      if (mounted) setState(() => _isMarking = false);
    }
  }

  void _openCompose() {
    showDialog<void>(
      context: context,
      builder: (context) => _ComposeEmailDialog(prospect: widget.prospect),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prospect = widget.prospect;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.splashGradientLight,
                        AppColors.primaryDark,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    prospect.brandName.isEmpty
                        ? '?'
                        : prospect.brandName[0].toUpperCase(),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prospect.brandName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [
                          if (prospect.category != null) prospect.category!,
                          if (prospect.city != null) prospect.city!,
                        ].join(' · '),
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (prospect.contacted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Contacted',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: const Icon(
                    Icons.expand_more,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm + 4),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: AppSpacing.sm + 4),
                      _CopyableField(
                        label: 'Website',
                        value: prospect.website ?? '—',
                        onCopy: prospect.website == null
                            ? null
                            : () => _copy(prospect.website!, 'Website'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CopyableField(
                        label: prospect.emails.length == 1
                            ? 'Email'
                            : 'Emails',
                        value: prospect.emails.isEmpty
                            ? '—'
                            : prospect.emails.join(', '),
                        onCopy: prospect.emails.isEmpty
                            ? null
                            : () =>
                                  _copy(prospect.emails.join(', '), 'Emails'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CopyableField(
                        label: 'Instagram',
                        value: prospect.instagramUrl ?? '—',
                        onCopy: prospect.instagramUrl == null
                            ? null
                            : () =>
                                  _copy(prospect.instagramUrl!, 'Instagram'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CopyableField(
                        label: 'LinkedIn',
                        value: prospect.linkedinUrl ?? '—',
                        onCopy: prospect.linkedinUrl == null
                            ? null
                            : () => _copy(prospect.linkedinUrl!, 'LinkedIn'),
                      ),
                      const SizedBox(height: AppSpacing.sm + 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!prospect.contacted)
                              OutlinedButton.icon(
                                onPressed: _isMarking ? null : _markContacted,
                                icon: _isMarking
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check, size: 16),
                                label: const Text('Mark contacted'),
                              ),
                            OutlinedButton.icon(
                              onPressed: _openCompose,
                              icon: const Icon(Icons.mail_outline, size: 16),
                              label: const Text('Send email'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalLinks,
    required this.signedUp,
    required this.onboarded,
    required this.onSignOut,
  });

  final int totalLinks;
  final int signedUp;
  final int onboarded;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.splashGradientLight, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'C',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Collabsy',
                          style: AppTextStyles.splashTitle.copyWith(
                            fontSize: 20,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Brand Outreach Tool',
                          style: AppTextStyles.splashSubtitle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Sign out',
                    onPressed: onSignOut,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.splashGlass,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.splashGlassBorder),
                ),
                child: Row(
                  children: [
                    _StatChip(label: 'Links sent', value: totalLinks),
                    _statDivider(),
                    _StatChip(label: 'Signed up', value: signedUp),
                    _statDivider(),
                    _StatChip(label: 'Onboarded', value: onboarded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 28,
    color: AppColors.splashGlassBorder,
    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
  );
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GeneratorCard extends StatelessWidget {
  const _GeneratorCard({
    required this.urlController,
    required this.isGenerating,
    required this.onGenerate,
    required this.duplicateLead,
    required this.generatedLead,
    required this.justCopiedMessage,
    required this.onCopyMessage,
  });

  final TextEditingController urlController;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final BrandLead? duplicateLead;
  final BrandLead? generatedLead;
  final bool justCopiedMessage;
  final ValueChanged<String> onCopyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Text(
                  'Paste a LinkedIn profile',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "We'll check if anyone's already contacted them, and hand you "
            'a tracking link + message if not.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: urlController,
            hintText: 'https://linkedin.com/in/username',
            prefixIcon: const Icon(
              Icons.link,
              color: AppColors.textHint,
              size: 20,
            ),
            enabled: !isGenerating,
            onSubmitted: (_) => onGenerate(),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            text: 'Generate link',
            icon: Icons.auto_awesome_outlined,
            isLoading: isGenerating,
            onPressed: isGenerating ? null : onGenerate,
          ),
          if (duplicateLead != null) ...[
            const SizedBox(height: AppSpacing.md),
            _DuplicateCard(lead: duplicateLead!),
          ],
          if (generatedLead != null) ...[
            const SizedBox(height: AppSpacing.md),
            _SuccessCard(
              lead: generatedLead!,
              justCopied: justCopiedMessage,
              onCopy: () => onCopyMessage(generatedLead!.message),
            ),
          ],
        ],
      ),
    );
  }
}

class _DuplicateCard extends StatelessWidget {
  const _DuplicateCard({required this.lead});

  final BrandLead lead;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block_flipped, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Already claimed',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${lead.handle} was contacted by ${lead.internEmail} on '
                  '${_fmtDate(lead.createdAt)}.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatusPill(status: lead.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.lead,
    required this.justCopied,
    required this.onCopy,
  });

  final BrandLead lead;
  final bool justCopied;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.celebration_outlined,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ready to send',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm + 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: SelectableText(lead.message, style: AppTextStyles.bodyLarge),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onCopy,
              icon: Icon(
                justCopied ? Icons.check : Icons.copy,
                size: 16,
                color: justCopied ? AppColors.success : null,
              ),
              label: Text(justCopied ? 'Copied!' : 'Copy message'),
              style: justCopied
                  ? OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 13, color: _statusColor(status)),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: AppTextStyles.bodySmall.copyWith(
              color: _statusColor(status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinksFilterCard extends StatelessWidget {
  const _LinksFilterCard({
    required this.start,
    required this.end,
    required this.statusFilter,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onStatusChanged,
  });

  final DateTime start;
  final DateTime end;
  final _StatusFilter statusFilter;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final ValueChanged<_StatusFilter> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickStart,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text('From: ${_fmtDate(start)}'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickEnd,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text('To: ${_fmtDate(end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          DropdownButtonFormField<_StatusFilter>(
            initialValue: statusFilter,
            decoration: const InputDecoration(labelText: 'Status'),
            items: _StatusFilter.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (value) {
              if (value != null) onStatusChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

/// A single "My Links" row — tap to expand and reveal the link + message
/// that were generated for this lead, each with its own copy button, so
/// an intern can re-send/re-copy without regenerating anything.
class _LeadRow extends StatefulWidget {
  const _LeadRow({required this.lead});

  final BrandLead lead;

  @override
  State<_LeadRow> createState() => _LeadRowState();
}

class _LeadRowState extends State<_LeadRow> {
  bool _expanded = false;

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    AppSnackbar.showSuccess(context, '$label copied.');
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final link = '$_linkBaseUrl${lead.handle}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.splashGradientLight,
                        AppColors.primaryDark,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lead.handle.isEmpty ? '?' : lead.handle[0].toUpperCase(),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.handle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _relativeTime(lead.createdAt),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: lead.status),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: const Icon(
                    Icons.expand_more,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm + 4),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: AppSpacing.sm + 4),
                      _CopyableField(
                        label: 'Link',
                        value: link,
                        onCopy: () => _copy(link, 'Link'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CopyableField(
                        label: 'Message',
                        value: lead.message,
                        onCopy: () => _copy(lead.message, 'Message'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  const _CopyableField({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.labelSmall)),
            if (onCopy != null)
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.copy,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: SelectableText(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: onCopy == null
                  ? AppColors.textHint
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The "connect your mailbox" step shared by every outreach-sending dialog
/// (one prospect, or the mass-email blast) — mail.collabsy.online
/// credentials are the same regardless of which dialog triggered the
/// connect, so this is the only place that logic lives.
class _ConnectMailboxStep extends ConsumerStatefulWidget {
  const _ConnectMailboxStep({required this.onConnected});

  /// Called with the connected address once `connectMailbox` succeeds.
  final ValueChanged<String> onConnected;

  @override
  ConsumerState<_ConnectMailboxStep> createState() =>
      _ConnectMailboxStepState();
}

class _ConnectMailboxStepState extends ConsumerState<_ConnectMailboxStep> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConnecting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (Validators.email(email) != null || password.isEmpty) {
      setState(() => _error = 'Enter a valid email and password.');
      return;
    }

    setState(() {
      _isConnecting = true;
      _error = null;
    });
    try {
      await ref
          .read(brandInternProspectsRepositoryProvider)
          .connectMailbox(email: email, password: password);
      widget.onConnected(email);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message ?? "Couldn't connect that mailbox.");
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "Couldn't connect that mailbox.");
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect your mailbox'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outreach emails send through your own '
              'mail.collabsy.online mailbox — connect it once and every '
              'email after goes out with one click.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _emailController,
              label: 'Mailbox email',
              hintText: 'you@collabsy.online',
              keyboardType: TextInputType.emailAddress,
              enabled: !_isConnecting,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _passwordController,
              label: 'Mailbox password',
              obscureText: true,
              enabled: !_isConnecting,
              onSubmitted: (_) => _connect(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConnecting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          width: 120,
          height: 40,
          text: 'Connect',
          isLoading: _isConnecting,
          onPressed: _isConnecting ? null : _connect,
        ),
      ],
    );
  }
}

/// Composes and sends a real outreach email for one prospect, through the
/// intern's own mail.collabsy.online mailbox (`sendBrandProspectEmail`) —
/// mail.collabsy.online's webmail has no way to be prefilled by a plain
/// link, so sending happens server-side instead, using mailbox credentials
/// the intern connects once (`connectBrandMailbox`) and that stay connected
/// for every send after. Shows the "connect your mailbox" step first if
/// they haven't yet, otherwise goes straight to compose.
class _ComposeEmailDialog extends ConsumerStatefulWidget {
  const _ComposeEmailDialog({required this.prospect});

  final BrandProspect prospect;

  @override
  ConsumerState<_ComposeEmailDialog> createState() =>
      _ComposeEmailDialogState();
}

enum _ComposeStep { checkingMailbox, connectMailbox, compose }

class _ComposeEmailDialogState extends ConsumerState<_ComposeEmailDialog> {
  _ComposeStep _step = _ComposeStep.checkingMailbox;
  String? _mailboxEmail;

  late final TextEditingController _toController;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _toController = TextEditingController(
      text: widget.prospect.emails.isEmpty ? '' : widget.prospect.emails.first,
    );

    final internEmail =
        ref.read(authRepositoryProvider).currentUser?.email ?? '';
    final internName = internEmail.contains('@')
        ? internEmail.split('@').first
        : 'Collabsy Team';

    _subjectController = TextEditingController(
      text: _defaultProspectEmailSubject.replaceAll(
        '{{brandName}}',
        widget.prospect.brandName,
      ),
    );
    _bodyController = TextEditingController(
      text: _defaultProspectEmailBody
          .replaceAll('{{brandName}}', widget.prospect.brandName)
          .replaceAll('{{internName}}', internName),
    );

    _loadMailboxStatus();
  }

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadMailboxStatus() async {
    try {
      final email = await ref
          .read(brandInternProspectsRepositoryProvider)
          .mailboxStatus();
      if (!mounted) return;
      setState(() {
        _mailboxEmail = email;
        _step = email == null
            ? _ComposeStep.connectMailbox
            : _ComposeStep.compose;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _step = _ComposeStep.connectMailbox);
    }
  }

  Future<void> _send() async {
    final to = _toController.text.trim();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();
    if (Validators.email(to) != null || subject.isEmpty || body.isEmpty) {
      AppSnackbar.showError(
        context,
        'Enter a valid email, subject, and message.',
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref
          .read(brandInternProspectsRepositoryProvider)
          .sendProspectEmail(to: to, subject: subject, body: body);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      AppSnackbar.showError(context, e.message ?? "Couldn't send the email.");
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
      AppSnackbar.showError(context, "Couldn't send the email.");
      return;
    }

    // Best-effort — the email already sent; a failed self-report write
    // (e.g. already contacted) shouldn't surface as a failure.
    if (!widget.prospect.contacted) {
      try {
        await ref
            .read(brandInternProspectsRepositoryProvider)
            .markContacted(widget.prospect.id);
      } catch (_) {
        // Ignore — see comment above.
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackbar.showSuccess(context, 'Email sent.');
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _ComposeStep.checkingMailbox:
        return const AlertDialog(
          content: SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      case _ComposeStep.connectMailbox:
        return _ConnectMailboxStep(
          onConnected: (email) => setState(() {
            _mailboxEmail = email;
            _step = _ComposeStep.compose;
          }),
        );
      case _ComposeStep.compose:
        return _buildComposeStep(context);
    }
  }

  Widget _buildComposeStep(BuildContext context) {
    final otherEmails = widget.prospect.emails
        .where((e) => e != _toController.text.trim())
        .toList();

    return AlertDialog(
      title: const Text('Compose outreach email'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_mailboxEmail != null) ...[
              Text(
                'Sending as $_mailboxEmail',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            AppTextField(
              controller: _toController,
              label: 'To',
              hintText: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              enabled: !_isSending,
              onChanged: (_) => setState(() {}),
            ),
            if (otherEmails.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final email in otherEmails)
                    ActionChip(
                      label: Text(email, style: AppTextStyles.bodySmall),
                      onPressed: _isSending
                          ? null
                          : () => setState(() {
                              _toController.text = email;
                            }),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _subjectController,
              label: 'Subject',
              enabled: !_isSending,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _bodyController,
              maxLines: 8,
              enabled: !_isSending,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          width: 120,
          height: 40,
          text: 'Send',
          icon: Icons.send_outlined,
          isLoading: _isSending,
          onPressed: _isSending ? null : _send,
        ),
      ],
    );
  }
}

/// Sends one email, Bcc'd to every prospect in [prospects] at once — the
/// caller (the Bulk Email tab's checkbox list) has already narrowed this
/// down to the selected ones; `sendBrandProspectMassEmail` still
/// re-validates each id server-side before including it. Marks each
/// recipient contacted. Since Bcc can't personalize per recipient, the
/// template has no `{{brandName}}` placeholder — just `{{internName}}`.
/// [initialSubject]/[initialBody] prefill from a saved campaign when the
/// intern picked one in the Bulk Email tab; `null` falls back to the
/// generic default template.
class _MassEmailDialog extends ConsumerStatefulWidget {
  const _MassEmailDialog({
    required this.prospects,
    this.initialSubject,
    this.initialBody,
  });

  final List<BrandProspect> prospects;
  final String? initialSubject;
  final String? initialBody;

  @override
  ConsumerState<_MassEmailDialog> createState() => _MassEmailDialogState();
}

class _MassEmailDialogState extends ConsumerState<_MassEmailDialog> {
  _ComposeStep _step = _ComposeStep.checkingMailbox;
  String? _mailboxEmail;

  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final internEmail =
        ref.read(authRepositoryProvider).currentUser?.email ?? '';
    final internName = internEmail.contains('@')
        ? internEmail.split('@').first
        : 'Collabsy Team';

    _subjectController = TextEditingController(
      text: widget.initialSubject ?? _defaultMassEmailSubject,
    );
    _bodyController = TextEditingController(
      text:
          widget.initialBody ??
          _defaultMassEmailBody.replaceAll('{{internName}}', internName),
    );

    _loadMailboxStatus();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  int get _recipientCount =>
      widget.prospects.where((p) => p.emails.isNotEmpty).length;

  Future<void> _loadMailboxStatus() async {
    try {
      final email = await ref
          .read(brandInternProspectsRepositoryProvider)
          .mailboxStatus();
      if (!mounted) return;
      setState(() {
        _mailboxEmail = email;
        _step = email == null
            ? _ComposeStep.connectMailbox
            : _ComposeStep.compose;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _step = _ComposeStep.connectMailbox);
    }
  }

  Future<void> _send() async {
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();
    if (subject.isEmpty || body.isEmpty) {
      AppSnackbar.showError(context, 'Enter a subject and message.');
      return;
    }

    final ids = widget.prospects
        .where((p) => p.emails.isNotEmpty)
        .map((p) => p.id)
        .toSet();

    setState(() => _isSending = true);
    final int sent;
    try {
      sent = await ref
          .read(brandInternProspectsRepositoryProvider)
          .sendMassEmail(subject: subject, body: body, prospectIds: ids);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      AppSnackbar.showError(context, e.message ?? "Couldn't send the email.");
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
      AppSnackbar.showError(context, "Couldn't send the email.");
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackbar.showSuccess(context, 'Sent to $sent contacts.');
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _ComposeStep.checkingMailbox:
        return const AlertDialog(
          content: SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      case _ComposeStep.connectMailbox:
        return _ConnectMailboxStep(
          onConnected: (email) => setState(() {
            _mailboxEmail = email;
            _step = _ComposeStep.compose;
          }),
        );
      case _ComposeStep.compose:
        return _buildComposeStep(context);
    }
  }

  Widget _buildComposeStep(BuildContext context) {
    return AlertDialog(
      title: const Text('Email all prospects'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_mailboxEmail != null) ...[
              Text(
                'Sending as $_mailboxEmail',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              widget.prospects.length == _recipientCount
                  ? 'Bcc\'d to $_recipientCount selected prospects. Everyone '
                        'gets this exact text — nobody sees who else '
                        'received it.'
                  : 'Bcc\'d to $_recipientCount of ${widget.prospects.length} '
                        'selected prospects (the rest have no email on '
                        'file). Everyone gets this exact text — nobody sees '
                        'who else received it.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: _subjectController,
              label: 'Subject',
              enabled: !_isSending,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _bodyController,
              maxLines: 8,
              enabled: !_isSending,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          width: 160,
          height: 40,
          text: 'Send to $_recipientCount',
          icon: Icons.send_outlined,
          isLoading: _isSending,
          onPressed: _isSending || _recipientCount == 0 ? null : _send,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/brand_lead.dart';
import '../../shared/models/brand_prospect.dart';
import '../../shared/utils/linkedin_url.dart';
import '../providers/brand_intern_leads_providers.dart';
import '../providers/brand_intern_prospects_providers.dart';

const _linkBaseUrl = 'https://collabsy.online/bl/';

const _defaultMessageTemplate =
    "Hi! 👋 I came across your profile and think your brand would be a "
    'great fit for Collabsy — a platform that connects brands with '
    'creators for influencer campaigns. Download the app from the Play '
    'Store or App Store here: {{link}}';

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
    _tabController = TabController(length: 2, vsync: this);
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
                      if (prospect.emailSentCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Text(
                            'Emailed ${prospect.emailSentCount}x'
                            '${prospect.emailSentAt == null ? '' : ' · last ${_relativeTime(prospect.emailSentAt)}'}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
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
                            if (prospect.emails.isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: _openCompose,
                                icon: const Icon(
                                  Icons.mail_outline,
                                  size: 16,
                                ),
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

/// Composes and sends a real outreach email for one prospect, through
/// Collabsy's own mailbox (`sendBrandProspectEmail`) — not a `mailto:`
/// link, so it works the same on every platform and the prospect's
/// `emailSentAt`/`emailSentCount`/`contacted` update automatically once it
/// goes through (this dialog itself only has to await the call).
class _ComposeEmailDialog extends ConsumerStatefulWidget {
  const _ComposeEmailDialog({required this.prospect});

  final BrandProspect prospect;

  @override
  ConsumerState<_ComposeEmailDialog> createState() =>
      _ComposeEmailDialogState();
}

class _ComposeEmailDialogState extends ConsumerState<_ComposeEmailDialog> {
  late String _to;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _to = widget.prospect.emails.first;

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
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();
    if (subject.isEmpty || body.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(brandInternProspectsRepositoryProvider)
          .sendEmail(
            prospectId: widget.prospect.id,
            to: _to,
            subject: subject,
            body: body,
          );
      if (!mounted) return;
      Navigator.pop(context);
      AppSnackbar.showSuccess(context, 'Email sent to $_to.');
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        "Couldn't send the email. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emails = widget.prospect.emails;

    return AlertDialog(
      title: const Text('Send outreach email'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emails.length > 1)
              DropdownButtonFormField<String>(
                initialValue: _to,
                decoration: const InputDecoration(labelText: 'To'),
                items: emails
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: _isSending
                    ? null
                    : (value) => setState(() => _to = value ?? _to),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'To: $_to',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
          width: 120,
          height: 40,
          text: 'Send',
          isLoading: _isSending,
          onPressed: _isSending ? null : _send,
        ),
      ],
    );
  }
}

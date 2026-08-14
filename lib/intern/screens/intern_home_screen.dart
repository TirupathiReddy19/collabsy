import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_breakpoints.dart';
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
import '../../shared/models/lead.dart';
import '../../shared/utils/instagram_handle.dart';
import '../providers/intern_leads_providers.dart';
import '../providers/intern_shift_providers.dart';

const _linkBaseUrl = 'https://collabsy-leads.web.app/l/';

/// A shift is 4 hours with a target of 200 messages sent.
const _shiftTargetHours = 4;
const _shiftMessageTarget = 200;

/// How often we credit active time to Firestore while the tab is focused —
/// see `_InternHomeScreenState.didChangeAppLifecycleState`.
const _shiftTickInterval = Duration(seconds: 30);

/// The comment an intern also leaves on the creator's post/profile,
/// alongside the DM — shown once they've copied the message, in
/// `_SuccessCard`. One is picked at random per lead (see `_pickRandom`)
/// and stored on the lead (`Lead.comment`) so it stays stable if the row
/// is revisited later — sending the exact same text hundreds of times a
/// day is what gets outreach accounts flagged as spam.
const _outreachComments = [
  'looking for collabs check your DM.',
  'sent you a DM about brand collabs!',
  'check your DM — got something for you.',
  'DM sent, take a look when you get a chance!',
];

/// Once the intern copies the message, the comment step unlocks this long
/// after — enough time to actually paste and send the DM in Instagram —
/// and once they copy the comment, the "Mark as sent" button unlocks
/// [_completeRevealDelay] after that. See `_SuccessCard`. This can't
/// verify anything actually went out on Instagram (nothing can, from
/// outside Instagram's own systems), but it forces a realistic minimum
/// pace and turns "did nothing" into an explicit, checkable claim instead
/// of silence.
const _commentRevealDelay = Duration(seconds: 15);
const _completeRevealDelay = Duration(seconds: 10);

/// The first cold-outreach DM. Same spam-avoidance reasoning as
/// [_outreachComments] — one is picked at random per lead in `_generate`
/// and stored as `Lead.message`, rather than sending identical text to
/// every target.
const _messageTemplates = [
  "Hi! 👋 I came across your profile and think you'd be a great fit for "
      'brand collaborations on Collabsy — a platform that connects '
      'influencers like you with brand campaigns. Check it out here: '
      '{{link}}',
  'Hey! I run outreach for Collabsy — we connect creators like you with '
      'brand collab opportunities. Your content stood out to me. Take a '
      'look: {{link}}',
  "Hi there! Really like your content — think you'd be a great fit for "
      'brand partnerships on Collabsy. Check it out here: {{link}}',
  "Hey 👋 quick one — Collabsy connects creators with brand campaigns, "
      "and your profile looks like a great fit. Here's the link: {{link}}",
];

/// Sent instead of a pick from [_messageTemplates] when following up on a
/// lead that's sitting in the "Needs follow-up" bucket (see
/// `_needsFollowUp`) — different wording than the first cold-outreach DM,
/// since the target has presumably already seen that one. Also picked at
/// random per follow-up, same reasoning.
const _followUpMessageTemplates = [
  "Hey again! 👋 Just following up in case this got buried — still "
      "think you'd be a great fit for brand collabs on Collabsy. Here's "
      'that link again: {{link}}',
  "Hi again! Not sure if my last message got lost — still think you'd "
      'be a great fit for brand collaborations on Collabsy. Here\'s the '
      'link: {{link}}',
  "Just circling back on this — brand collabs on Collabsy, still think "
      "you'd be a great fit. Link again here: {{link}}",
  'Following up in case you missed it! Would love for you to check out '
      'Collabsy for brand collab opportunities: {{link}}',
];

/// The follow-up send flow skips the comment step entirely (unlike the
/// first-touch flow in `_SuccessCard`) — just copy the message, wait this
/// long, then log it as sent. See `_FollowUpFlow`.
const _followUpConfirmDelay = Duration(seconds: 10);

final _random = Random();

T _pickRandom<T>(List<T> options) => options[_random.nextInt(options.length)];

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

/// A lead that hasn't been clicked yet needs a follow-up once it's been
/// sitting this long since the link was generated.
const _followUpNoClickAfter = Duration(days: 3);

/// A lead that was clicked but never signed up needs a follow-up once
/// it's been this long since the click.
const _followUpNoSignupAfter = Duration(days: 7);

/// Derived from the lead's current state, except once the intern has
/// actually logged a follow-up send (`lastFollowUpSentAt` set via
/// `_FollowUpFlow`/`logFollowUp`) — at that point it drops out of the
/// bucket for good, so a followed-up lead doesn't keep nagging.
bool _needsFollowUp(Lead lead) {
  if (lead.lastFollowUpSentAt != null) return false;
  final now = DateTime.now();
  if (lead.status == 'linkGenerated' && lead.createdAt != null) {
    return now.difference(lead.createdAt!) >= _followUpNoClickAfter;
  }
  if (lead.status == 'clicked' && lead.clickedAt != null) {
    return now.difference(lead.clickedAt!) >= _followUpNoSignupAfter;
  }
  return false;
}

enum _StatusFilter {
  all('All statuses'),
  needsFollowUp('Needs follow-up'),
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

/// The intern tool's only screen — paste a target's Instagram profile,
/// get back a unique tracking link + ready-to-send DM, or find out
/// someone else already claimed them.
class InternHomeScreen extends ConsumerStatefulWidget {
  const InternHomeScreen({super.key});

  @override
  ConsumerState<InternHomeScreen> createState() => _InternHomeScreenState();
}

class _InternHomeScreenState extends ConsumerState<InternHomeScreen>
    with WidgetsBindingObserver {
  final _urlController = TextEditingController();
  bool _isGenerating = false;
  bool _justCopiedMessage = false;
  Lead? _duplicateLead;
  Lead? _generatedLead;

  late DateTime _start;
  late DateTime _end;
  _StatusFilter _statusFilter = _StatusFilter.all;

  // Shift time tracking — only credits time while the tab is actually
  // focused (AppLifecycleState.resumed), never while backgrounded, per
  // the product requirement that this must not overcount a forgotten-open
  // tab. See intern_shift_providers.dart for the write side.
  bool _isTabActive = true;
  Timer? _shiftTicker;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _end = DateTime(today.year, today.month, today.day);
    _start = _end.subtract(const Duration(days: 29));

    WidgetsBinding.instance.addObserver(this);
    _shiftTicker = Timer.periodic(
      _shiftTickInterval,
      (_) => _creditShiftTick(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shiftTicker?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isTabActive = state == AppLifecycleState.resumed;
  }

  void _creditShiftTick() {
    if (!_isTabActive || !mounted) return;
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    ref
        .read(internShiftRepositoryProvider)
        .incrementActiveSeconds(
          internId: user.uid,
          internEmail: user.email ?? '',
          seconds: _shiftTickInterval.inSeconds,
        );
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

  List<Lead> _filterLeads(List<Lead> leads) {
    return leads.where((lead) {
      if (!_inRange(lead.createdAt, _start, _endExclusive)) return false;
      switch (_statusFilter) {
        case _StatusFilter.all:
          return true;
        case _StatusFilter.needsFollowUp:
          return _needsFollowUp(lead);
        default:
          return lead.status == _statusFilter.name;
      }
    }).toList();
  }

  Future<void> _generate() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return;
    final handle = normalizeInstagramHandle(raw);
    if (handle.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _duplicateLead = null;
      _generatedLead = null;
    });

    try {
      final repository = ref.read(internLeadsRepositoryProvider);
      final existing = await repository.fetch(handle);
      if (existing != null) {
        setState(() => _duplicateLead = existing);
        return;
      }

      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) return;

      final config = await ref.read(outreachConfigProvider.future);
      final customTemplate = config?['messageTemplate'] as String?;
      final template = _pickRandom([
        ..._messageTemplates,
        if (customTemplate != null && customTemplate.trim().isNotEmpty)
          customTemplate,
      ]);
      final link = '$_linkBaseUrl$handle';
      final message = template.replaceAll('{{link}}', link);
      final comment = _pickRandom(_outreachComments);

      await repository.create(
        handle: handle,
        instagramUrl: raw,
        internId: user.uid,
        internEmail: user.email ?? '',
        message: message,
        comment: comment,
      );

      setState(() {
        _generatedLead = (
          handle: handle,
          instagramUrl: raw,
          internId: user.uid,
          internEmail: user.email ?? '',
          message: message,
          comment: comment,
          status: 'linkGenerated',
          createdAt: DateTime.now(),
          clickedAt: null,
          clickCount: 0,
          matchedUid: null,
          signedUpAt: null,
          onboardingCompleteAt: null,
          internConfirmedSent: false,
          internConfirmedSentAt: null,
          lastFollowUpSentAt: null,
          followUpCount: 0,
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
    final myLeads = ref.watch(myLeadsProvider).value ?? const <Lead>[];
    final signedUpCount = myLeads
        .where(
          (l) => l.status == 'signedUp' || l.status == 'onboardingComplete',
        )
        .length;
    final onboardedCount = myLeads
        .where((l) => l.status == 'onboardingComplete')
        .length;
    final filteredLeads = _filterLeads(myLeads);

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final newLinksSentTodayCount = myLeads
        .where((l) => l.createdAt != null && !l.createdAt!.isBefore(todayStart))
        .length;
    final followUpsSentTodayCount = myLeads
        .where(
          (l) =>
              l.lastFollowUpSentAt != null &&
              !l.lastFollowUpSentAt!.isBefore(todayStart),
        )
        .length;
    // Follow-ups count toward the same daily 200-message target as new
    // links — both are a DM the intern actually sent today.
    final sentTodayCount = newLinksSentTodayCount + followUpsSentTodayCount;
    final activeSecondsToday =
        ref.watch(myShiftActiveSecondsTodayProvider).value ?? 0;
    final customFollowUpTemplate =
        ref.watch(outreachConfigProvider).value?['followUpMessageTemplate']
            as String?;
    final followUpTemplatePool = [
      ..._followUpMessageTemplates,
      if (customFollowUpTemplate != null &&
          customFollowUpTemplate.trim().isNotEmpty)
        customFollowUpTemplate,
    ];

    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;
    final shiftSidebar = _ShiftSidebar(
      sentToday: sentTodayCount,
      activeSecondsToday: activeSecondsToday,
    );

    final mainContent = SingleChildScrollView(
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
                      'Paste an Instagram profile above to '
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
                      for (final (index, lead) in filteredLeads.indexed)
                        StaggeredFadeIn(
                          key: ValueKey(lead.handle),
                          delay: Duration(
                            milliseconds: (index * 40).clamp(0, 400),
                          ),
                          child: _LeadRow(
                            lead: lead,
                            followUpTemplatePool: followUpTemplatePool,
                          ),
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );

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
          Expanded(
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                        ),
                        child: SizedBox(
                          width: 240,
                          child: SingleChildScrollView(child: shiftSidebar),
                        ),
                      ),
                      Expanded(child: mainContent),
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          AppSpacing.md,
                          AppSpacing.screenHorizontal,
                          0,
                        ),
                        child: shiftSidebar,
                      ),
                      Expanded(child: mainContent),
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
                          'Outreach Tool',
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

/// Today's shift, against the 4h / 200-message targets — pinned to the
/// left of the page (see `_InternHomeScreenState.build`). Hours only
/// accrue while this tab is actually focused (see
/// `_InternHomeScreenState.didChangeAppLifecycleState`), so this reflects
/// real time spent working the tool, not just time signed in.
class _ShiftSidebar extends StatelessWidget {
  const _ShiftSidebar({
    required this.sentToday,
    required this.activeSecondsToday,
  });

  final int sentToday;
  final int activeSecondsToday;

  @override
  Widget build(BuildContext context) {
    final hours = activeSecondsToday ~/ 3600;
    final minutes = (activeSecondsToday % 3600) ~/ 60;
    final hoursFraction = activeSecondsToday / (_shiftTargetHours * 3600);
    final messagesFraction = sentToday / _shiftMessageTarget;
    final remaining = (_shiftMessageTarget - sentToday).clamp(
      0,
      _shiftMessageTarget,
    );
    final remainingFraction = remaining / _shiftMessageTarget;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Today's shift", style: AppTextStyles.titleSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          _ShiftRing(
            valueLabel: '${hours}h ${minutes}m',
            caption: 'of ${_shiftTargetHours}h shift',
            fraction: hoursFraction,
          ),
          const SizedBox(height: AppSpacing.md),
          _ShiftRing(
            valueLabel: '$sentToday',
            caption: 'of $_shiftMessageTarget sent',
            fraction: messagesFraction,
          ),
          const SizedBox(height: AppSpacing.md),
          _ShiftRing(
            valueLabel: '$remaining',
            caption: 'remaining to send',
            fraction: remainingFraction,
          ),
        ],
      ),
    );
  }
}

class _ShiftRing extends StatelessWidget {
  const _ShiftRing({
    required this.valueLabel,
    required this.caption,
    required this.fraction,
  });

  final String valueLabel;
  final String caption;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: CircularProgressIndicator(
                  value: fraction.clamp(0.0, 1.0),
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              Text(
                valueLabel,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
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
  final Lead? duplicateLead;
  final Lead? generatedLead;
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
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Text(
                  'Paste an Instagram profile',
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
            hintText: 'https://instagram.com/username',
            prefixIcon: const Icon(
              Icons.alternate_email,
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
              key: ValueKey(generatedLead!.handle),
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

  final Lead lead;

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
                  '@${lead.handle} was contacted by ${lead.internEmail} on '
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

/// Shows the generated message with its Copy button available right
/// away. Copying it starts a [_commentRevealDelay] countdown — enough
/// time to actually paste and send the DM in Instagram — before a second
/// step appears: a short comment to also leave on the creator's
/// post/profile. Copying *that* starts another countdown
/// ([_completeRevealDelay]) before the "Mark as sent" button unlocks.
/// This can't verify the DM or comment actually went out on Instagram —
/// nothing outside Instagram's own systems can — but it forces a
/// realistic minimum pace per lead and turns "did nothing" into an
/// explicit, checkable claim instead of silence. See
/// `intern_leads_providers.dart`'s `confirmSent` and the matching
/// `firestore.rules` block for the one-way false→true write.
class _SuccessCard extends ConsumerStatefulWidget {
  const _SuccessCard({
    super.key,
    required this.lead,
    required this.justCopied,
    required this.onCopy,
  });

  final Lead lead;
  final bool justCopied;
  final VoidCallback onCopy;

  @override
  ConsumerState<_SuccessCard> createState() => _SuccessCardState();
}

class _SuccessCardState extends ConsumerState<_SuccessCard> {
  Timer? _commentTicker;
  Timer? _completeTicker;
  int _secondsSinceMessageCopied = 0;
  int _secondsSinceCommentCopied = 0;
  bool _messageCopied = false;
  bool _commentCopied = false;
  bool _justCopiedComment = false;
  bool _isConfirming = false;
  late bool _confirmed = widget.lead.internConfirmedSent;

  bool get _showCommentSection =>
      _messageCopied &&
      _secondsSinceMessageCopied >= _commentRevealDelay.inSeconds;
  bool get _showCompleteButton =>
      _commentCopied &&
      _secondsSinceCommentCopied >= _completeRevealDelay.inSeconds;

  @override
  void dispose() {
    _commentTicker?.cancel();
    _completeTicker?.cancel();
    super.dispose();
  }

  void _handleCopyMessage() {
    widget.onCopy();
    if (_messageCopied) return;
    setState(() => _messageCopied = true);
    _commentTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsSinceMessageCopied++);
    });
  }

  Future<void> _handleCopyComment() async {
    await Clipboard.setData(ClipboardData(text: widget.lead.comment));
    if (!mounted) return;
    setState(() => _justCopiedComment = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justCopiedComment = false);
    });
    if (_commentCopied) return;
    setState(() => _commentCopied = true);
    _completeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsSinceCommentCopied++);
    });
  }

  Future<void> _confirmSent() async {
    setState(() => _isConfirming = true);
    try {
      await ref
          .read(internLeadsRepositoryProvider)
          .confirmSent(widget.lead.handle);
      if (!mounted) return;
      setState(() {
        _confirmed = true;
        _isConfirming = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      AppSnackbar.showError(context, "Couldn't confirm. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentSecondsLeft =
        _commentRevealDelay.inSeconds - _secondsSinceMessageCopied;
    final completeSecondsLeft =
        _completeRevealDelay.inSeconds - _secondsSinceCommentCopied;

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
          Text('1. Send this as a DM', style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm + 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: SelectableText(
              widget.lead.message,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _handleCopyMessage,
              icon: Icon(
                widget.justCopied ? Icons.check : Icons.copy,
                size: 16,
                color: widget.justCopied ? AppColors.success : null,
              ),
              label: Text(widget.justCopied ? 'Copied!' : 'Copy message'),
              style: widget.justCopied
                  ? OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    )
                  : null,
            ),
          ),
          if (_messageCopied && !_showCommentSection) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Go send that DM — the comment step unlocks in ${commentSecondsLeft}s',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
          if (_showCommentSection) ...[
            const SizedBox(height: AppSpacing.md),
            Text('2. Also leave this comment', style: AppTextStyles.labelLarge),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: SelectableText(
                widget.lead.comment,
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _handleCopyComment,
                icon: Icon(
                  _justCopiedComment ? Icons.check : Icons.copy,
                  size: 16,
                  color: _justCopiedComment ? AppColors.success : null,
                ),
                label: Text(_justCopiedComment ? 'Copied!' : 'Copy comment'),
                style: _justCopiedComment
                    ? OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                      )
                    : null,
              ),
            ),
          ],
          if (_commentCopied && !_showCompleteButton) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Post that comment too, then confirm in ${completeSecondsLeft}s',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
          if (_showCompleteButton) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: _confirmed
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      label: const Text('Marked as sent'),
                      style: OutlinedButton.styleFrom(
                        disabledForegroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                      ),
                    )
                  : PrimaryButton(
                      text: "I've sent this on Instagram",
                      icon: Icons.task_alt_outlined,
                      isLoading: _isConfirming,
                      onPressed: _confirmSent,
                    ),
            ),
          ],
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

class _FollowUpBadge extends StatelessWidget {
  const _FollowUpBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            size: 13,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            'Follow up',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.warning,
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
  const _LeadRow({required this.lead, required this.followUpTemplatePool});

  final Lead lead;
  final List<String> followUpTemplatePool;

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
                        '@${lead.handle}',
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
                if (_needsFollowUp(lead)) ...[
                  const _FollowUpBadge(),
                  const SizedBox(width: 6),
                ],
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
                      if (_needsFollowUp(lead)) ...[
                        const SizedBox(height: AppSpacing.sm + 4),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: AppSpacing.sm + 4),
                        _FollowUpFlow(
                          key: ValueKey('${lead.handle}-followup'),
                          lead: lead,
                          link: link,
                          templatePool: widget.followUpTemplatePool,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// The follow-up send flow for a lead sitting in the "Needs follow-up"
/// bucket — simpler than `_SuccessCard`'s first-touch flow: no comment
/// step, just copy the follow-up message, wait [_followUpConfirmDelay],
/// then log it via `logFollowUp`. Not proof anything was actually sent
/// (same caveat as `internConfirmedSent`), but it's a checkable claim.
class _FollowUpFlow extends ConsumerStatefulWidget {
  const _FollowUpFlow({
    super.key,
    required this.lead,
    required this.link,
    required this.templatePool,
  });

  final Lead lead;
  final String link;
  final List<String> templatePool;

  @override
  ConsumerState<_FollowUpFlow> createState() => _FollowUpFlowState();
}

class _FollowUpFlowState extends ConsumerState<_FollowUpFlow> {
  Timer? _ticker;
  int _secondsSinceCopied = 0;
  bool _copied = false;
  bool _isLogging = false;

  // Picked once when this row's follow-up flow first mounts, not on every
  // rebuild — otherwise the text would jump around mid-copy.
  late final String _message = _pickRandom(
    widget.templatePool,
  ).replaceAll('{{link}}', widget.link);

  bool get _showLogButton =>
      _copied && _secondsSinceCopied >= _followUpConfirmDelay.inSeconds;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: _message));
    if (!mounted) return;
    if (!_copied) {
      setState(() => _copied = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _secondsSinceCopied++);
      });
    }
    AppSnackbar.showSuccess(context, 'Follow-up message copied.');
  }

  Future<void> _logFollowUp() async {
    setState(() => _isLogging = true);
    try {
      await ref
          .read(internLeadsRepositoryProvider)
          .logFollowUp(widget.lead.handle);
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Follow-up logged.');
    } catch (error) {
      debugPrint('logFollowUp failed for ${widget.lead.handle}: $error');
      if (!mounted) return;
      AppSnackbar.showError(context, "Couldn't log the follow-up.");
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _followUpConfirmDelay.inSeconds - _secondsSinceCopied;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 14,
              color: AppColors.warning,
            ),
            const SizedBox(width: 4),
            Text('Follow-up message', style: AppTextStyles.labelSmall),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: SelectableText(
            _message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!_showLogButton) ...[
          OutlinedButton.icon(
            onPressed: _handleCopy,
            icon: const Icon(Icons.copy, size: 16),
            label: Text(_copied ? 'Copy again' : 'Copy follow-up message'),
          ),
          if (_copied) ...[
            const SizedBox(height: 4),
            Text(
              'Go send it on Instagram — logging unlocks in ${remaining}s.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ] else
          PrimaryButton(
            text: "I've sent this follow-up",
            isLoading: _isLogging,
            onPressed: _isLogging ? null : _logFollowUp,
          ),
        if (widget.lead.lastFollowUpSentAt != null) ...[
          const SizedBox(height: 4),
          Text(
            'Last followed up ${_relativeTime(widget.lead.lastFollowUpSentAt)}'
            ' · ${widget.lead.followUpCount} total.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
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
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.labelSmall)),
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
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

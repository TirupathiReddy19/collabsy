import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/shared/auth_button.dart';
import '../../auth/shared/auth_header.dart';
import '../models/collaboration_preference.dart';
import '../models/creator_gender.dart';
import '../providers/creator_profile_providers.dart';
import 'widgets/gender_collaboration_fields.dart';

/// One-time gate for creator accounts that finished onboarding before
/// gender/collaboration-preference existed as required fields — the
/// router's redirect guard sends any creator whose `creatorProfiles` doc
/// is still missing either field here, ahead of everything else, the next
/// time they open the app. A brand-new signup never sees this screen at
/// all, since [CreatorDetailsScreen] already collects both up front.
class CreatorAdditionalDetailsScreen extends ConsumerStatefulWidget {
  const CreatorAdditionalDetailsScreen({super.key});

  @override
  ConsumerState<CreatorAdditionalDetailsScreen> createState() =>
      _CreatorAdditionalDetailsScreenState();
}

class _CreatorAdditionalDetailsScreenState
    extends ConsumerState<CreatorAdditionalDetailsScreen> {
  CreatorGender? _selectedGender;
  CollaborationPreference? _selectedCollabPreference;

  Future<void> _continue() async {
    if (_selectedGender == null) {
      AppSnackbar.showError(context, 'Select your gender');
      return;
    }
    if (_selectedCollabPreference == null) {
      AppSnackbar.showError(
        context,
        "Select what collaborations you're open to",
      );
      return;
    }

    await ref
        .read(creatorProfileControllerProvider.notifier)
        .updateProfile(
          gender: _selectedGender,
          collaborationPreference: _selectedCollabPreference,
        );
    if (!mounted) return;
    if (ref.read(creatorProfileControllerProvider).hasError) {
      AppSnackbar.showError(
        context,
        "Couldn't save your details. Please try again.",
      );
      return;
    }
    // Re-enters the router's redirect from the top rather than pushing
    // onward manually — same pattern CreatorInstagramConnectScreen uses to
    // hand off to whatever the profile now actually resolves to
    // (verification-pending, or straight to the dashboard for an already
    // -approved account).
    context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(creatorProfileControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(
                title: 'Just two more questions',
                subtitle: "We've added a couple of new fields since you "
                    'joined — help brands find you better.',
              ),
              const SizedBox(height: 24),
              GenderCollaborationFields(
                selectedGender: _selectedGender,
                selectedPreference: _selectedCollabPreference,
                enabled: !isLoading,
                onGenderChanged: (value) =>
                    setState(() => _selectedGender = value),
                onPreferenceChanged: (value) =>
                    setState(() => _selectedCollabPreference = value),
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: 'Continue',
                onPressed: isLoading ? null : _continue,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

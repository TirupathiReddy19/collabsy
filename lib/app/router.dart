import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/firebase_service.dart';
import '../core/services/local_storage_service.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/brand/data/brand_profile_repository.dart';
import '../features/creator/data/creator_profile_repository.dart';
import '../features/announcements/screens/announcements_screen.dart';
import '../features/auth/complete_profile/complete_profile_screen.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/mfa/mfa_challenge_screen.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/auth/shared/check_email_screen.dart';
import '../features/auth/shared/otp_verification_view.dart';
import '../features/auth/shared/suspended_screen.dart';
import '../features/auth/shared/terms_gate_screen.dart';
import '../features/auth/signup/signup_screen.dart';
import '../features/auth/forgot_password/forgot_password_screen.dart';
import '../features/blocking/screens/blocked_accounts_screen.dart';
import '../features/brand/campaigns/brand_campaign_detail_screen.dart';
import '../features/brand/campaigns/create_campaign_screen.dart';
import '../features/brand/discover/creator_public_profile_screen.dart';
import '../shared/models/verification_status.dart';
import '../features/brand/onboarding/brand_details_screen.dart';
import '../features/brand/onboarding/brand_verification_pending_screen.dart';
import '../features/brand/providers/brand_profile_providers.dart';
import '../features/brand/screens/brand_account_screen.dart';
import '../features/brand/screens/brand_campaigns_screen.dart';
import '../features/brand/screens/brand_discover_screen.dart';
import '../features/brand/screens/brand_home_screen.dart';
import '../features/brand/screens/brand_messages_screen.dart';
import '../features/chat/screens/chat_conversation_screen.dart';
import '../features/creator/campaigns/brand_public_profile_screen.dart';
import '../features/creator/campaigns/creator_campaign_detail_screen.dart';
import '../features/creator/onboarding/creator_additional_details_screen.dart';
import '../features/creator/onboarding/creator_details_screen.dart';
import '../features/creator/onboarding/creator_instagram_connect_screen.dart';
import '../features/creator/onboarding/creator_verification_pending_screen.dart';
import '../features/creator/providers/creator_profile_providers.dart';
import '../features/creator/screens/creator_campaigns_screen.dart';
import '../features/creator/screens/creator_home_screen.dart';
import '../features/creator/screens/creator_messages_screen.dart';
import '../features/creator/screens/creator_profile_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/settings/screens/connected_accounts_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/support/screens/support_chat_screen.dart';
import '../features/support/screens/support_help_screen.dart';
import '../features/support/screens/support_ticket_history_screen.dart';
import '../shared/models/user_role.dart';
import 'app_shell.dart';
import 'router_refresh_stream.dart';
import 'routes.dart';

/// Everything the redirect callback does once it knows the account needs
/// role/verification/onboarding resolved — pulled out into its own
/// function purely so the try/catch around it (see the call site) wraps
/// one call instead of needing to be threaded through every `await`
/// inside this logic individually.
Future<String?> _resolvePostAuthRedirect({
  required Ref ref,
  required AuthRepository authRepository,
  required BrandProfileRepository brandProfileRepository,
  required CreatorProfileRepository creatorProfileRepository,
  required User user,
  required String location,
  required bool atCompleteProfile,
  required bool atSuspended,
  required bool atTermsGate,
  required bool atCreatorOnboarding,
  required bool atBrandOnboarding,
}) async {
  final profile = await authRepository.fetchProfile(user.uid);
  ref.invalidate(currentProfileProvider);
  if (profile?.role == null) {
    // No role yet (fresh Google sign-in never asked for one) — send
    // them to fill in the missing role + phone.
    return atCompleteProfile ? null : AppRoutes.completeProfile;
  }
  if (profile!.suspended) {
    // Sign-in itself is still allowed for a suspended account (see
    // suspendUserAccount) — this is what actually locks them out,
    // ahead of every other gate below, so a suspended account never
    // gets as far as re-accepting terms or finishing onboarding.
    return atSuspended ? null : AppRoutes.suspended;
  }
  if (profile.termsAcceptedAt == null) {
    // Every brand-new signup lands here right after their role is
    // known, before any onboarding step — and since nothing ever set
    // this field before the gate existed, every pre-existing account
    // lands here too, exactly once, the next time they open the app.
    return atTermsGate ? null : AppRoutes.termsGate;
  }
  if (profile.role == UserRole.creator && !profile.onboardingCompleted) {
    // Creator role set but hasn't finished the languages/location +
    // Instagram-connect steps yet — Instagram connect is required
    // (not skippable), since verification below needs real data.
    return atCreatorOnboarding ? null : AppRoutes.creatorDetails;
  }
  if (profile.role == UserRole.brand && !profile.onboardingCompleted) {
    // Brand role set but hasn't filled in company details yet —
    // also catches every pre-existing Brand account, since nothing
    // ever set this flag true for them before this step existed.
    return atBrandOnboarding ? null : AppRoutes.brandDetails;
  }
  if (profile.role == UserRole.brand) {
    // Onboarding is done, but the dashboard is still gated on admin
    // approval. `verificationStatus` defaults to pending whenever
    // it's missing from Firestore, so this also catches every
    // pre-existing Brand account created before verification existed
    // — not just brand-new signups.
    final brandProfile = await brandProfileRepository.fetchBrandProfile(
      user.uid,
    );
    final verified =
        brandProfile?.verificationStatus == VerificationStatus.approved;
    if (!verified) {
      return location == AppRoutes.brandVerificationPending
          ? null
          : AppRoutes.brandVerificationPending;
    }
  }
  if (profile.role == UserRole.creator) {
    final creatorProfile = await creatorProfileRepository
        .fetchCreatorProfile(user.uid);
    // Gender/collaboration-preference didn't exist as required fields
    // when this creator's `onboardingCompleted` flag was first set, so
    // this is the same free retroactive catch as the onboarding gate
    // above — every pre-existing Creator account gets sent through this
    // once, before anything else, the next time they open the app. A
    // brand-new signup never sees it: CreatorDetailsScreen already
    // collects both up front, ahead of onboardingCompleted flipping true.
    final needsAdditionalDetails =
        creatorProfile?.gender == null ||
        creatorProfile?.collaborationPreference == null;
    if (needsAdditionalDetails) {
      return location == AppRoutes.creatorAdditionalDetails
          ? null
          : AppRoutes.creatorAdditionalDetails;
    }
    // Onboarding is done, but the dashboard is still gated on admin
    // approval — same reasoning as the Brand gate above, and the
    // same free retroactive catch for every pre-existing Creator
    // account.
    final verified =
        creatorProfile?.verificationStatus == VerificationStatus.approved;
    if (!verified) {
      return location == AppRoutes.creatorVerificationPending
          ? null
          : AppRoutes.creatorVerificationPending;
    }
  }
  return profile.role == UserRole.creator
      ? AppRoutes.creatorHome
      : AppRoutes.brandHome;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final analytics = ref.watch(firebaseAnalyticsProvider);
  final brandProfileRepository = ref.watch(brandProfileRepositoryProvider);
  final creatorProfileRepository = ref.watch(creatorProfileRepositoryProvider);

  final refreshStream = GoRouterRefreshStream(authRepository.authStateChanges);
  // `currentProfileWatchProvider` is a genuine Firestore listener (unlike
  // the one-shot `currentProfileProvider`) — `ref.listen` (not `watch`)
  // bridges its every emission into a `redirect()` re-evaluation without
  // making this whole provider — and the GoRouter it builds — rebuild
  // every time the doc changes. This is what lets an admin suspending the
  // account interrupt an already-open session within moments, rather than
  // only being caught the next time this user hits splash/onboarding/auth.
  ref.listen(currentProfileWatchProvider, (previous, next) {
    refreshStream.refresh();
  });
  // Same bridge for the verification-approval gate below — lets an admin's
  // approve/reject decision move an already-open session off the pending
  // screen (or, just as importantly, re-lock a not-yet-approved session out
  // of the dashboard) within moments, not just on the next app open.
  ref.listen(ownCreatorProfileStreamProvider, (previous, next) {
    refreshStream.refresh();
  });
  ref.listen(ownBrandProfileStreamProvider, (previous, next) {
    refreshStream.refresh();
  });

  return GoRouter(
    initialLocation: AppRoutes.splash,
    observers: [FirebaseAnalyticsObserver(analytics: analytics)],
    refreshListenable: refreshStream,
    redirect: (context, state) async {
      final location = state.matchedLocation;
      final atSplash = location == AppRoutes.splash;
      final atOnboarding = location == AppRoutes.onboarding;
      final atOtp = location == AppRoutes.otp;
      final atCompleteProfile = location == AppRoutes.completeProfile;
      final atCheckEmail = location == AppRoutes.checkEmail;
      final atTermsGate = location == AppRoutes.termsGate;
      final atSuspended = location == AppRoutes.suspended;
      final atAuth = location.startsWith('/auth');
      final atCreatorOnboarding = location.startsWith('/creator/onboarding');
      final atBrandOnboarding = location.startsWith('/brand/onboarding');
      final atCreatorVerificationPending =
          location == AppRoutes.creatorVerificationPending;
      final atBrandVerificationPending =
          location == AppRoutes.brandVerificationPending;

      // Splash decides nothing itself — it always lands here first and the
      // guard below sends it wherever it actually needs to go.
      if (atSplash) return null;

      if (!localStorage.hasSeenOnboarding) {
        return atOnboarding ? null : AppRoutes.onboarding;
      }

      final user = authRepository.currentUser;
      final loggedIn = user != null;

      // Live check, ahead of everything else — catches an admin suspending
      // this account while it's already mid-session somewhere deep in the
      // app (a shell tab, a chat, settings), not just at sign-in. Backed by
      // currentProfileWatchProvider's Firestore listener via the
      // ref.listen bridge above, so this is a cheap synchronous read, not
      // a fresh fetch on every navigation.
      if (loggedIn) {
        final liveSuspended =
            ref.read(currentProfileWatchProvider).value?.suspended ?? false;
        if (liveSuspended && !atSuspended) {
          return AppRoutes.suspended;
        }

        // Live approval gate — unlike the one-time check further below
        // (which only runs right as someone finishes onboarding), this
        // re-applies on every navigation so a creator/brand who already
        // finished onboarding once can't just reopen the app and land on
        // their dashboard while still pending admin review. Reads the
        // live stream's cached value rather than awaiting it, so an
        // unresolved first load (`hasValue == false`) is treated as "don't
        // know yet" and left to the checks below rather than bounced to
        // the pending screen.
        final liveProfile = ref.read(currentProfileWatchProvider).value;
        final exemptFromVerificationGate =
            atOnboarding ||
            atAuth ||
            atCompleteProfile ||
            atCheckEmail ||
            atTermsGate ||
            atOtp ||
            atCreatorOnboarding ||
            atBrandOnboarding ||
            atCreatorVerificationPending ||
            atBrandVerificationPending;
        if (!exemptFromVerificationGate &&
            liveProfile != null &&
            liveProfile.onboardingCompleted) {
          if (liveProfile.role == UserRole.brand) {
            final brandStream = ref.read(ownBrandProfileStreamProvider);
            if (brandStream.hasValue) {
              final approved =
                  brandStream.value?.verificationStatus ==
                  VerificationStatus.approved;
              if (!approved) return AppRoutes.brandVerificationPending;
            }
          }
          if (liveProfile.role == UserRole.creator) {
            final creatorStream = ref.read(ownCreatorProfileStreamProvider);
            if (creatorStream.hasValue) {
              final approved =
                  creatorStream.value?.verificationStatus ==
                  VerificationStatus.approved;
              if (!approved) return AppRoutes.creatorVerificationPending;
            }
          }
        }
      }

      if (!loggedIn) {
        // completeProfile/checkEmail require a session (they're post-auth
        // screens that just happen to live under /auth) — everything else
        // under /auth is a legitimate pre-auth screen and gets left alone.
        if (atCompleteProfile || atCheckEmail) return AppRoutes.login;
        return atAuth ? null : AppRoutes.login;
      }

      // The OTP screen manages its own next step (verify -> set role ->
      // go to splash) — never interrupt it mid-flow.
      if (atOtp) return null;

      // Firebase signs a user in immediately on signUpWithPassword, before
      // their email is verified — unlike Google sign-ins, which have no
      // password provider and are always considered verified. Hold
      // unverified email/password users on checkEmail until they confirm.
      //
      // A phone-first account adding an email (CompleteProfileScreen's
      // `_alreadyVerifiedPhone` case) has no `password` provider either, so
      // it needs its own signal — `verifyBeforeUpdateEmail` deliberately
      // leaves `user.email`/`emailVerified` untouched until the link is
      // clicked, so there's nothing on `user` itself to gate on; the local
      // cache set right before that email was sent is the only signal.
      final hasPasswordProvider = user.providerData.any(
        (p) => p.providerId == 'password',
      );
      final hasPendingPhoneEmail =
          localStorage.pendingPhoneEmailVerification != null;
      if ((hasPasswordProvider || hasPendingPhoneEmail) &&
          !user.emailVerified &&
          !atSuspended) {
        return atCheckEmail ? null : AppRoutes.checkEmail;
      }

      // Logged in but sitting on onboarding/auth/creator-onboarding (e.g. a
      // relaunch that restored a session, a Google sign-in that just landed
      // back on the login screen, or finishing/skipping the creator-details
      // step) — figure out where they actually belong.
      //
      // Deliberately fetched fresh here rather than via
      // ref.read(currentProfileProvider.future): that provider and this
      // router's own refreshListenable are two independent listeners on
      // the same auth-state stream, with no guaranteed ordering between
      // them. Reading the cached provider risked catching a stale
      // snapshot from a half-processed sign-out (e.g. right after a
      // sign-out+sign-in, briefly still reflecting "no user") and
      // wrongly concluding a role-having account had none.
      if (atOnboarding || atAuth || atCreatorOnboarding || atBrandOnboarding) {
        // Every branch below awaits a one-shot Firestore `.get()` (fresh
        // reads, deliberately not the cached stream providers — see the
        // comment above this block). Firestore throws `[unavailable]`
        // rather than falling back to cache for these when the device has
        // no network right at this instant, and go_router doesn't catch
        // exceptions thrown from `redirect` — an uncaught one here crashes
        // the entire app (seen in production Crashlytics: OnePlus/Android
        // 11, `cloud_firestore/unavailable`). Staying put and retrying on
        // the next redirect evaluation (auth state change, connectivity
        // restored, manual retry) is far better than a hard crash.
        try {
          return await _resolvePostAuthRedirect(
            ref: ref,
            authRepository: authRepository,
            brandProfileRepository: brandProfileRepository,
            creatorProfileRepository: creatorProfileRepository,
            user: user,
            location: location,
            atCompleteProfile: atCompleteProfile,
            atSuspended: atSuspended,
            atTermsGate: atTermsGate,
            atCreatorOnboarding: atCreatorOnboarding,
            atBrandOnboarding: atBrandOnboarding,
          );
        } catch (_) {
          return null;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpVerificationView(),
      ),
      GoRoute(
        path: AppRoutes.mfaChallenge,
        builder: (context, state) => const MfaChallengeScreen(),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkEmail,
        builder: (context, state) => const CheckEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsGate,
        builder: (context, state) => const TermsGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.suspended,
        builder: (context, state) => const SuspendedScreen(),
      ),
      GoRoute(
        path: AppRoutes.creatorDetails,
        builder: (context, state) => const CreatorDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.creatorInstagramConnect,
        builder: (context, state) => const CreatorInstagramConnectScreen(),
      ),
      GoRoute(
        path: AppRoutes.creatorAdditionalDetails,
        builder: (context, state) => const CreatorAdditionalDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.creatorVerificationPending,
        builder: (context, state) => const CreatorVerificationPendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.brandDetails,
        builder: (context, state) => const BrandDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.brandVerificationPending,
        builder: (context, state) => const BrandVerificationPendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.createCampaign,
        builder: (context, state) => const CreateCampaignScreen(),
      ),
      GoRoute(
        path: AppRoutes.brandCampaignDetail,
        builder: (context, state) => BrandCampaignDetailScreen(
          campaignId: state.pathParameters['campaignId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.creatorCampaignDetail,
        builder: (context, state) => CreatorCampaignDetailScreen(
          campaignId: state.pathParameters['campaignId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.creatorPublicProfile,
        builder: (context, state) => CreatorPublicProfileScreen(
          creatorId: state.pathParameters['creatorId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.brandPublicProfile,
        builder: (context, state) =>
            BrandPublicProfileScreen(brandId: state.pathParameters['brandId']!),
      ),
      GoRoute(
        path: AppRoutes.chatDetail,
        builder: (context, state) =>
            ChatConversationScreen(chatId: state.pathParameters['chatId']!),
      ),
      GoRoute(
        path: AppRoutes.announcements,
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.connectedAccounts,
        builder: (context, state) => const ConnectedAccountsScreen(),
      ),
      GoRoute(
        path: AppRoutes.blockedAccounts,
        builder: (context, state) => const BlockedAccountsScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportHelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.supportHistory,
        builder: (context, state) => const SupportTicketHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.supportChat,
        builder: (context, state) =>
            SupportChatScreen(ticketId: state.pathParameters['ticketId']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            CreatorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.creatorHome,
                builder: (context, state) => const CreatorHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.creatorCampaigns,
                builder: (context, state) => const CreatorCampaignsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.creatorMessages,
                builder: (context, state) => const CreatorMessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.creatorProfile,
                builder: (context, state) => const CreatorProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BrandShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.brandHome,
                builder: (context, state) => const BrandHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.brandCampaigns,
                builder: (context, state) => const BrandCampaignsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.brandDiscover,
                builder: (context, state) => const BrandDiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.brandMessages,
                builder: (context, state) => const BrandMessagesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.brandAccount,
                builder: (context, state) => const BrandAccountScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          "Page Not Found",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
});

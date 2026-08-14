import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/legal_text.dart';
import '../widgets/website_section.dart';

/// Ported verbatim from `web-legal/privacy/index.html` (the same copy
/// linked from the app's Settings and Terms Gate screens) — restyled to
/// match the website, not reworded.
class WebsitePrivacyScreen extends StatelessWidget {
  const WebsitePrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebsiteSection(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privacy Policy', style: AppTextStyles.displayMedium),
          const SizedBox(height: 4),
          Text(
            'Effective August 4, 2026',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LegalP([
            legalText(
              'Collabsy connects Creators and Brands for influencer '
              'marketing campaigns. This policy explains what information '
              'we collect through the Collabsy mobile app, why we collect '
              'it, who we share it with, and the choices you have.',
            ),
          ]),
          const LegalH2('1. Information we collect'),
          LegalP([
            legalBold('Account information. '),
            legalText(
              'Your phone number (used to sign in), and — if you provide '
              'one — your email address and password. We never see or '
              'store your password in plain text; Firebase Authentication '
              'handles it for us in hashed form.',
            ),
          ]),
          LegalP([
            legalBold('Profile information. '),
            legalText(
              'Your display name, profile photo, city and state, and role '
              '(Creator or Brand). Creators can add a bio, content '
              'categories, and languages. Brands can add a company name, '
              'designation, website, and LinkedIn URL.',
            ),
          ]),
          LegalP([
            legalBold('Instagram data. '),
            legalText(
              'If you connect your Instagram Business account, we receive '
              'your Instagram username, name, profile photo, follower '
              "count, and recent media directly from Instagram's official "
              'API. We only request this when you choose to connect it, '
              'and it\'s shown to Brands considering you for a campaign — '
              'the same way it would be if they viewed your Instagram '
              'profile directly.',
            ),
          ]),
          LegalP([
            legalBold('Campaigns and messages. '),
            legalText(
              'Campaign listings you post or apply to, your application '
              'status, and the messages you exchange with other users '
              'inside the app.',
            ),
          ]),
          LegalP([
            legalBold('Support requests. '),
            legalText(
              'Anything you send us when you contact support, including '
              'messages in an in-app support chat.',
            ),
          ]),
          LegalP([
            legalBold('Reports and blocks. '),
            legalText(
              'If you report or block another user, we keep a record of '
              'that action so we can review it and enforce our Terms.',
            ),
          ]),
          LegalP([
            legalBold('Usage and device data. '),
            legalText(
              'Basic app analytics and crash reports (via Firebase '
              'Analytics and Crashlytics), and a push notification token '
              'so we can deliver notifications to your device.',
            ),
          ]),
          const LegalH2("2. What we don't collect"),
          LegalBullets([
            [
              legalBold('No precise location. '),
              legalText(
                "City and state are typed by you — we never access your "
                "device's GPS location.",
              ),
            ],
            [
              legalBold('No payment information. '),
              legalText(
                "Collabsy doesn't process payments between Creators and "
                "Brands or store any financial details.",
              ),
            ],
            [
              legalBold('No advertising tracking. '),
              legalText(
                "We don't run ads and don't use advertising identifiers to "
                'track you across other apps.',
              ),
            ],
          ]),
          const LegalH2('3. How we use your information'),
          LegalBullets([
            [
              legalText(
                'Operate discovery, applications, and messaging between '
                'Creators and Brands',
              ),
            ],
            [
              legalText(
                'Verify Creator and Brand accounts before they\'re '
                'publicly visible',
              ),
            ],
            [
              legalText(
                'Send you notifications about applications, messages, and '
                'campaigns',
              ),
            ],
            [legalText('Respond to support requests')],
            [legalText('Review reports and enforce our Terms of Service')],
            [
              legalText(
                'Understand how the app is used and fix problems, using '
                'aggregated analytics and crash data',
              ),
            ],
          ]),
          const LegalH2('4. Who we share it with'),
          LegalP([
            legalBold('The other side of the platform. '),
            legalText(
              'Sharing profile information between Creators and Brands is '
              'core to how Collabsy works — a Brand can see a '
              "Creator's profile and connected Instagram stats, and a "
              "Creator can see a Brand's profile, the same way each would "
              'if they were reviewing an application or a campaign listing '
              'directly.',
            ),
          ]),
          LegalP([
            legalBold('Service providers. '),
            legalText(
              'We use Firebase and Google Cloud for hosting, our database, '
              'authentication, analytics, crash reporting, and push '
              "notifications. If you connect Instagram, that connection "
              "is made directly with Meta's Instagram API.",
            ),
          ]),
          LegalP([
            legalBold('Legal reasons. '),
            legalText(
              "We may disclose information if required by law, or where "
              "we believe it's necessary to protect the rights, property, "
              'or safety of Collabsy, our users, or the public.',
            ),
          ]),
          LegalP([legalBold('We never sell your personal information.')]),
          const LegalH2('5. Your choices'),
          LegalBullets([
            [
              legalBold('Delete your account '),
              legalText(
                'any time from Settings → Danger Zone → Delete Account. '
                'This permanently removes your profile. Campaigns, '
                'applications, and messages you were part of may remain '
                'visible to the other participant, the same way a message '
                "stays in someone else's inbox after you delete your own "
                'account elsewhere.',
              ),
            ],
            [
              legalBold('Block or unblock other users '),
              legalText('from Settings → Privacy & Safety.'),
            ],
            [
              legalBold('Turn push notifications on or off '),
              legalText('from Settings.'),
            ],
            [
              legalBold('Disconnect Instagram '),
              legalText('any time from Settings → Connected Accounts.'),
            ],
          ]),
          const LegalH2('6. How long we keep your data'),
          LegalP([
            legalText(
              'We keep your information while your account is active. '
              'When you delete your account, we delete your profile and '
              'personal data, with the exception described above for '
              'messages and campaign records that other users are still '
              'part of.',
            ),
          ]),
          const LegalH2("7. Children's privacy"),
          LegalP([
            legalText(
              'Collabsy is a professional platform for Creators and '
              'Brands and is not directed at, or intended for use by, '
              'anyone under 18.',
            ),
          ]),
          const LegalH2('8. Security'),
          LegalP([
            legalText(
              "We use Firebase's security infrastructure, encrypted "
              'connections (HTTPS/TLS) for all traffic, and database rules '
              'that restrict exactly who can read or write each piece of '
              'data.',
            ),
          ]),
          const LegalH2('9. Changes to this policy'),
          LegalP([
            legalText(
              "If we make material changes to this policy, we'll update "
              'the effective date above and let you know in the app.',
            ),
          ]),
          const LegalH2('10. Contact us'),
          LegalP([
            legalText('Questions about this policy or your data? Email us at '),
            TextSpan(
              text: 'support@collabsy.online',
              style: AppTextStyles.link,
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    launchUrl(Uri.parse('mailto:support@collabsy.online')),
            ),
            legalText('.'),
          ]),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

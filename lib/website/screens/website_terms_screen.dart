import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/legal_text.dart';
import '../widgets/website_section.dart';

/// Ported verbatim from `web-legal/terms/index.html` (the same copy linked
/// from the app's Settings and Terms Gate screens) — restyled to match the
/// website, not reworded.
class WebsiteTermsScreen extends StatelessWidget {
  const WebsiteTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebsiteSection(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Terms of Service', style: AppTextStyles.displayMedium),
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
              'These Terms govern your use of Collabsy as a Creator or a '
              'Brand. By creating an account or using the app, you agree '
              'to them.',
            ),
          ]),
          const LegalH2('1. Eligibility'),
          LegalP([
            legalText(
              'You must be at least 18 years old to use Collabsy. If '
              "you're creating a Brand account on behalf of a company, you "
              'confirm you have the authority to represent that company '
              'and agree to these Terms on its behalf.',
            ),
          ]),
          const LegalH2('2. Your account'),
          LegalBullets([
            [
              legalText(
                'Provide accurate information when you sign up, and keep '
                'it up to date.',
              ),
            ],
            [
              legalText(
                "One account per person or company — don't create "
                "accounts to impersonate someone else or misrepresent "
                'your identity, follower count, or company.',
              ),
            ],
            [
              legalText(
                "You're responsible for anything that happens under your "
                'account, so keep your credentials secure.',
              ),
            ],
          ]),
          const LegalH2('3. Creator and Brand conduct'),
          LegalP([
            legalText(
              'Collabsy is a place for genuine collaboration. You agree '
              'not to:',
            ),
          ]),
          LegalBullets([
            [
              legalText(
                'Harass, threaten, or abuse other users in messages, '
                'profiles, or campaign listings',
              ),
            ],
            [
              legalText(
                "Post spam, illegal content, or content that infringes "
                "someone else's rights",
              ),
            ],
            [
              legalText(
                'Misrepresent your identity, your company, or your '
                'Instagram metrics',
              ),
            ],
            [
              legalText(
                "Attempt to circumvent our verification process or "
                "another user's block",
              ),
            ],
          ]),
          LegalP([
            legalText(
              'Report and Block tools are available on every profile and '
              'conversation. We review reports and, depending on '
              'severity, may remove content, warn an account, or suspend '
              'or terminate it — repeat violations lead to stronger '
              'action.',
            ),
          ]),
          const LegalH2('4. Campaigns between Creators and Brands'),
          LegalP([
            legalText(
              'Collabsy helps Creators and Brands discover each other, '
              'apply to campaigns, and communicate. Any agreement about '
              'deliverables, compensation, or timelines is between the '
              'Creator and the Brand directly — Collabsy is not a party '
              "to that agreement and doesn't guarantee payment, "
              'performance, or the outcome of any campaign.',
            ),
          ]),
          const LegalH2('5. Content you post'),
          LegalP([
            legalText(
              'You retain ownership of anything you post — your profile, '
              'campaign listings, and messages. By posting it, you grant '
              'Collabsy a license to display it within the app to the '
              "users it's meant for, which is what makes discovery and "
              "messaging work. You're responsible for having the rights "
              'to anything you upload.',
            ),
          ]),
          const LegalH2('6. Instagram and other connected accounts'),
          LegalP([
            legalText(
              'Connecting your Instagram Business account is optional. '
              "That connection is also governed by Meta's own terms, in "
              'addition to these. You can disconnect it at any time from '
              'Connected Accounts in Settings.',
            ),
          ]),
          const LegalH2('7. Ending your account'),
          LegalP([
            legalText(
              'You can delete your account at any time from Settings. We '
              'may suspend or terminate an account that violates these '
              'Terms or applicable law, with notice where practical.',
            ),
          ]),
          const LegalH2('8. Disclaimers'),
          LegalP([
            legalText(
              'Collabsy is provided "as is." We don\'t guarantee '
              'uninterrupted service, or the accuracy, quality, or '
              'outcome of any Creator profile, Brand listing, or '
              'campaign.',
            ),
          ]),
          const LegalH2('9. Limitation of liability'),
          LegalP([
            legalText(
              "To the extent permitted by law, Collabsy isn't liable for "
              'indirect, incidental, or consequential damages arising '
              'from your use of the app, or from agreements you enter '
              'into with another user through it.',
            ),
          ]),
          const LegalH2('10. Governing law'),
          LegalP([legalText('These Terms are governed by the laws of India.')]),
          const LegalH2('11. Changes to these Terms'),
          LegalP([
            legalText(
              'We may update these Terms from time to time. Continuing to '
              'use Collabsy after a change means you accept the updated '
              'Terms.',
            ),
          ]),
          const LegalH2('12. Contact us'),
          LegalP([
            legalText('Questions about these Terms? Email us at '),
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

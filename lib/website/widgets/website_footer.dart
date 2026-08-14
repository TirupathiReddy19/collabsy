import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_logo.dart';
import 'website_section.dart';

const _companyLinks = [
  ('Home', '/'),
  ('Creators', '/creators'),
  ('Brands', '/brands'),
  ('About', '/about'),
  ('Contact', '/contact'),
];

const _legalLinks = [
  ('Privacy Policy', '/privacy'),
  ('Terms of Service', '/terms'),
  ('Delete Account', '/delete-account'),
];

/// Site-wide footer — contact details match the Contact page exactly (same
/// WhatsApp number, email, city).
class WebsiteFooter extends StatelessWidget {
  const WebsiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.textPrimary,
      child: WebsiteSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 48,
              runSpacing: 32,
              children: [
                const SizedBox(width: 260, child: _BrandColumn()),
                SizedBox(
                  width: 160,
                  child: _LinkColumn(title: 'Company', links: _companyLinks),
                ),
                SizedBox(
                  width: 160,
                  child: _LinkColumn(title: 'Legal', links: _legalLinks),
                ),
                const SizedBox(width: 220, child: _ContactColumn()),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: AppSpacing.md),
            Text(
              '© ${DateTime.now().year} Collabsy. All rights reserved.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandColumn extends StatelessWidget {
  const _BrandColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(width: 17, height: 17, child: CollabsyMark()),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Collabsy',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Influencer marketing that connects Creators and Brands — built '
          'for real campaigns, not vanity metrics.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _LinkColumn extends StatelessWidget {
  const _LinkColumn({required this.title, required this.links});

  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        for (final (label, path) in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => context.go(path),
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
            ),
          ),
      ],
    );
  }
}

class _ContactColumn extends StatelessWidget {
  const _ContactColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Contact',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        _ContactLine(
          icon: Icons.mail_outline_rounded,
          text: 'hello@collabsy.online',
          onTap: () => launchUrl(Uri.parse('mailto:hello@collabsy.online')),
        ),
        const SizedBox(height: 8),
        _ContactLine(
          icon: Icons.chat_bubble_outline_rounded,
          text: '+91 93814 87811',
          onTap: () => launchUrl(Uri.parse('https://wa.me/919381487811')),
        ),
        const SizedBox(height: 8),
        const _ContactLine(
          icon: Icons.location_on_outlined,
          text: 'Bangalore, India',
        ),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/website_section.dart';
import '../widgets/website_section_heading.dart';

class WebsiteContactScreen extends StatelessWidget {
  const WebsiteContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebsiteSection(
      child: Column(
        children: [
          const WebsiteSectionHeading(
            title: 'Get in touch',
            subtitle:
                'Have a question, or want a campaign plan for your brand? '
                "Reach us any of these ways — or use the Brands page's "
                'form for a full campaign brief.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _ContactCard(
                icon: Icons.mail_outline_rounded,
                title: 'Email',
                value: 'hello@collabsy.online',
                onTap: () =>
                    launchUrl(Uri.parse('mailto:hello@collabsy.online')),
              ),
              _ContactCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'WhatsApp',
                value: '+91 93814 87811',
                onTap: () => launchUrl(Uri.parse('https://wa.me/919381487811')),
              ),
              const _ContactCard(
                icon: Icons.location_on_outlined,
                title: 'Based in',
                value: 'Bangalore, India',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.titleMedium),
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: card,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

const _waitlistPhone = '919381487811';
const _waitlistMessage =
    "Hi Collabsy! I'd like to join the waitlist for the app.";

/// "Get the app" CTA. The app isn't live on the Play Store / App Store yet
/// (confirmed with the team), so this opens a WhatsApp chat on the same
/// number the Contact page uses instead of a store link — swap for real
/// store badges once the app is published.
class WaitlistCtaButton extends StatelessWidget {
  const WaitlistCtaButton({super.key})
    : label = 'Join the App Waitlist',
      expanded = true;

  const WaitlistCtaButton.compact({super.key})
    : label = 'Get the App',
      expanded = false;

  final String label;
  final bool expanded;

  Future<void> _open() => launchUrl(
    Uri.parse(
      'https://wa.me/$_waitlistPhone?text=${Uri.encodeComponent(_waitlistMessage)}',
    ),
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: _open,
      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: Size(0, expanded ? 56 : 44),
        maximumSize: Size(double.infinity, expanded ? 56 : 44),
        padding: EdgeInsets.symmetric(horizontal: expanded ? 24 : 18),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: AppTextStyles.button.copyWith(fontSize: expanded ? 16 : 14),
      ),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

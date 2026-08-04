import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'instagram_icon.dart';
import 'whatsapp_icon.dart';

const _instagramUrl = 'https://www.instagram.com/collabsy_official/';
const _whatsappUrl = 'https://wa.me/919381487811';

/// Home-dashboard footer section — hero-style headline plus follow-us /
/// talk-to-us pill buttons, shown identically on both the Creator and
/// Brand portals. Deliberately not a `Card` — sits directly on the page.
class ContactLinksCard extends StatelessWidget {
  const ContactLinksCard({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'One Place. Endless\nCollaborations.',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        const _DashedDivider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Pill(
                backgroundColor: Colors.black,
                borderColor: Colors.black,
                foregroundColor: Colors.white,
                icon: const InstagramIcon(size: 20),
                label: '@collabsy_official',
                onTap: () => _launch(_instagramUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Pill(
                backgroundColor: Colors.white,
                borderColor: AppColors.primary,
                foregroundColor: AppColors.primary,
                icon: const WhatsAppIcon(size: 20),
                label: 'Talk to us',
                onTap: () => _launch(_whatsappUrl),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

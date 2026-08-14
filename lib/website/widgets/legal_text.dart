import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

/// Small building blocks for rendering the ported Privacy/Terms copy with
/// the same structure (h2 sections, bold-led paragraphs, bullet lists) as
/// the source `web-legal/{privacy,terms}/index.html`.
class LegalH2 extends StatelessWidget {
  const LegalH2(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(text, style: AppTextStyles.heading2),
    );
  }
}

class LegalP extends StatelessWidget {
  const LegalP(this.spans, {super.key});

  final List<InlineSpan> spans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text.rich(
        TextSpan(style: AppTextStyles.bodyLarge, children: spans),
      ),
    );
  }
}

TextSpan legalBold(String text) => TextSpan(
  text: text,
  style: const TextStyle(fontWeight: FontWeight.w700),
);

TextSpan legalText(String text) => TextSpan(text: text);

class LegalBullets extends StatelessWidget {
  const LegalBullets(this.items, {super.key});

  final List<List<InlineSpan>> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final spans in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: AppTextStyles.bodyLarge),
                  Expanded(
                    child: Text.rich(
                      TextSpan(style: AppTextStyles.bodyLarge, children: spans),
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

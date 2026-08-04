import 'package:flutter/material.dart';

/// Which identity this badge marks — each gets its own fixed, brand-neutral
/// color (independent of `AppColors`/theme, same reasoning as
/// `InstagramIcon` staying brand-colored regardless of app theme).
enum VerifiedBadgeVariant { creator, brand, broadcast, support }

/// A lite X/Twitter-style verified tick. `Icons.verified` is Material's
/// built-in scalloped-seal-with-checkmark glyph — already exactly this
/// shape, just tinted per [variant]. Creator/Brand badges are shown by the
/// caller only when that profile's `verificationStatus` is approved;
/// Broadcast/Support are fixed official identities and always shown.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.variant, this.size = 16});

  final VerifiedBadgeVariant variant;
  final double size;

  Color get _color => switch (variant) {
    VerifiedBadgeVariant.creator => const Color(0xFF1D9BF0),
    VerifiedBadgeVariant.brand => const Color(0xFF9AA5B1),
    VerifiedBadgeVariant.broadcast => const Color(0xFFD4AF37),
    // Deliberately distinct from AppColors.error (#DC2626) so it never
    // reads as a warning.
    VerifiedBadgeVariant.support => const Color(0xFFE0245E),
  };

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified, color: _color, size: size);
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A small circular badge in WhatsApp's signature green with the actual
/// WhatsApp glyph (via the `font_awesome_flutter` icon font), used anywhere
/// the app links out to WhatsApp.
class WhatsAppIcon extends StatelessWidget {
  const WhatsAppIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF25D366),
        shape: BoxShape.circle,
      ),
      child: FaIcon(
        FontAwesomeIcons.whatsapp,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

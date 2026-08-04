import 'package:flutter/material.dart';

/// A small square badge recreating Instagram's recognizable gradient
/// (purple -> pink -> orange -> yellow), used anywhere the app references
/// an Instagram connection — this app doesn't ship Meta's actual logo
/// asset, just the brand color scheme people associate with it.
class InstagramIcon extends StatelessWidget {
  const InstagramIcon({super.key, this.size = 32, this.iconSize});

  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFEDA75),
            Color(0xFFFA7E1E),
            Color(0xFFD62976),
            Color(0xFF962FBF),
            Color(0xFF4F5BD5),
          ],
        ),
      ),
      child: Icon(
        Icons.camera_alt_outlined,
        color: Colors.white,
        size: iconSize ?? size * 0.55,
      ),
    );
  }
}

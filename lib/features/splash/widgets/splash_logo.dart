import 'package:flutter/material.dart';

import '../../../core/widgets/app_logo.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(
      size: 96,
      showText: true,
      showTagline: true,
    );
  }
}
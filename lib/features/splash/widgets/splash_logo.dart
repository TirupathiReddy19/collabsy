import 'package:flutter/material.dart';

import '../../../core/widgets/app_logo.dart';

/// The bare Collabsy mark, no card or text — matches the native Android
/// launch screen (android/app/src/main/res/drawable/launch_background.xml)
/// exactly, so the handoff from native to Dart splash is invisible.
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 120, height: 120, child: CollabsyMark());
  }
}

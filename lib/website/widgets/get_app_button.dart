import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=online.collabsy.app';
const _appStoreUrl = 'https://apps.apple.com/in/app/collabsy/id6808197823';

Future<void> _openStore(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

/// "Get the app" CTA. On an Android or iPhone browser it goes straight to
/// that platform's store listing; anywhere else (desktop, iPad, unknown) it
/// asks which store, since a desktop visitor can't tell which one they need
/// to open on their phone.
class GetAppButton extends StatelessWidget {
  const GetAppButton({super.key})
    : label = 'Download the App',
      expanded = true;

  const GetAppButton.compact({super.key})
    : label = 'Get the App',
      expanded = false;

  final String label;
  final bool expanded;

  Future<void> _onPressed(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _openStore(_playStoreUrl);
      case TargetPlatform.iOS:
        return _openStore(_appStoreUrl);
      default:
        return showDialog<void>(
          context: context,
          builder: (_) => const _ChooseStoreDialog(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: () => _onPressed(context),
      icon: const Icon(Icons.download_rounded, size: 18),
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

class _ChooseStoreDialog extends StatelessWidget {
  const _ChooseStoreDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Get the Collabsy app'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Available on Android and iPhone in India. Pick your phone\'s '
              'store to open the listing.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _StoreButton(
              icon: Icons.phone_android_rounded,
              label: 'Google Play (Android)',
              url: _playStoreUrl,
            ),
            const SizedBox(height: 12),
            _StoreButton(
              icon: Icons.phone_iphone_rounded,
              label: 'App Store (iPhone)',
              url: _appStoreUrl,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _StoreButton extends StatelessWidget {
  const _StoreButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _openStore(url);
        Navigator.of(context).pop();
      },
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }
}

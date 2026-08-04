import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/config/instagram_config.dart';
import '../widgets/instagram_oauth_webview_screen.dart';

/// Drives the user-facing half of Instagram Business Login: builds the
/// authorize URL and shows it in an in-app WebView, returning the
/// authorization `code` once Instagram redirects back. This service never
/// talks to Instagram's token endpoints directly — the App Secret those
/// require must never reach the client, so the code exchange happens in
/// [InstagramRepository] via a Cloud Function instead.
class InstagramAuthService {
  const InstagramAuthService();

  /// Opens the Instagram authorize page and waits for the redirect.
  /// Returns the authorization code, or throws
  /// [InstagramAuthCancelledException] if the user backs out or Instagram
  /// declines (e.g. `access_denied`).
  Future<String> authorize(BuildContext context) async {
    final state = _randomState();
    final authorizeUrl = InstagramConfig.buildAuthorizeUrl(state);

    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (context) => InstagramOAuthWebViewScreen(
          authorizeUrl: authorizeUrl,
          redirectUri: InstagramConfig.redirectUri,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result is String) return result;
    if (result is InstagramAuthCancelledException) throw result;
    throw const InstagramAuthCancelledException();
  }

  String _randomState() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }
}

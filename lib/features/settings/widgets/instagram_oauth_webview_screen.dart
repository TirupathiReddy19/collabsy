import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';

/// Thrown when the user cancels or Instagram redirects back with an OAuth
/// error instead of a code (e.g. `access_denied` if they decline
/// permissions).
class InstagramAuthCancelledException implements Exception {
  const InstagramAuthCancelledException([this.reason]);
  final String? reason;

  @override
  String toString() =>
      'InstagramAuthCancelledException(${reason ?? 'cancelled'})';
}

/// Shows the Instagram authorize page in an in-app WebView and resolves
/// once the WebView is about to navigate to [redirectUri] — at that point
/// the `code` (or `error`) query parameter is extracted from the URL and
/// that navigation is cancelled, so the redirect page itself never
/// actually loads over the network.
class InstagramOAuthWebViewScreen extends StatefulWidget {
  const InstagramOAuthWebViewScreen({
    super.key,
    required this.authorizeUrl,
    required this.redirectUri,
  });

  final String authorizeUrl;
  final String redirectUri;

  @override
  State<InstagramOAuthWebViewScreen> createState() =>
      _InstagramOAuthWebViewScreenState();
}

class _InstagramOAuthWebViewScreenState
    extends State<InstagramOAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          // The primary interception is in onNavigationRequest, which
          // cancels the redirect before it ever loads. But some Android
          // WebView versions don't invoke that hook for server-side (HTTP
          // 30x) redirect hops, so the redirect page — the plain HTML
          // fallback served by instagramOAuthRedirect — ends up actually
          // loading with the code/error still sitting unread in its own
          // URL. Checking again here catches that case instead of leaving
          // the user stuck looking at a page that never resolves.
          onPageFinished: (url) {
            if (mounted) setState(() => _loading = false);
            _tryResolve(url);
          },
          onNavigationRequest: (request) {
            if (_tryResolve(request.url)) return NavigationDecision.prevent;
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizeUrl));
  }

  bool _tryResolve(String url) {
    if (_resolved || !url.startsWith(widget.redirectUri)) return false;

    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    final error =
        uri.queryParameters['error'] ??
        uri.queryParameters['error_description'];
    if (code == null && error == null) return false;

    _resolved = true;
    if (code != null) {
      Navigator.of(context).pop(code);
    } else {
      Navigator.of(context).pop(InstagramAuthCancelledException(error));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Instagram'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(
            context,
          ).pop(const InstagramAuthCancelledException('closed_by_user')),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: LoadingIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}

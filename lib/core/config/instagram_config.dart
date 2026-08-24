/// Instagram Business Login (the current "Instagram API with Instagram
/// Login" product — not the deprecated Basic Display API) configuration.
///
/// [appId] is the Instagram App ID from the Meta App Dashboard (App setup ->
/// Instagram business login). It's a public value — it's sent as
/// `client_id` in the OAuth authorize URL, same as any OAuth client ID — the
/// App Secret never appears here or anywhere in the Flutter app; it lives
/// only in the Cloud Functions secret store.
///
/// [redirectUri] must exactly match (including trailing slash) one of the
/// "OAuth redirect URIs" configured for the product in the App Dashboard.
class InstagramConfig {
  InstagramConfig._();

  static const String appId = String.fromEnvironment(
    'INSTAGRAM_APP_ID',
    defaultValue: '1055815590339227',
  );

  static const String redirectUri = String.fromEnvironment(
    'INSTAGRAM_REDIRECT_URI',
    defaultValue:
        'https://us-central1-collabsy-mobile-applicaation.cloudfunctions.net/instagramOAuthRedirect',
  );

  /// Current (non-deprecated) Instagram Business Login scopes — the older
  /// `business_basic`/`business_content_publish`/etc. names were retired.
  ///
  /// Only `instagram_business_basic` is requested: it's the only scope the
  /// app actually calls (profile + follower stats via [fetchProfile] in the
  /// Cloud Functions). Requesting publish/comments/messages scopes the app
  /// never uses would need Advanced Access + Meta App Review to go Live,
  /// and reviewers reject permission requests that don't match real usage.
  static const List<String> scopes = ['instagram_business_basic'];

  static const String authorizeUrl =
      'https://www.instagram.com/oauth/authorize';

  static String buildAuthorizeUrl(String state) {
    final uri = Uri.parse(authorizeUrl).replace(
      queryParameters: {
        'client_id': appId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': scopes.join(','),
        'state': state,
      },
    );
    return uri.toString();
  }
}

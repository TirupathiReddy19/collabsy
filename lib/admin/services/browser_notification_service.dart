import 'dart:html' as html;

/// Which admin event triggered the notification — each gets its own short,
/// synthesized tone (`assets/sounds/`, generated locally — not sourced
/// audio) so staff can tell categories apart without looking at the
/// screen.
enum AdminNotificationSound {
  creatorProfile('assets/sounds/notify_creator.wav'),
  brandProfile('assets/sounds/notify_brand.wav'),
  campaignApproval('assets/sounds/notify_campaign.wav'),
  supportTicket('assets/sounds/notify_support.wav'),
  reportOrBlock('assets/sounds/notify_report.wav');

  const AdminNotificationSound(this.assetPath);

  /// Pubspec-relative asset path. Flutter web serves declared assets
  /// nested under an extra `assets/` prefix — see [_audioUrl].
  final String assetPath;
}

/// Desktop (browser) notifications for the admin web portal.
///
/// `dart:html`-only, same as [downloadCsv] in `csv_download.dart` — safe
/// because `lib/admin` is exclusively built for
/// `flutter build web -t lib/main_admin.dart` and this file is never
/// reachable from the mobile app's entry point.
///
/// Deliberately only fires while the tab is backgrounded (Page Visibility
/// API): a staff member looking at the screen already sees the new item
/// in whatever live list is open, so a desktop popup and a sound on top
/// of that would just be noise.
class BrowserNotificationService {
  BrowserNotificationService._();

  static bool get _isSupported => html.Notification.supported;

  /// Call once the admin is signed in — browsers only show the permission
  /// prompt in response to a real session, and this is a no-op once the
  /// user has already answered (granted or denied) on a prior visit.
  static Future<void> requestPermission() async {
    if (!_isSupported) return;
    if (html.Notification.permission != 'default') return;
    await html.Notification.requestPermission();
  }

  static void notify({
    required String title,
    required String body,
    required AdminNotificationSound sound,
    String? tag,
  }) {
    if (html.document.hidden != true) {
      // Tab is focused/visible — staff is already looking at the portal.
      return;
    }
    _playSound(sound);
    if (_isSupported && html.Notification.permission == 'granted') {
      html.Notification(title, body: body, tag: tag, icon: 'favicon.png');
    }
  }

  static void _playSound(AdminNotificationSound sound) {
    try {
      html.AudioElement('assets/${sound.assetPath}').play();
    } catch (_) {
      // Autoplay can be blocked until the tab has had a user gesture —
      // nothing actionable to do about it from here.
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns a [Stream] into a [Listenable] so `GoRouter`'s `refreshListenable`
/// re-evaluates `redirect()` whenever the stream emits — used to react to
/// Firebase auth-state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  /// Manually triggers a `redirect()` re-evaluation — used to bridge in
  /// signals that aren't a [Stream] this class already owns a subscription
  /// to (e.g. a Riverpod `ref.listen` callback on another provider).
  void refresh() => notifyListeners();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

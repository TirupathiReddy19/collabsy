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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

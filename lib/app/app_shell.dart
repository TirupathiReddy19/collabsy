import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/push_notification_service.dart';
import '../features/auth/providers/auth_providers.dart';
import 'routes.dart';

/// Requests push permission and registers the FCM token once per session,
/// shortly after landing in either portal's shell — by then the user is
/// definitely signed in with a `users/{uid}` doc to attach the token to.
/// Also surfaces foreground messages as a SnackBar (FCM doesn't show its own
/// system-tray notification while the app is in the foreground) and routes
/// a tap on a background/terminated notification to the in-app feed.
mixin _PushSetupMixin<T extends StatefulWidget> on State<T> {
  WidgetRef get ref;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final userId = ref.read(authRepositoryProvider).currentUser?.uid;
      if (userId == null) return;
      await ref.read(pushNotificationServiceProvider).initialize(userId);

      // App was opened by tapping a push notification while fully
      // terminated (as opposed to backgrounded, which onMessageOpenedApp
      // below covers).
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null && mounted) {
        context.push(AppRoutes.notifications);
      }

      FirebaseMessaging.onMessage.listen((message) {
        if (!mounted) return;
        final notification = message.notification;
        if (notification == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${notification.title ?? ''}: ${notification.body ?? ''}',
            ),
          ),
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (!mounted) return;
        context.push(AppRoutes.notifications);
      });
    });
  }
}

/// Cross-fades on every bottom-nav tab switch without ever recreating
/// [child] — [StatefulNavigationShell] keeps every branch's own Navigator
/// alive internally (that's what preserves each tab's scroll/nav state), so
/// swapping it into an AnimatedSwitcher would tear that down. Instead this
/// just replays a fade over the same child whenever [currentIndex] changes.
class _TabFade extends StatefulWidget {
  const _TabFade({required this.currentIndex, required this.child});

  final int currentIndex;
  final Widget child;

  @override
  State<_TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<_TabFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  @override
  void didUpdateWidget(_TabFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: widget.child);
  }
}

/// Bottom-nav shell for the Creator portal (Home / Campaigns / Messages /
/// Profile) — wraps whichever branch [StatefulShellRoute.indexedStack]
/// currently has active.
class CreatorShell extends ConsumerStatefulWidget {
  const CreatorShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<CreatorShell> createState() => _CreatorShellState();
}

class _CreatorShellState extends ConsumerState<CreatorShell>
    with _PushSetupMixin<CreatorShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _TabFade(
        currentIndex: widget.navigationShell.currentIndex,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Campaigns',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Bottom-nav shell for the Brand portal (Home / Campaigns / Discover /
/// Messages / Account).
class BrandShell extends ConsumerStatefulWidget {
  const BrandShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<BrandShell> createState() => _BrandShellState();
}

class _BrandShellState extends ConsumerState<BrandShell>
    with _PushSetupMixin<BrandShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _TabFade(
        currentIndex: widget.navigationShell.currentIndex,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Campaigns',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

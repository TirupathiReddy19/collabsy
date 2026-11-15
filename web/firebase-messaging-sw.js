// Required by the `firebase_messaging` Flutter plugin's web implementation,
// which registers this exact path regardless of whether a given web build
// actually uses FCM (it's a shared pubspec.yaml dependency, compiled into
// every `flutter build web` target — admin, brand-intern, intern, website,
// marketing — not just the mobile app that calls FirebaseMessaging APIs).
// Without this file, the request 404s at the static level and Firebase
// Hosting's SPA catch-all rewrite (`"source": "**" -> "/index.html"`) serves
// the page HTML instead, which the browser then refuses to run as a script:
// "The script has an unsupported MIME type ('text/html')".
//
// Lives in `web/` (shared by every build target, not per-target) so one
// copy fixes this everywhere at once. This project's web portals don't
// currently send background FCM pushes themselves (the admin desktop
// notifications feature is a separate, plain Notification-API mechanism —
// see `lib/admin/services/browser_notification_service.dart`), so the
// background handler below is the standard no-op passthrough: it exists
// only so the browser has a valid script to register.
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCV74-c6R-QMmTj-NRBSpOg7pI2wsCW510',
  appId: '1:132008349319:web:66b3cf4586b601e2857222',
  messagingSenderId: '132008349319',
  projectId: 'collabsy-mobile-applicaation',
  authDomain: 'collabsy-mobile-applicaation.firebaseapp.com',
  storageBucket: 'collabsy-mobile-applicaation.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title ?? 'Collabsy';
  self.registration.showNotification(title, {
    body: payload.notification?.body,
    icon: '/favicon.png',
  });
});

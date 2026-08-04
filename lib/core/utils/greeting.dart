import 'package:flutter/material.dart';

/// A time-of-day greeting for dashboard headers — "Good morning"/
/// "Good afternoon"/"Good evening"/"Good night" depending on the device's
/// current local time.
String timeBasedGreeting() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return 'Good morning';
  if (hour >= 12 && hour < 17) return 'Good afternoon';
  if (hour >= 17 && hour < 21) return 'Good evening';
  return 'Good night';
}

/// A sunrise/sun/sunset/moon icon matching [timeBasedGreeting]'s time band.
/// Sunset reuses the sunrise glyph mirrored horizontally — Material's icon
/// set has no distinct sunset icon of its own.
Widget timeBasedGreetingIcon({double size = 40, Color? color}) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) {
    return Icon(Icons.wb_twilight, size: size, color: color);
  }
  if (hour >= 12 && hour < 17) {
    return Icon(Icons.wb_sunny, size: size, color: color);
  }
  if (hour >= 17 && hour < 21) {
    return Transform.flip(
      flipX: true,
      child: Icon(Icons.wb_twilight, size: size, color: color),
    );
  }
  return Icon(Icons.nights_stay, size: size, color: color);
}

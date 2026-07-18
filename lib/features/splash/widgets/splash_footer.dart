import 'package:flutter/material.dart';

class SplashFooter extends StatefulWidget {
  const SplashFooter({super.key});

  @override
  State<SplashFooter> createState() => _SplashFooterState();
}

class _SplashFooterState extends State<SplashFooter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.9),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "Loading...",
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Preparing your experience",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 36),
      ],
    );
  }
}
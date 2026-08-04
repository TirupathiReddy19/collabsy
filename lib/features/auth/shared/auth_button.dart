import 'package:flutter/material.dart';

import '../../../core/widgets/primary_button.dart';

/// The primary full-width call-to-action button used across auth screens
/// (Send OTP / Verify / Continue). Thin wrapper around [PrimaryButton] so
/// every auth screen gets consistent sizing without duplicating it.
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
    );
  }
}

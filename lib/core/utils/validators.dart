import 'package:flutter/widgets.dart';

enum IdentifierType { email, phone, unknown }

/// Domains that don't count as a "work" email — mirrors the Figma
/// SmartLogin prototype's personal-domain block list for the Brand tab.
const personalEmailDomains = [
  'gmail.com',
  'yahoo.com',
  'hotmail.com',
  'outlook.com',
  'rediffmail.com',
  'ymail.com',
  'icloud.com',
  'live.com',
];

class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneDigitsPattern = RegExp(r'^\d{10}$');

  /// Detects whether [value] looks like an email or a phone number as the
  /// user types, for the single smart-login identifier field.
  static IdentifierType detectIdentifierType(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return IdentifierType.unknown;
    if (trimmed.contains('@')) return IdentifierType.email;

    final digitsOnly = trimmed
        .replaceAll(RegExp(r'\s+'), '')
        .replaceFirst(RegExp(r'^(\+91|0)'), '');
    if (RegExp(r'^\d+$').hasMatch(digitsOnly)) return IdentifierType.phone;

    return IdentifierType.unknown;
  }

  static bool isPersonalEmailDomain(String email) {
    final parts = email.split('@');
    if (parts.length < 2) return false;
    return personalEmailDomains.contains(parts[1].toLowerCase().trim());
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your email address';
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  /// Same as [email] but also requires a non-personal (work) domain —
  /// used on the Brand/Agency signup tab.
  static String? workEmail(String? value) {
    final basic = email(value);
    if (basic != null) return basic;
    if (isPersonalEmailDomain(value!.trim())) {
      return 'Work email required (not Gmail/Yahoo/Hotmail, etc.)';
    }
    return null;
  }

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your phone number';
    final digitsOnly = trimmed
        .replaceAll(RegExp(r'\s+'), '')
        .replaceFirst(RegExp(r'^(\+91|0)'), '');
    if (!_phoneDigitsPattern.hasMatch(digitsOnly)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Normalizes a validated 10-digit Indian number (with or without a
  /// leading `+91`/`0`) into the E.164 format Firebase's phone auth
  /// requires (`+91XXXXXXXXXX`) — [phone] only checks digit count, it
  /// never mutates what the user typed.
  static String toE164(String value) {
    final digitsOnly = value
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceFirst(RegExp(r'^(\+91|0)'), '');
    return '+91$digitsOnly';
  }

  static final _linkedinPattern = RegExp(
    r'^https?:\/\/(www\.)?linkedin\.com\/.+',
    caseSensitive: false,
  );

  static String? linkedinUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your LinkedIn profile link';
    if (!_linkedinPattern.hasMatch(trimmed)) {
      return 'Enter a valid LinkedIn URL (linkedin.com/...)';
    }
    return null;
  }

  static String? password(String? value) {
    final trimmed = value ?? '';
    if (trimmed.isEmpty) return 'Enter a password';
    if (trimmed.length < 8) return 'Min. 8 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(
    TextEditingController passwordController,
  ) {
    return (value) {
      if (value != passwordController.text) return 'Passwords do not match';
      return null;
    };
  }
}

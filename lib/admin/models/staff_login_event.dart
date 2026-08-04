import 'package:flutter/material.dart';

/// What kind of session-boundary event this is — written at each real
/// admin-portal sign-in/sign-out for a staff account, since Firebase Auth
/// itself only ever exposes the single latest `metadata.lastSignInTime`
/// and keeps no history of its own.
enum StaffLoginEventType {
  login,
  logout,
  forcedLogout;

  static StaffLoginEventType fromDbValue(String? value) => switch (value) {
    'logout' => StaffLoginEventType.logout,
    'forcedLogout' => StaffLoginEventType.forcedLogout,
    _ => StaffLoginEventType.login,
  };

  String toDbValue() => name;

  String get label => switch (this) {
    StaffLoginEventType.login => 'Signed in',
    StaffLoginEventType.logout => 'Signed out',
    StaffLoginEventType.forcedLogout => 'Force-logged-out by admin',
  };

  IconData get icon => switch (this) {
    StaffLoginEventType.login => Icons.login,
    StaffLoginEventType.logout => Icons.logout,
    StaffLoginEventType.forcedLogout => Icons.block,
  };
}

/// One `staffLoginEvents` document — write-once (see `firestore.rules`),
/// a permanent record of a single staff account session boundary.
typedef StaffLoginEvent = ({
  String uid,
  String email,
  String roleName,
  StaffLoginEventType type,
  DateTime? timestamp,
});

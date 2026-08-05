import 'package:flutter/material.dart';

/// What kind of admin decision this log entry records. Every one of these
/// corresponds to an action that already exists elsewhere in the admin
/// portal (Campaign/Brand approve-reject) — this just also writes a
/// permanent record of it.
enum AuditLogAction {
  campaignApproved,
  campaignRejected,
  brandVerified,
  brandRejected,
  creatorVerified,
  creatorRejected,
  staffAccountCreated,
  staffPermissionsUpdated,
  staffAccountForcedLogout,
  supportReplySent,
  supportTicketResolved,
  supportTicketReopened,
  broadcastSent,
  outreachSettingsUpdated,
  creatorSuspended,
  creatorReinstated,
  brandSuspended,
  brandReinstated;

  static AuditLogAction fromDbValue(String? value) => switch (value) {
    'campaignRejected' => AuditLogAction.campaignRejected,
    'brandVerified' => AuditLogAction.brandVerified,
    'brandRejected' => AuditLogAction.brandRejected,
    'creatorVerified' => AuditLogAction.creatorVerified,
    'creatorRejected' => AuditLogAction.creatorRejected,
    'staffAccountCreated' => AuditLogAction.staffAccountCreated,
    'staffPermissionsUpdated' => AuditLogAction.staffPermissionsUpdated,
    'staffAccountForcedLogout' => AuditLogAction.staffAccountForcedLogout,
    'supportReplySent' => AuditLogAction.supportReplySent,
    'supportTicketResolved' => AuditLogAction.supportTicketResolved,
    'supportTicketReopened' => AuditLogAction.supportTicketReopened,
    'broadcastSent' => AuditLogAction.broadcastSent,
    'outreachSettingsUpdated' => AuditLogAction.outreachSettingsUpdated,
    'creatorSuspended' => AuditLogAction.creatorSuspended,
    'creatorReinstated' => AuditLogAction.creatorReinstated,
    'brandSuspended' => AuditLogAction.brandSuspended,
    'brandReinstated' => AuditLogAction.brandReinstated,
    _ => AuditLogAction.campaignApproved,
  };

  String toDbValue() => name;

  String label(String targetName) => switch (this) {
    AuditLogAction.campaignApproved => 'Approved campaign "$targetName"',
    AuditLogAction.campaignRejected => 'Rejected campaign "$targetName"',
    AuditLogAction.brandVerified => 'Verified brand "$targetName"',
    AuditLogAction.brandRejected => 'Rejected brand "$targetName"',
    AuditLogAction.creatorVerified => 'Verified creator "$targetName"',
    AuditLogAction.creatorRejected => 'Rejected creator "$targetName"',
    AuditLogAction.staffAccountCreated => 'Created staff role "$targetName"',
    AuditLogAction.staffPermissionsUpdated =>
      'Updated access for staff role "$targetName"',
    AuditLogAction.staffAccountForcedLogout =>
      'Forced logout for staff role "$targetName"',
    AuditLogAction.supportReplySent => 'Replied to $targetName\'s ticket',
    AuditLogAction.supportTicketResolved =>
      'Marked $targetName\'s ticket resolved',
    AuditLogAction.supportTicketReopened => 'Reopened $targetName\'s ticket',
    AuditLogAction.broadcastSent => 'Sent broadcast "$targetName"',
    AuditLogAction.outreachSettingsUpdated => 'Updated $targetName settings',
    AuditLogAction.creatorSuspended => 'Suspended creator "$targetName"',
    AuditLogAction.creatorReinstated => 'Reinstated creator "$targetName"',
    AuditLogAction.brandSuspended => 'Suspended brand "$targetName"',
    AuditLogAction.brandReinstated => 'Reinstated brand "$targetName"',
  };

  IconData get icon => switch (this) {
    AuditLogAction.campaignApproved => Icons.campaign_outlined,
    AuditLogAction.campaignRejected => Icons.campaign_outlined,
    AuditLogAction.brandVerified => Icons.business_outlined,
    AuditLogAction.brandRejected => Icons.business_outlined,
    AuditLogAction.creatorVerified => Icons.people_outline,
    AuditLogAction.creatorRejected => Icons.people_outline,
    AuditLogAction.staffAccountCreated => Icons.admin_panel_settings_outlined,
    AuditLogAction.staffPermissionsUpdated => Icons.edit_outlined,
    AuditLogAction.staffAccountForcedLogout => Icons.logout,
    AuditLogAction.supportReplySent => Icons.support_agent_outlined,
    AuditLogAction.supportTicketResolved => Icons.check_circle_outline,
    AuditLogAction.supportTicketReopened => Icons.replay,
    AuditLogAction.broadcastSent => Icons.campaign_outlined,
    AuditLogAction.outreachSettingsUpdated => Icons.settings_outlined,
    AuditLogAction.creatorSuspended ||
    AuditLogAction.brandSuspended => Icons.block,
    AuditLogAction.creatorReinstated ||
    AuditLogAction.brandReinstated => Icons.restart_alt,
  };

  bool get isApproval => switch (this) {
    AuditLogAction.campaignApproved ||
    AuditLogAction.brandVerified ||
    AuditLogAction.creatorVerified ||
    AuditLogAction.staffAccountCreated ||
    AuditLogAction.staffPermissionsUpdated ||
    AuditLogAction.supportReplySent ||
    AuditLogAction.supportTicketResolved ||
    AuditLogAction.broadcastSent ||
    AuditLogAction.outreachSettingsUpdated ||
    AuditLogAction.creatorReinstated ||
    AuditLogAction.brandReinstated => true,
    AuditLogAction.campaignRejected ||
    AuditLogAction.brandRejected ||
    AuditLogAction.creatorRejected ||
    AuditLogAction.staffAccountForcedLogout ||
    AuditLogAction.supportTicketReopened ||
    AuditLogAction.creatorSuspended ||
    AuditLogAction.brandSuspended => false,
  };

  /// Where tapping this entry should navigate — `null` targetId means
  /// there's nothing to jump to.
  String? routeFor(String targetId) => switch (this) {
    AuditLogAction.campaignApproved ||
    AuditLogAction.campaignRejected => '/campaigns/$targetId',
    AuditLogAction.brandVerified ||
    AuditLogAction.brandRejected => '/brands/$targetId',
    AuditLogAction.creatorVerified ||
    AuditLogAction.creatorRejected => '/creators/$targetId',
    AuditLogAction.staffAccountCreated ||
    AuditLogAction.staffPermissionsUpdated ||
    AuditLogAction.staffAccountForcedLogout => '/roles',
    AuditLogAction.supportReplySent ||
    AuditLogAction.supportTicketResolved ||
    AuditLogAction.supportTicketReopened => '/support/$targetId',
    AuditLogAction.broadcastSent => null,
    AuditLogAction.outreachSettingsUpdated => '/settings',
    AuditLogAction.creatorSuspended ||
    AuditLogAction.creatorReinstated => '/creators/$targetId',
    AuditLogAction.brandSuspended ||
    AuditLogAction.brandReinstated => '/brands/$targetId',
  };
}

/// One `auditLogs` document — a permanent record of a single admin
/// decision. Write-once (see `firestore.rules`); this app never edits or
/// deletes one.
typedef AuditLogEntry = ({
  String actorEmail,
  AuditLogAction action,
  String targetId,
  String targetName,
  DateTime? timestamp,
});

import 'package:flutter/material.dart';

/// What a notification is about — drives its icon in the feed. Navigation
/// on tap is driven by `referenceType`/`referenceId` on the notification
/// itself, not this.
enum NotificationType {
  newApplication,
  applicationAccepted,
  applicationRejected,
  newMessage,
  deliverableSubmitted,
  deliverableApproved,
  campaignApproved,
  campaignRejected,
  profileVerified,
  profileRejected,
  supportReply,
  applicationWithdrawn;

  static NotificationType fromDbValue(String? value) => switch (value) {
    'newApplication' => NotificationType.newApplication,
    'applicationAccepted' => NotificationType.applicationAccepted,
    'applicationRejected' => NotificationType.applicationRejected,
    'applicationWithdrawn' => NotificationType.applicationWithdrawn,
    'deliverableSubmitted' => NotificationType.deliverableSubmitted,
    'deliverableApproved' => NotificationType.deliverableApproved,
    'campaignApproved' => NotificationType.campaignApproved,
    'campaignRejected' => NotificationType.campaignRejected,
    'profileVerified' => NotificationType.profileVerified,
    'profileRejected' => NotificationType.profileRejected,
    'supportReply' => NotificationType.supportReply,
    _ => NotificationType.newMessage,
  };

  String toDbValue() => name;

  IconData get icon => switch (this) {
    NotificationType.newApplication => Icons.person_add_alt_outlined,
    NotificationType.applicationAccepted => Icons.check_circle_outline,
    NotificationType.applicationRejected => Icons.cancel_outlined,
    NotificationType.newMessage => Icons.chat_bubble_outline,
    NotificationType.deliverableSubmitted => Icons.upload_outlined,
    NotificationType.deliverableApproved => Icons.verified_outlined,
    NotificationType.campaignApproved => Icons.campaign_outlined,
    NotificationType.campaignRejected => Icons.cancel_outlined,
    NotificationType.profileVerified => Icons.verified_user_outlined,
    NotificationType.profileRejected => Icons.gpp_bad_outlined,
    NotificationType.supportReply => Icons.help_outline,
    NotificationType.applicationWithdrawn => Icons.undo_outlined,
  };
}

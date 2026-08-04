/// Whether an admin has reviewed a Brand's website + LinkedIn profile, or a
/// Creator's connected Instagram — the same pending/approved/rejected
/// lifecycle applies to both profile types. Every profile starts (and
/// stays) [pending] until an admin explicitly sets it — the profile's own
/// user can never write this field (enforced in `firestore.rules`, not
/// just the UI).
enum VerificationStatus {
  pending,
  approved,
  rejected;

  String toDbValue() => name;

  String get label => switch (this) {
    VerificationStatus.pending => 'Pending review',
    VerificationStatus.approved => 'Verified',
    VerificationStatus.rejected => 'Rejected',
  };
}

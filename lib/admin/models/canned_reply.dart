/// A predefined reply the admin/staff can drop into the reply box instead
/// of retyping the same answer to common questions — hardcoded for now,
/// not stored in Firestore, since there's no need yet to edit these outside
/// of a code change.
class CannedReply {
  const CannedReply(this.label, this.text);

  final String label;
  final String text;
}

const cannedReplies = [
  CannedReply(
    'Ask for a screenshot',
    'Thanks for reaching out! Could you share a screenshot of the issue '
        "so we can take a closer look?",
  ),
  CannedReply(
    'Looking into it',
    "We've received your report and are looking into it now — we'll "
        'update you here as soon as we know more.',
  ),
  CannedReply(
    'Issue resolved',
    "This has been resolved on our end — please try again and let us "
        "know if it's still happening.",
  ),
  CannedReply(
    'Verification timing',
    'Your brand profile is under review — this usually takes 15–30 '
        'minutes.',
  ),
  CannedReply(
    'Campaign review timing',
    'New campaigns go through a quick review before going live — this '
        'usually takes 15–30 minutes.',
  ),
];

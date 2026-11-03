import { getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

import { requireAdminOrPermission } from "../shared/adminAuth";

/**
 * Whether the caller has already connected a mail.collabsy.online mailbox
 * (see `connectBrandMailbox.ts`) — the brand-intern compose dialog checks
 * this before offering to send, since `brandMailCredentials/{uid}` itself is
 * unreadable to every client. Only ever returns the email, never the stored
 * password.
 */
export const getBrandMailboxStatus = onCall(async (request) => {
  await requireAdminOrPermission(request, "/brand-outreach-leads");

  const doc = await getFirestore()
    .collection("brandMailCredentials")
    .doc(request.auth!.uid)
    .get();

  return { email: (doc.data()?.email as string | undefined) ?? null };
});

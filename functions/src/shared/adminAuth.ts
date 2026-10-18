import { getFirestore } from "firebase-admin/firestore";
import { CallableRequest, HttpsError } from "firebase-functions/v2/https";

export const ADMIN_EMAIL = "admin@collabsy.online";

/**
 * True only for the super admin, mirroring firestore.rules' isAdmin().
 * E1: email_verified re-enabled 2026-10-18 once admin@collabsy.online's
 * email was actually verified (an earlier attempt locked the admin portal
 * out on 2026-10-11, because it wasn't verified yet at that point).
 */
export function isAdminRequest(request: CallableRequest): boolean {
  return request.auth?.token?.email === ADMIN_EMAIL
    && request.auth?.token?.email_verified === true;
}

/** Throws `permission-denied` unless the caller is the super admin. */
export function requireAdmin(request: CallableRequest): void {
  if (!isAdminRequest(request)) {
    throw new HttpsError("permission-denied", "Admin only.");
  }
}

/**
 * Mirrors firestore.rules' isAdmin()/isActiveStaffWithPermission(navPath) —
 * the same authorization boundary, reimplemented here because Cloud
 * Functions don't go through Firestore security rules for their own logic
 * (only for the Firestore reads/writes they themselves perform). Throws
 * `permission-denied` rather than returning a bool so every caller fails
 * closed by default.
 */
export async function requireAdminOrPermission(
  request: CallableRequest,
  navPath: string
): Promise<void> {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  if (isAdminRequest(request)) return;

  const staffDoc = await getFirestore().collection("staffAccounts").doc(uid).get();
  const staff = staffDoc.data();
  if (staff?.active === true && staff?.permissions?.[navPath] === true) return;

  throw new HttpsError("permission-denied", "You don't have access to this section.");
}

import { getFirestore } from "firebase-admin/firestore";
import { CallableRequest, HttpsError } from "firebase-functions/v2/https";

const ADMIN_EMAIL = "admin@collabsy.online";

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
  const email = request.auth?.token?.email;
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  if (email === ADMIN_EMAIL) return;

  const staffDoc = await getFirestore().collection("staffAccounts").doc(uid).get();
  const staff = staffDoc.data();
  if (staff?.active === true && staff?.permissions?.[navPath] === true) return;

  throw new HttpsError("permission-denied", "You don't have access to this section.");
}

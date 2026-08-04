import { getAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const ADMIN_EMAIL = "admin@collabsy.online";

interface CreateStaffAccountRequest {
  email: string;
  password: string;
  roleName: string;
  permissions: Record<string, boolean>;
}

/**
 * Creates a new admin-portal staff account — the client SDK can't create a
 * new Firebase Auth user without signing out the currently-authenticated
 * admin session, so this has to happen server-side via the Admin SDK (same
 * constraint already solved once for `backfillCreatedAtFromAuth`). Only the
 * super admin may call this; the resulting account's actual permissions are
 * enforced both here (what gets written) and in `firestore.rules`
 * (`isActiveStaffWithPermission`) on every subsequent request that account
 * makes — this function is just account provisioning, not the security
 * boundary itself.
 */
export const createStaffAccount = onCall(async (request) => {
  const email = request.auth?.token?.email;
  if (email !== ADMIN_EMAIL) {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const data = request.data as CreateStaffAccountRequest;
  if (!data?.email || !data?.password || !data?.roleName) {
    throw new HttpsError("invalid-argument", "email, password, and roleName are required.");
  }

  const userRecord = await getAuth().createUser({
    email: data.email,
    password: data.password,
  });

  await getFirestore().collection("staffAccounts").doc(userRecord.uid).set({
    email: data.email,
    roleName: data.roleName,
    permissions: data.permissions ?? {},
    active: true,
    createdAt: Timestamp.now(),
    createdBy: ADMIN_EMAIL,
  });

  return { uid: userRecord.uid };
});

import { getAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const ADMIN_EMAIL = "admin@collabsy.online";

/**
 * Suspends a Creator or Brand account found violating the Terms of
 * Service. Sign-in itself is deliberately left enabled — the app's own
 * router gate is what actually locks a suspended account out (redirects
 * straight to a "your account is suspended" screen with nothing reachable
 * except Support), so the person can still see why and get help instead
 * of just hitting a generic sign-in failure. `revokeRefreshTokens` cuts
 * off any already-open session immediately (same primitive
 * `forceLogoutStaffAccount` uses for staff) so the next thing that
 * session does is re-authenticate and land on that gate too.
 */
export const suspendUserAccount = onCall(async (request) => {
  const email = request.auth?.token?.email;
  if (email !== ADMIN_EMAIL) {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const uid = request.data?.uid as string | undefined;
  const reason = request.data?.reason as string | undefined;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  await getAuth().revokeRefreshTokens(uid);

  await getFirestore()
    .collection("users")
    .doc(uid)
    .set(
      {
        suspended: true,
        suspendedReason: reason && reason.length > 0 ? reason : null,
        suspendedAt: Timestamp.now(),
      },
      { merge: true }
    );

  return { success: true };
});

/** Reverses `suspendUserAccount` — re-enables sign-in and clears the flag. */
export const reinstateUserAccount = onCall(async (request) => {
  const email = request.auth?.token?.email;
  if (email !== ADMIN_EMAIL) {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const uid = request.data?.uid as string | undefined;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  await getAuth().updateUser(uid, { disabled: false });

  await getFirestore().collection("users").doc(uid).set(
    {
      suspended: false,
      suspendedReason: null,
    },
    { merge: true }
  );

  return { success: true };
});

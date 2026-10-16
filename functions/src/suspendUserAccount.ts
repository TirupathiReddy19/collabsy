import { getAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { requireAdmin } from "./shared/adminAuth";

/**
 * Adds or removes the `suspended` custom claim while keeping any other claims
 * the account has. firestore.rules reads `request.auth.token.suspended` to
 * refuse a suspended account's writes (applications, chats, campaigns, ...) —
 * the claim, not the `users.suspended` field, is what the rules can check
 * without an extra read on every request. It only lands in the account's ID
 * token on its next refresh, which `revokeRefreshTokens` forces.
 */
async function setSuspendedClaim(uid: string, suspended: boolean): Promise<void> {
  const auth = getAuth();
  const user = await auth.getUser(uid);
  const claims = { ...(user.customClaims ?? {}) };
  if (suspended) {
    claims.suspended = true;
  } else {
    delete claims.suspended;
  }
  await auth.setCustomUserClaims(uid, claims);
}

/**
 * Suspends a Creator or Brand account found violating the Terms of
 * Service. Sign-in itself is deliberately left enabled — the app's own
 * router gate shows a "your account is suspended" screen with nothing
 * reachable except Support, so the person can still see why and get help
 * instead of just hitting a generic sign-in failure. The `suspended` custom
 * claim is what makes that real on the server: firestore.rules refuse the
 * account's writes (except Support) once its token carries the claim, so
 * bypassing the app UI doesn't help. `revokeRefreshTokens` cuts off any
 * already-open session so its next token refresh picks the claim up (an ID
 * token issued before the suspension stays valid for at most an hour).
 */
export const suspendUserAccount = onCall(async (request) => {
  requireAdmin(request);

  const uid = request.data?.uid as string | undefined;
  const reason = request.data?.reason as string | undefined;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  await setSuspendedClaim(uid, true);
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

/** Reverses `suspendUserAccount` — re-enables sign-in and clears the flag
 * and the claim. Refresh tokens are revoked again so the account's next
 * sign-in gets a token without the claim right away, instead of staying
 * blocked until the old one expires. */
export const reinstateUserAccount = onCall(async (request) => {
  requireAdmin(request);

  const uid = request.data?.uid as string | undefined;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid is required.");
  }

  await getAuth().updateUser(uid, { disabled: false });
  await setSuspendedClaim(uid, false);
  await getAuth().revokeRefreshTokens(uid);

  await getFirestore().collection("users").doc(uid).set(
    {
      suspended: false,
      suspendedReason: null,
    },
    { merge: true }
  );

  return { success: true };
});

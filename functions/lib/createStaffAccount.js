"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createStaffAccount = void 0;
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const ADMIN_EMAIL = "admin@collabsy.online";
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
exports.createStaffAccount = (0, https_1.onCall)(async (request) => {
    const email = request.auth?.token?.email;
    if (email !== ADMIN_EMAIL) {
        throw new https_1.HttpsError("permission-denied", "Admin only.");
    }
    const data = request.data;
    if (!data?.email || !data?.password || !data?.roleName) {
        throw new https_1.HttpsError("invalid-argument", "email, password, and roleName are required.");
    }
    const userRecord = await (0, auth_1.getAuth)().createUser({
        email: data.email,
        password: data.password,
    });
    await (0, firestore_1.getFirestore)().collection("staffAccounts").doc(userRecord.uid).set({
        email: data.email,
        roleName: data.roleName,
        permissions: data.permissions ?? {},
        active: true,
        createdAt: firestore_1.Timestamp.now(),
        createdBy: ADMIN_EMAIL,
    });
    return { uid: userRecord.uid };
});

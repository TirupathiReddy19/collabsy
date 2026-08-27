"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAdminOrPermission = requireAdminOrPermission;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const ADMIN_EMAIL = "admin@collabsy.online";
/**
 * Mirrors firestore.rules' isAdmin()/isActiveStaffWithPermission(navPath) —
 * the same authorization boundary, reimplemented here because Cloud
 * Functions don't go through Firestore security rules for their own logic
 * (only for the Firestore reads/writes they themselves perform). Throws
 * `permission-denied` rather than returning a bool so every caller fails
 * closed by default.
 */
async function requireAdminOrPermission(request, navPath) {
    const email = request.auth?.token?.email;
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    if (email === ADMIN_EMAIL)
        return;
    const staffDoc = await (0, firestore_1.getFirestore)().collection("staffAccounts").doc(uid).get();
    const staff = staffDoc.data();
    if (staff?.active === true && staff?.permissions?.[navPath] === true)
        return;
    throw new https_1.HttpsError("permission-denied", "You don't have access to this section.");
}

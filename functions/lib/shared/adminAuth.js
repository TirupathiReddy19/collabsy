"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ADMIN_EMAIL = void 0;
exports.isAdminRequest = isAdminRequest;
exports.requireAdmin = requireAdmin;
exports.requireAdminOrPermission = requireAdminOrPermission;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
exports.ADMIN_EMAIL = "admin@collabsy.online";
/**
 * True only for the super admin, mirroring firestore.rules' isAdmin().
 * E1: email_verified re-enabled 2026-10-18 once admin@collabsy.online's
 * email was actually verified (an earlier attempt locked the admin portal
 * out on 2026-10-11, because it wasn't verified yet at that point).
 */
function isAdminRequest(request) {
    return request.auth?.token?.email === exports.ADMIN_EMAIL
        && request.auth?.token?.email_verified === true;
}
/** Throws `permission-denied` unless the caller is the super admin. */
function requireAdmin(request) {
    if (!isAdminRequest(request)) {
        throw new https_1.HttpsError("permission-denied", "Admin only.");
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
async function requireAdminOrPermission(request, navPath) {
    const uid = request.auth?.uid;
    if (!uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    if (isAdminRequest(request))
        return;
    const staffDoc = await (0, firestore_1.getFirestore)().collection("staffAccounts").doc(uid).get();
    const staff = staffDoc.data();
    if (staff?.active === true && staff?.permissions?.[navPath] === true)
        return;
    throw new https_1.HttpsError("permission-denied", "You don't have access to this section.");
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendPushOnNotificationCreate = exports.sendPushOnAnnouncementCreate = exports.onBrandProfileWritten = exports.redirectBrandLead = exports.onOnboardingComplete = exports.redirectLead = exports.reinstateUserAccount = exports.suspendUserAccount = exports.onAuthUserDeleted = exports.deleteAccount = exports.forceLogoutStaffAccount = exports.getStaffLastSignIn = exports.createStaffAccount = exports.backfillCreatedAtFromAuth = exports.instagramOAuthRedirect = exports.refreshConnectedInstagramProfiles = exports.refreshExpiringInstagramTokens = exports.refreshInstagramProfile = exports.disconnectInstagram = exports.exchangeInstagramCode = void 0;
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
const messaging_1 = require("firebase-admin/messaging");
const firestore_2 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
(0, app_1.initializeApp)();
var exchangeInstagramCode_1 = require("./instagram/exchangeInstagramCode");
Object.defineProperty(exports, "exchangeInstagramCode", { enumerable: true, get: function () { return exchangeInstagramCode_1.exchangeInstagramCode; } });
var disconnectInstagram_1 = require("./instagram/disconnectInstagram");
Object.defineProperty(exports, "disconnectInstagram", { enumerable: true, get: function () { return disconnectInstagram_1.disconnectInstagram; } });
var refreshInstagramProfile_1 = require("./instagram/refreshInstagramProfile");
Object.defineProperty(exports, "refreshInstagramProfile", { enumerable: true, get: function () { return refreshInstagramProfile_1.refreshInstagramProfile; } });
var refreshExpiringTokens_1 = require("./instagram/refreshExpiringTokens");
Object.defineProperty(exports, "refreshExpiringInstagramTokens", { enumerable: true, get: function () { return refreshExpiringTokens_1.refreshExpiringInstagramTokens; } });
var refreshConnectedProfiles_1 = require("./instagram/refreshConnectedProfiles");
Object.defineProperty(exports, "refreshConnectedInstagramProfiles", { enumerable: true, get: function () { return refreshConnectedProfiles_1.refreshConnectedInstagramProfiles; } });
var oauthRedirect_1 = require("./instagram/oauthRedirect");
Object.defineProperty(exports, "instagramOAuthRedirect", { enumerable: true, get: function () { return oauthRedirect_1.instagramOAuthRedirect; } });
var backfillCreatedAt_1 = require("./backfillCreatedAt");
Object.defineProperty(exports, "backfillCreatedAtFromAuth", { enumerable: true, get: function () { return backfillCreatedAt_1.backfillCreatedAtFromAuth; } });
var createStaffAccount_1 = require("./createStaffAccount");
Object.defineProperty(exports, "createStaffAccount", { enumerable: true, get: function () { return createStaffAccount_1.createStaffAccount; } });
var staffAccountActions_1 = require("./staffAccountActions");
Object.defineProperty(exports, "getStaffLastSignIn", { enumerable: true, get: function () { return staffAccountActions_1.getStaffLastSignIn; } });
Object.defineProperty(exports, "forceLogoutStaffAccount", { enumerable: true, get: function () { return staffAccountActions_1.forceLogoutStaffAccount; } });
var deleteAccount_1 = require("./deleteAccount");
Object.defineProperty(exports, "deleteAccount", { enumerable: true, get: function () { return deleteAccount_1.deleteAccount; } });
var onAuthUserDeleted_1 = require("./onAuthUserDeleted");
Object.defineProperty(exports, "onAuthUserDeleted", { enumerable: true, get: function () { return onAuthUserDeleted_1.onAuthUserDeleted; } });
var suspendUserAccount_1 = require("./suspendUserAccount");
Object.defineProperty(exports, "suspendUserAccount", { enumerable: true, get: function () { return suspendUserAccount_1.suspendUserAccount; } });
Object.defineProperty(exports, "reinstateUserAccount", { enumerable: true, get: function () { return suspendUserAccount_1.reinstateUserAccount; } });
var redirectLead_1 = require("./leads/redirectLead");
Object.defineProperty(exports, "redirectLead", { enumerable: true, get: function () { return redirectLead_1.redirectLead; } });
var onOnboardingComplete_1 = require("./leads/onOnboardingComplete");
Object.defineProperty(exports, "onOnboardingComplete", { enumerable: true, get: function () { return onOnboardingComplete_1.onOnboardingComplete; } });
var redirectBrandLead_1 = require("./brandLeads/redirectBrandLead");
Object.defineProperty(exports, "redirectBrandLead", { enumerable: true, get: function () { return redirectBrandLead_1.redirectBrandLead; } });
var onBrandProfileWritten_1 = require("./brandLeads/onBrandProfileWritten");
Object.defineProperty(exports, "onBrandProfileWritten", { enumerable: true, get: function () { return onBrandProfileWritten_1.onBrandProfileWritten; } });
var sendPushOnAnnouncementCreate_1 = require("./sendPushOnAnnouncementCreate");
Object.defineProperty(exports, "sendPushOnAnnouncementCreate", { enumerable: true, get: function () { return sendPushOnAnnouncementCreate_1.sendPushOnAnnouncementCreate; } });
/**
 * Sends a push notification whenever a `notifications/{id}` document is
 * created — the client app never talks to FCM's send API directly (it can't;
 * that's server-only), it just writes the notification doc and this
 * function delivers it to whichever device token the recipient last
 * registered.
 */
exports.sendPushOnNotificationCreate = (0, firestore_2.onDocumentCreated)("notifications/{notificationId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot)
        return;
    const notification = snapshot.data();
    const userId = notification.userId;
    if (!userId)
        return;
    const userDoc = await (0, firestore_1.getFirestore)().collection("users").doc(userId).get();
    const user = userDoc.data();
    if (!user)
        return;
    // Respects the Settings screen's push toggle — defaults to enabled
    // since older user docs predate the field.
    if (user.pushNotificationsEnabled === false)
        return;
    const token = user.fcmToken;
    if (!token)
        return;
    try {
        await (0, messaging_1.getMessaging)().send({
            token,
            notification: {
                title: notification.title ?? "Collabsy",
                body: notification.body ?? "",
            },
            data: {
                referenceType: notification.referenceType ?? "",
                referenceId: notification.referenceId ?? "",
            },
        });
    }
    catch (error) {
        firebase_functions_1.logger.error("Failed to send push notification", error);
    }
});

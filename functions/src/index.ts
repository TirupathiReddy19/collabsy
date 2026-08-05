import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";

initializeApp();

export { exchangeInstagramCode } from "./instagram/exchangeInstagramCode";
export { disconnectInstagram } from "./instagram/disconnectInstagram";
export { refreshInstagramProfile } from "./instagram/refreshInstagramProfile";
export { refreshExpiringInstagramTokens } from "./instagram/refreshExpiringTokens";
export { refreshConnectedInstagramProfiles } from "./instagram/refreshConnectedProfiles";
export { instagramOAuthRedirect } from "./instagram/oauthRedirect";
export { backfillCreatedAtFromAuth } from "./backfillCreatedAt";
export { createStaffAccount } from "./createStaffAccount";
export { getStaffLastSignIn, forceLogoutStaffAccount } from "./staffAccountActions";
export { deleteAccount } from "./deleteAccount";
export { onAuthUserDeleted } from "./onAuthUserDeleted";
export { suspendUserAccount, reinstateUserAccount } from "./suspendUserAccount";
export { redirectLead } from "./leads/redirectLead";
export { onOnboardingComplete } from "./leads/onOnboardingComplete";
export { redirectBrandLead } from "./brandLeads/redirectBrandLead";
export { onBrandProfileWritten } from "./brandLeads/onBrandProfileWritten";
export { sendPushOnAnnouncementCreate } from "./sendPushOnAnnouncementCreate";

/**
 * Sends a push notification whenever a `notifications/{id}` document is
 * created — the client app never talks to FCM's send API directly (it can't;
 * that's server-only), it just writes the notification doc and this
 * function delivers it to whichever device token the recipient last
 * registered.
 */
export const sendPushOnNotificationCreate = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const notification = snapshot.data();
    const userId = notification.userId as string | undefined;
    if (!userId) return;

    const userDoc = await getFirestore().collection("users").doc(userId).get();
    const user = userDoc.data();
    if (!user) return;

    // Respects the Settings screen's push toggle — defaults to enabled
    // since older user docs predate the field.
    if (user.pushNotificationsEnabled === false) return;

    const token = user.fcmToken as string | undefined;
    if (!token) return;

    try {
      await getMessaging().send({
        token,
        notification: {
          title: (notification.title as string) ?? "Collabsy",
          body: (notification.body as string) ?? "",
        },
        data: {
          referenceType: (notification.referenceType as string) ?? "",
          referenceId: (notification.referenceId as string) ?? "",
        },
      });
    } catch (error) {
      logger.error("Failed to send push notification", error);
    }
  }
);

import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";

const FCM_MULTICAST_LIMIT = 500;

function chunk<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    chunks.push(items.slice(i, i + size));
  }
  return chunks;
}

/**
 * Given the base role-matched `users` snapshot, narrows it down further per
 * the announcement's `targetType` — re-derived here (not trusted from the
 * client) the same way the role filter above already is, so a targeted
 * broadcast can't over-deliver just because of what the client happened to
 * compute. Returns the subset of `usersSnapshot.docs` that also match.
 */
async function filterByTarget(
  announcement: FirebaseFirestore.DocumentData,
  usersSnapshot: FirebaseFirestore.QuerySnapshot
): Promise<FirebaseFirestore.QueryDocumentSnapshot[]> {
  const targetType = (announcement.targetType as string | undefined) ?? "all";
  if (targetType === "all") return usersSnapshot.docs;

  const firestore = getFirestore();

  if (targetType === "creator") {
    const targetCreatorId = announcement.targetCreatorId as string | undefined;
    if (!targetCreatorId) return [];
    return usersSnapshot.docs.filter((doc) => doc.id === targetCreatorId);
  }

  if (targetType === "brand") {
    const targetBrandId = announcement.targetBrandId as string | undefined;
    if (!targetBrandId) return [];
    return usersSnapshot.docs.filter((doc) => doc.id === targetBrandId);
  }

  if (targetType === "category") {
    const categories = (announcement.targetCategories as string[] | undefined) ?? [];
    if (categories.length === 0) return [];
    // Reused for both Creator "content category" and Brand "industry" —
    // same field, different collection to match against depending on which
    // audience this broadcast is for.
    const collectionName =
      announcement.audience === "brand" ? "brandProfiles" : "creatorProfiles";
    const matchingUids = new Set<string>();
    // `array-contains-any` caps at 10 values per query.
    for (const batch of chunk(categories, 10)) {
      const snapshot = await firestore
        .collection(collectionName)
        .where("categories", "array-contains-any", batch)
        .get();
      snapshot.docs.forEach((doc) => matchingUids.add(doc.id));
    }
    return usersSnapshot.docs.filter((doc) => matchingUids.has(doc.id));
  }

  if (targetType === "followerRange") {
    const min = announcement.targetMinFollowers as number | undefined;
    const max = announcement.targetMaxFollowers as number | undefined;
    let query = firestore.collection("instagram_accounts") as FirebaseFirestore.Query;
    if (min != null) query = query.where("followersCount", ">=", min);
    if (max != null) query = query.where("followersCount", "<=", max);
    const snapshot = await query.get();
    const matchingUids = new Set(snapshot.docs.map((doc) => doc.id));
    return usersSnapshot.docs.filter((doc) => matchingUids.has(doc.id));
  }

  if (targetType === "companySize") {
    const size = announcement.targetCompanySize as string | undefined;
    if (!size) return usersSnapshot.docs;
    const snapshot = await firestore
      .collection("brandProfiles")
      .where("companySize", "==", size)
      .get();
    const matchingUids = new Set(snapshot.docs.map((doc) => doc.id));
    return usersSnapshot.docs.filter((doc) => matchingUids.has(doc.id));
  }

  return usersSnapshot.docs;
}

/**
 * Sends a push notification to every user in a broadcast's audience whenever
 * an `announcements/{id}` document is created. Unlike
 * `sendPushOnNotificationCreate` (one recipient per doc), a single broadcast
 * doc fans out to potentially many device tokens, so this uses
 * `sendEachForMulticast` in batches of 500 (FCM's per-call limit) instead of
 * a single `send()`.
 */
export const sendPushOnAnnouncementCreate = onDocumentCreated(
  "announcements/{announcementId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const announcement = snapshot.data();
    const audience = announcement.audience as string | undefined;
    if (!audience) return;

    const firestore = getFirestore();
    let usersQuery = firestore.collection("users") as FirebaseFirestore.Query;
    if (audience !== "all") {
      usersQuery = usersQuery.where("role", "==", audience);
    }
    const usersSnapshot = await usersQuery.get();
    const targetedDocs = await filterByTarget(announcement, usersSnapshot);

    const tokens: string[] = [];
    for (const doc of targetedDocs) {
      const user = doc.data();
      if (user.pushNotificationsEnabled === false) continue;
      const token = user.fcmToken as string | undefined;
      if (token) tokens.push(token);
    }
    if (tokens.length === 0) return;

    const title = (announcement.title as string) ?? "Collabsy";
    const body = (announcement.body as string) ?? "";

    for (const batch of chunk(tokens, FCM_MULTICAST_LIMIT)) {
      try {
        await getMessaging().sendEachForMulticast({
          tokens: batch,
          notification: { title, body },
          data: { referenceType: "announcement", referenceId: "" },
        });
      } catch (error) {
        logger.error("Failed to send broadcast push batch", error);
      }
    }
  }
);

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";

import { normalizeInstagramHandle } from "./leadsHelpers";
import {
  comingSoonPage,
  desktopLandingPage,
  detectPlatform,
} from "../shared/redirectPages";

/**
 * The public link every generated outreach message points to
 * (`/l/{handle}`, via a Firebase Hosting rewrite). Records the click
 * against the matching `leads/{handle}` doc, then either redirects to
 * the right app store for the visitor's platform or — before the app is
 * published, or on desktop — serves a simple landing page. Mirrors
 * `instagram/oauthRedirect.ts`'s plain `onRequest` shape.
 */
export const redirectLead = onRequest(async (req, res) => {
  const segments = req.path.split("/").filter(Boolean);
  const rawHandle = segments[segments.length - 1] ?? "";
  const handle = normalizeInstagramHandle(rawHandle);

  const firestore = getFirestore();

  if (handle) {
    try {
      const leadRef = firestore.collection("leads").doc(handle);
      const leadDoc = await leadRef.get();
      if (leadDoc.exists) {
        const data = leadDoc.data();
        await leadRef.set(
          {
            clickCount: FieldValue.increment(1),
            clickedAt: data?.clickedAt ?? Timestamp.now(),
            status: data?.status === "linkGenerated" ? "clicked" : data?.status,
          },
          { merge: true }
        );
      }
    } catch (error) {
      logger.error("Failed to record lead click", error);
    }
  }

  const configDoc = await firestore
    .collection("config")
    .doc("outreachLinks")
    .get();
  const config = configDoc.data() ?? {};

  if (config.comingSoonEnabled !== false) {
    res.status(200).send(comingSoonPage());
    return;
  }

  const platform = detectPlatform((req.headers["user-agent"] as string) ?? "");
  const storeUrl =
    platform === "android"
      ? (config.androidStoreUrl as string | undefined)
      : platform === "ios"
        ? (config.iosStoreUrl as string | undefined)
        : undefined;

  if (storeUrl) {
    res.redirect(302, storeUrl);
    return;
  }
  res.status(200).send(desktopLandingPage());
});

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";

import { normalizeLinkedInUrl } from "./brandLeadsHelpers";
import {
  comingSoonPage,
  desktopLandingPage,
  detectPlatform,
} from "../shared/redirectPages";

/**
 * The public link every generated brand-outreach message points to
 * (`/bl/{slug}`, via a Firebase Hosting rewrite on the brand-intern site).
 * Records the click against the matching `brandLeads/{slug}` doc, then
 * either redirects to the right app store for the visitor's platform or —
 * before the app is published, or on desktop — serves a simple landing
 * page. Mirrors `leads/redirectLead.ts` exactly, reading its own
 * `config/brandOutreachLinks` doc (kept separate since the DM copy differs,
 * even though the underlying app/store links are the same).
 */
export const redirectBrandLead = onRequest(async (req, res) => {
  const segments = req.path.split("/").filter(Boolean);
  const rawSlug = segments.slice(1).join("/");
  const slug = normalizeLinkedInUrl(rawSlug);

  const firestore = getFirestore();

  if (slug) {
    try {
      const leadRef = firestore.collection("brandLeads").doc(slug);
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
      logger.error("Failed to record brand lead click", error);
    }
  }

  const configDoc = await firestore
    .collection("config")
    .doc("brandOutreachLinks")
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

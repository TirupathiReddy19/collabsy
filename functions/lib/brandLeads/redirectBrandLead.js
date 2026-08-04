"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.redirectBrandLead = void 0;
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const firebase_functions_1 = require("firebase-functions");
const brandLeadsHelpers_1 = require("./brandLeadsHelpers");
const redirectPages_1 = require("../shared/redirectPages");
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
exports.redirectBrandLead = (0, https_1.onRequest)(async (req, res) => {
    const segments = req.path.split("/").filter(Boolean);
    const rawSlug = segments.slice(1).join("/");
    const slug = (0, brandLeadsHelpers_1.normalizeLinkedInUrl)(rawSlug);
    const firestore = (0, firestore_1.getFirestore)();
    if (slug) {
        try {
            const leadRef = firestore.collection("brandLeads").doc(slug);
            const leadDoc = await leadRef.get();
            if (leadDoc.exists) {
                const data = leadDoc.data();
                await leadRef.set({
                    clickCount: firestore_1.FieldValue.increment(1),
                    clickedAt: data?.clickedAt ?? firestore_1.Timestamp.now(),
                    status: data?.status === "linkGenerated" ? "clicked" : data?.status,
                }, { merge: true });
            }
        }
        catch (error) {
            firebase_functions_1.logger.error("Failed to record brand lead click", error);
        }
    }
    const configDoc = await firestore
        .collection("config")
        .doc("brandOutreachLinks")
        .get();
    const config = configDoc.data() ?? {};
    if (config.comingSoonEnabled !== false) {
        res.status(200).send((0, redirectPages_1.comingSoonPage)());
        return;
    }
    const platform = (0, redirectPages_1.detectPlatform)(req.headers["user-agent"] ?? "");
    const storeUrl = platform === "android"
        ? config.androidStoreUrl
        : platform === "ios"
            ? config.iosStoreUrl
            : undefined;
    if (storeUrl) {
        res.redirect(302, storeUrl);
        return;
    }
    res.status(200).send((0, redirectPages_1.desktopLandingPage)());
});

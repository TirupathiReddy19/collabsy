"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.clientIp = clientIp;
exports.hashKey = hashKey;
exports.enforceRateLimit = enforceRateLimit;
const crypto_1 = require("crypto");
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/v2/https");
const HOUR_MS = 60 * 60 * 1000;
/** The caller's IP as Google's front end saw it. Cloud Run / Cloud Functions
 * APPEND the real client address to X-Forwarded-For, so the LAST entry is the
 * trustworthy one; anything a client types into that header sits to its left
 * and is ignored. Falls back to the socket address. */
function clientIp(request) {
    const forwarded = request.rawRequest?.headers?.["x-forwarded-for"];
    const raw = Array.isArray(forwarded) ? forwarded.join(",") : forwarded;
    if (raw) {
        const parts = raw.split(",").map((p) => p.trim()).filter(Boolean);
        if (parts.length > 0)
            return parts[parts.length - 1];
    }
    return request.rawRequest?.ip ?? "unknown";
}
/** A short, non-reversible key for an address, so the limiter never stores
 * the address itself. */
function hashKey(value) {
    return (0, crypto_1.createHash)("sha256").update(value).digest("hex").slice(0, 32);
}
/**
 * Counts this request against the caller's budget and the form-wide budget
 * inside one Firestore transaction, and throws `resource-exhausted` when
 * either is spent. The form-wide budget is what bounds a flood spread over
 * many addresses. Counters live in `rateLimits/` (Admin SDK only; the
 * rules deny every client) and reset when their window rolls over.
 */
async function enforceRateLimit(request, rule, nowMs = Date.now()) {
    const windowMs = rule.windowMs ?? HOUR_MS;
    const db = (0, firestore_1.getFirestore)();
    const callerRef = db
        .collection("rateLimits")
        .doc(`${rule.bucket}_${hashKey(clientIp(request))}`);
    const globalRef = db.collection("rateLimits").doc(`${rule.bucket}_all`);
    await db.runTransaction(async (tx) => {
        const [callerSnap, globalSnap] = await Promise.all([
            tx.get(callerRef),
            tx.get(globalRef),
        ]);
        const next = (snap, limit) => {
            const data = snap.data();
            const startMs = data?.windowStart?.toMillis();
            if (startMs === undefined || nowMs - startMs >= windowMs) {
                return { count: 1, windowStartMs: nowMs };
            }
            const count = Number(data?.count ?? 0);
            if (count >= limit) {
                throw new https_1.HttpsError("resource-exhausted", "Too many requests. Please try again later.");
            }
            return { count: count + 1, windowStartMs: startMs };
        };
        const caller = next(callerSnap, rule.perCallerLimit);
        const global = next(globalSnap, rule.globalLimit);
        tx.set(callerRef, {
            count: caller.count,
            windowStart: firestore_1.Timestamp.fromMillis(caller.windowStartMs),
        });
        tx.set(globalRef, {
            count: global.count,
            windowStart: firestore_1.Timestamp.fromMillis(global.windowStartMs),
        });
    });
}

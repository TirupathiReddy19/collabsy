import { createHash } from "crypto";

import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { CallableRequest, HttpsError } from "firebase-functions/v2/https";

const HOUR_MS = 60 * 60 * 1000;

/** The caller's IP as Google's front end saw it. Cloud Run / Cloud Functions
 * APPEND the real client address to X-Forwarded-For, so the LAST entry is the
 * trustworthy one; anything a client types into that header sits to its left
 * and is ignored. Falls back to the socket address. */
export function clientIp(request: CallableRequest): string {
  const forwarded = request.rawRequest?.headers?.["x-forwarded-for"];
  const raw = Array.isArray(forwarded) ? forwarded.join(",") : forwarded;
  if (raw) {
    const parts = raw.split(",").map((p) => p.trim()).filter(Boolean);
    if (parts.length > 0) return parts[parts.length - 1];
  }
  return request.rawRequest?.ip ?? "unknown";
}

/** A short, non-reversible key for an address, so the limiter never stores
 * the address itself. */
export function hashKey(value: string): string {
  return createHash("sha256").update(value).digest("hex").slice(0, 32);
}

export interface RateLimitRule {
  /** Which form this budget belongs to, e.g. `campaignRequest`. */
  bucket: string;
  /** Submissions allowed per caller within the window. */
  perCallerLimit: number;
  /** Submissions allowed from everyone combined within the window. */
  globalLimit: number;
  windowMs?: number;
}

/**
 * Counts this request against the caller's budget and the form-wide budget
 * inside one Firestore transaction, and throws `resource-exhausted` when
 * either is spent. The form-wide budget is what bounds a flood spread over
 * many addresses. Counters live in `rateLimits/` (Admin SDK only; the
 * rules deny every client) and reset when their window rolls over.
 */
export async function enforceRateLimit(
  request: CallableRequest,
  rule: RateLimitRule,
  nowMs: number = Date.now()
): Promise<void> {
  const windowMs = rule.windowMs ?? HOUR_MS;
  const db = getFirestore();
  const callerRef = db
    .collection("rateLimits")
    .doc(`${rule.bucket}_${hashKey(clientIp(request))}`);
  const globalRef = db.collection("rateLimits").doc(`${rule.bucket}_all`);

  await db.runTransaction(async (tx) => {
    const [callerSnap, globalSnap] = await Promise.all([
      tx.get(callerRef),
      tx.get(globalRef),
    ]);

    const next = (
      snap: FirebaseFirestore.DocumentSnapshot,
      limit: number
    ): { count: number; windowStartMs: number } => {
      const data = snap.data();
      const startMs = (data?.windowStart as Timestamp | undefined)?.toMillis();
      if (startMs === undefined || nowMs - startMs >= windowMs) {
        return { count: 1, windowStartMs: nowMs };
      }
      const count = Number(data?.count ?? 0);
      if (count >= limit) {
        throw new HttpsError(
          "resource-exhausted",
          "Too many requests. Please try again later."
        );
      }
      return { count: count + 1, windowStartMs: startMs };
    };

    const caller = next(callerSnap, rule.perCallerLimit);
    const global = next(globalSnap, rule.globalLimit);

    tx.set(callerRef, {
      count: caller.count,
      windowStart: Timestamp.fromMillis(caller.windowStartMs),
    });
    tx.set(globalRef, {
      count: global.count,
      windowStart: Timestamp.fromMillis(global.windowStartMs),
    });
  });
}

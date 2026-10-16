import type { Request } from "firebase-functions/v2/https";

/** Link-preview fetchers, crawlers and scripted HTTP clients. They hit an
 * outreach link without a person ever opening it (Instagram/WhatsApp/Slack
 * unfurl a pasted link, search bots index it), so counting them would inflate
 * a lead's `clickCount` and flip its status to "clicked" falsely. Real
 * in-app browsers (Instagram, WhatsApp, Chrome, Safari) are NOT matched. */
const BOT_PATTERN =
  /bot\b|crawler|spider|slurp|facebookexternalhit|meta-externalagent|meta-externalfetcher|whatsapp\/|telegrambot|slackbot|discordbot|twitterbot|linkedinbot|skypeuripreview|embedly|preview|headlesschrome|curl\/|wget\/|python-requests|python-urllib|go-http-client|okhttp\/\d|axios\/|node-fetch|java\//i;

export function isBotUserAgent(userAgent: string): boolean {
  if (!userAgent) return true;
  return BOT_PATTERN.test(userAgent);
}

/** A repeat hit on the same lead inside this window is not counted, which
 * bounds the writes (and the count inflation) any one caller can cause on a
 * single lead document. */
export const CLICK_COOLDOWN_MS = 10_000;

/** Whether this request should be recorded as a click: a real GET (not a
 * HEAD/prefetch probe) from a non-bot client, outside the per-lead
 * cooldown. `lastClickMs` is the lead's previous `lastClickAt`, if any. */
export function shouldRecordClick(
  req: Pick<Request, "method" | "headers">,
  lastClickMs: number | undefined,
  nowMs: number = Date.now()
): boolean {
  if (req.method !== "GET") return false;
  if (isBotUserAgent((req.headers["user-agent"] as string | undefined) ?? "")) {
    return false;
  }
  if (lastClickMs !== undefined && nowMs - lastClickMs < CLICK_COOLDOWN_MS) {
    return false;
  }
  return true;
}

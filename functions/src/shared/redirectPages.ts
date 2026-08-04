/**
 * Small platform-detection + landing-page helpers shared by every outreach
 * tool's public redirect endpoint (`leads/redirectLead.ts`,
 * `brandLeads/redirectBrandLead.ts`) — identical behavior regardless of
 * which outreach funnel the click came from, since they all point at the
 * same Collabsy app/store listings.
 */

export function detectPlatform(userAgent: string): "android" | "ios" | "other" {
  const ua = userAgent.toLowerCase();
  if (ua.includes("android")) return "android";
  if (/iphone|ipad|ipod/.test(ua)) return "ios";
  return "other";
}

export function comingSoonPage(): string {
  return `<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Collabsy — Coming Soon</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; padding: 48px 24px; }
      h1 { color: #FF6B35; }
    </style>
  </head>
  <body>
    <h1>Collabsy</h1>
    <p>We're launching soon — thanks for your interest! We'll let you know the moment the app is live.</p>
  </body>
</html>`;
}

export function desktopLandingPage(): string {
  return `<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Collabsy</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; text-align: center; padding: 48px 24px; }
      h1 { color: #FF6B35; }
    </style>
  </head>
  <body>
    <h1>Collabsy</h1>
    <p>Open this link on your phone to download the app.</p>
  </body>
</html>`;
}

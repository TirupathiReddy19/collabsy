# Collabsy staging environment

A fully local copy of the website, admin portal, and both outreach tools,
running against the **Firebase Local Emulator Suite** instead of production.
It is the safe place to point a scanner (Strix, OWASP ZAP, Burp, etc.) —
everything runs on `localhost`, nothing ever reaches the real database,
the real users, or the real Google Cloud project.

## Why the emulator suite instead of a second cloud project

- **Free.** No new Firebase project, no billing account, no cost risk.
- **Isolated by construction.** Everything runs under the fake project id
  `demo-collabsy`. The Firebase CLI's documented behavior for any
  `demo-`-prefixed project id is to skip all production communication
  entirely — not just Firestore/Auth, every API call stays local.
- **Real rules, real code.** It loads the actual `firestore.rules` and
  `storage.rules` from the repo root, and runs the actual Cloud Functions
  source — so a security finding here reflects a real gap, not a staging
  shortcut.
- **One exception, deliberately disabled here:** `getCrashAnalytics` calls
  BigQuery directly (not through any Firebase emulator), so it would
  otherwise reach the real BigQuery dataset using this machine's real
  Google credentials. It's guarded to return empty data whenever
  `FUNCTIONS_EMULATOR=true` (see `functions/src/admin/getCrashAnalytics.ts`).
  The Instagram OAuth functions (`exchangeInstagramCode` and friends) will
  just fail cleanly here too — they need a real `instagramAppSecret`, which
  only exists in the real project's Secret Manager and is never present on
  this machine's filesystem.

## One-time setup

```bash
cd staging
npm install
```

## Running it

Three steps, each in this order:

```bash
# 1. Build the four web apps pointed at the emulator (takes a few minutes)
npm run build

# 2. Start the emulator suite (keep this running in its own terminal)
npm start

# 3. In a second terminal, seed it with fake accounts and data
npm run seed
```

Then open:

| Site | URL |
|---|---|
| Website | http://localhost:5000 |
| Admin portal | http://localhost:5005 |
| Creator/intern outreach tool | http://localhost:5006 |
| Brand outreach tool | http://localhost:5007 |
| Emulator UI (inspect Firestore/Auth data live) | http://localhost:4000 |

(`firebase.staging.json` only controls the first hosting port; the CLI
auto-assigns the rest on each start. Check the "All emulators ready" banner
it prints — reported here is what it assigned this time, and there's no
guarantee the same ports repeat on the next `npm start`.)

Sign-in accounts `npm run seed` creates (all fake, emulator-only):

| Who | Credential |
|---|---|
| Admin portal | `admin@collabsy.online` / `StagingAdmin123!` |
| Intern & brand outreach tools | `staff@collabsy.online` / `StagingStaff123!` |
| Creator (mobile app, not staged here) | phone `+919000000001`, any 6-digit OTP |
| Brand (mobile app, not staged here) | `brand@example.test` / `StagingBrand123!` |

## Pointing a scanner at it

Point Strix, ZAP, or whatever you use at the `localhost` URLs above. Treat
the whole `5000`–`5004` + `9099`/`8080`/`5001`/`9199` range as the scope —
nothing else on this machine should be in scope.

Stopping the emulator (`Ctrl+C` in the `npm start` terminal) discards all
seeded data; run `npm run seed` again next time.

**If a browser tab was ever pointed at one of these URLs before you last
ran `npm run build`:** Flutter web registers a service worker that caches
the app aggressively, so a plain reload can keep showing the old build
indefinitely. Hard-refresh (Ctrl+Shift+R) or open the URL in a private
window if something looks stale.

## Pointing Strix at it

[Strix](https://github.com/usestrix/strix) is an agentic scanner that drives
its own browser inside its own Docker sandbox container — which is why
`firebase.staging.json` binds every emulator to `0.0.0.0` (not the default
`127.0.0.1`) and `lib/core/config/emulator_config.dart` picks the Firestore/
Auth/Functions/Storage host dynamically from whatever hostname the page was
actually loaded through, instead of a hardcoded `localhost`. Loopback
addresses mean something different inside Strix's container than they do on
this machine, so both of those matter — without them the page would load but
every Firestore/Auth call inside it would silently fail.

1. **Install** (needs Docker running):
   ```bash
   curl -sSL https://strix.ai/install | bash
   ```
2. **Set your own Anthropic API key** — this is Strix's own LLM usage, billed
   separately from anything else:
   ```bash
   export STRIX_LLM="anthropic/claude-sonnet-4-6"
   export LLM_API_KEY="your-api-key"
   ```
3. **Run it**, using `host.docker.internal` (what Docker Desktop resolves to
   this machine from inside a container) instead of `localhost`:
   ```bash
   strix -n --scan-mode standard \
     -t http://host.docker.internal:5000 \
     -t http://host.docker.internal:5005 \
     -t http://host.docker.internal:5006 \
     -t http://host.docker.internal:5007 \
     --instruction "Sign-in accounts: admin@collabsy.online / StagingAdmin123! for the admin portal; staff@collabsy.online / StagingStaff123! for the outreach tools. This is a local emulator with fake data — destructive actions (deleting data, suspending accounts, exhausting rate limits) are expected and fine to try; nothing here is real."
   ```
   If `host.docker.internal` doesn't resolve from inside the container on
   your setup, use this machine's LAN IP instead (`ipconfig` → the Wi-Fi/
   Ethernet adapter's IPv4 address) — the 0.0.0.0 binding works the same way
   either way, which is how this was actually verified (not with
   `host.docker.internal` itself, which needs Docker to test directly).
4. Start with `--scan-mode quick` or `standard` first — `deep` (the CLI
   default when you omit `-m`) costs and takes substantially more. `-n`
   exits non-zero when it finds something; add `--fail-on high` to only fail
   on high/critical.
5. **Don't include the Emulator UI** (port 4000) as a target — that's
   Firebase's own tooling, not part of Collabsy, and scanning it tells you
   nothing useful.
6. View results afterward with `strix view`. Reset staging to a clean state
   (`Ctrl+C` the `npm start` terminal, `npm start` again, `npm run seed`
   again) whenever you want to rerun from scratch.

## What this does not cover

- The **mobile app** (Android/iOS) isn't wired to the emulator — staging
  here is web-only, matching the website/admin/outreach-tool scope. The
  creator and brand accounts seeded above exist so the admin portal and
  outreach tools have real-looking data to render, not so you can sign in
  to a staged mobile app.
- **Instagram OAuth** fails cleanly (see above) — there's nothing to scan
  there without the real Meta app secret.
- This is a snapshot of the **current rules and functions**, not of a
  specific release; rebuild (`npm run build`) after pulling new changes.

## Files

- `../firebase.staging.json` — the emulator-only Firebase config (separate
  from the real `firebase.json`, which is what `firebase deploy` reads —
  this file is never passed to `deploy`).
- `../lib/core/config/emulator_config.dart` — the Flutter-side switch; only
  active when a build passes `--dart-define=USE_FIREBASE_EMULATOR=true`,
  which only `npm run build` here does. A normal `flutter build web` (and
  every production deploy) never sets this, so production is unaffected.
- `seed.js` — writes the fake accounts/data above into the emulator.
- `build.js` — builds the four web targets into `build/staging/web-*`
  (separate from `build/web-*`, which `firebase deploy` reads).

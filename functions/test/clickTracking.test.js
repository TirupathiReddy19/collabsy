const test = require('node:test');
const assert = require('node:assert');
const { isBotUserAgent, shouldRecordClick, CLICK_COOLDOWN_MS } = require('../lib/shared/clickTracking');

const IG_IOS = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21F90 Instagram 340.0.0.30.109 (iPhone15,2; iOS 17_5; en_IN; en; scale=3.00; 1170x2532; 640000000)';
const CHROME_ANDROID = 'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36';
const SAFARI_IOS = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';
const req = (ua, method = 'GET') => ({ method, headers: { 'user-agent': ua } });

test('real browsers and in-app browsers are not bots', () => {
  for (const ua of [IG_IOS, CHROME_ANDROID, SAFARI_IOS]) assert.strictEqual(isBotUserAgent(ua), false, ua);
});

test('link-preview fetchers, crawlers and scripts are bots', () => {
  for (const ua of [
    'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uagent.php)',
    'meta-externalagent/1.1 (+https://developers.facebook.com/docs/sharing/webmasters/crawler)',
    'WhatsApp/2.23.20.0 A', 'Slackbot-LinkExpanding 1.0', 'Twitterbot/1.0',
    'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
    'curl/8.4.0', 'python-requests/2.31.0', 'Go-http-client/2.0', '',
  ]) assert.strictEqual(isBotUserAgent(ua), true, ua);
});

test('only a non-bot GET outside the cooldown is recorded', () => {
  const now = 1_000_000;
  assert.strictEqual(shouldRecordClick(req(CHROME_ANDROID), undefined, now), true);
  assert.strictEqual(shouldRecordClick(req(CHROME_ANDROID, 'HEAD'), undefined, now), false);
  assert.strictEqual(shouldRecordClick(req('curl/8.4.0'), undefined, now), false);
  assert.strictEqual(shouldRecordClick(req(CHROME_ANDROID), now - 1000, now), false);
  assert.strictEqual(shouldRecordClick(req(CHROME_ANDROID), now - CLICK_COOLDOWN_MS, now), true);
});

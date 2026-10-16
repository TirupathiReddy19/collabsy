// Runs against the LOCAL Firestore emulator only (demo project), never
// production:
//   cd tests/firestore-rules && npm run test:functions
process.env.GCLOUD_PROJECT = 'demo-collabsy';
if (!process.env.FIRESTORE_EMULATOR_HOST) {
  throw new Error('Run this through the Firestore emulator (see the header comment).');
}

const test = require('node:test');
const assert = require('node:assert');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

initializeApp({ projectId: 'demo-collabsy' });
const { enforceRateLimit } = require('../lib/publicForms/rateLimit');

const callAs = (ip) => ({ rawRequest: { headers: { 'x-forwarded-for': ip }, ip } });
const rule = (over = {}) => ({ bucket: 'test', perCallerLimit: 3, globalLimit: 5, ...over });
const status = async (fn) => {
  try { await fn(); return 'ok'; } catch (e) { return e.code; }
};

test.beforeEach(async () => {
  const snap = await getFirestore().collection('rateLimits').get();
  await Promise.all(snap.docs.map((d) => d.ref.delete()));
});

test('one caller is stopped after its limit, others are not', async () => {
  for (let i = 0; i < 3; i++) await enforceRateLimit(callAs('203.0.113.1'), rule());
  assert.strictEqual(await status(() => enforceRateLimit(callAs('203.0.113.1'), rule())), 'resource-exhausted');
  assert.strictEqual(await status(() => enforceRateLimit(callAs('203.0.113.2'), rule())), 'ok');
});

test('the form-wide limit stops a flood spread over many addresses', async () => {
  for (let i = 1; i <= 5; i++) await enforceRateLimit(callAs(`203.0.113.${i}`), rule());
  assert.strictEqual(await status(() => enforceRateLimit(callAs('198.51.100.77'), rule())), 'resource-exhausted');
});

test('the counters reset once the window has passed', async () => {
  const t0 = 1_000_000_000_000;
  for (let i = 0; i < 3; i++) await enforceRateLimit(callAs('203.0.113.1'), rule(), t0);
  assert.strictEqual(await status(() => enforceRateLimit(callAs('203.0.113.1'), rule(), t0 + 60_000)), 'resource-exhausted');
  assert.strictEqual(await status(() => enforceRateLimit(callAs('203.0.113.1'), rule(), t0 + 61 * 60_000)), 'ok');
});

test('separate forms keep separate budgets', async () => {
  for (let i = 0; i < 3; i++) await enforceRateLimit(callAs('203.0.113.1'), rule({ bucket: 'a' }));
  assert.strictEqual(await status(() => enforceRateLimit(callAs('203.0.113.1'), rule({ bucket: 'a' }))), 'resource-exhausted');
  assert.strictEqual(await status(() => enforceRateLimit(callAs('203.0.113.1'), rule({ bucket: 'b' }))), 'ok');
});

test('stored counters never contain the raw address', async () => {
  await enforceRateLimit(callAs('203.0.113.1'), rule());
  const snap = await getFirestore().collection('rateLimits').get();
  for (const d of snap.docs) {
    assert.ok(!d.id.includes('203.0.113.1'), d.id);
    assert.ok(!JSON.stringify(d.data()).includes('203.0.113.1'));
  }
});

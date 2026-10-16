const test = require('node:test');
const assert = require('node:assert');
const { parseCampaignRequest, parseDeletionRequest } = require('../lib/publicForms/validation');
const { clientIp, hashKey } = require('../lib/publicForms/rateLimit');

const validCampaign = () => ({
  companyName: 'Acme Foods',
  contactName: 'Asha Rao',
  workEmail: 'asha@acme.example',
  phone: '+919000000001',
  budgetRange: '50k_2l',
  campaignBrief: 'Launching a new snack range and need 20 micro-influencers.',
});

const rejects = (fn, code = 'invalid-argument') =>
  assert.throws(fn, (e) => e.code === code, `expected ${code}`);

test('a valid campaign request is accepted and trimmed', () => {
  const out = parseCampaignRequest({ ...validCampaign(), companyName: '  Acme Foods  ' });
  assert.strictEqual(out.companyName, 'Acme Foods');
  assert.strictEqual(out.budgetRange, '50k_2l');
});

test('phone is optional', () => {
  const { phone, ...rest } = validCampaign();
  assert.strictEqual(parseCampaignRequest(rest).phone, undefined);
  assert.strictEqual(parseCampaignRequest({ ...rest, phone: '   ' }).phone, undefined);
});

test('campaign request rejects missing, wrong-type and oversized fields', () => {
  rejects(() => parseCampaignRequest(null));
  rejects(() => parseCampaignRequest([]));
  rejects(() => parseCampaignRequest({ ...validCampaign(), companyName: '' }));
  rejects(() => parseCampaignRequest({ ...validCampaign(), companyName: 42 }));
  rejects(() => parseCampaignRequest({ ...validCampaign(), companyName: 'x'.repeat(200) }));
  rejects(() => parseCampaignRequest({ ...validCampaign(), campaignBrief: 'x'.repeat(3000) }));
  rejects(() => parseCampaignRequest({ ...validCampaign(), phone: '9'.repeat(40) }));
});

test('campaign request rejects a bad email or budget range', () => {
  rejects(() => parseCampaignRequest({ ...validCampaign(), workEmail: 'not-an-email' }));
  rejects(() => parseCampaignRequest({ ...validCampaign(), workEmail: 'a b@c.d' }));
  rejects(() => parseCampaignRequest({ ...validCampaign(), budgetRange: 'unlimited' }));
  rejects(() => parseCampaignRequest({ ...validCampaign(), budgetRange: undefined }));
});

test('campaign request ignores extra fields instead of storing them', () => {
  const out = parseCampaignRequest({ ...validCampaign(), status: 'approved', isAdmin: true });
  assert.deepStrictEqual(Object.keys(out).sort(), [
    'budgetRange', 'campaignBrief', 'companyName', 'contactName', 'phone', 'workEmail',
  ]);
});

test('deletion request: identifier required, reason optional and capped', () => {
  assert.deepStrictEqual(parseDeletionRequest({ identifier: ' a@b.example ' }), {
    identifier: 'a@b.example', reason: undefined,
  });
  rejects(() => parseDeletionRequest({}));
  rejects(() => parseDeletionRequest({ identifier: 'x'.repeat(200) }));
  rejects(() => parseDeletionRequest({ identifier: 'a@b.example', reason: 'x'.repeat(1000) }));
  rejects(() => parseDeletionRequest({ identifier: 'a@b.example', reason: 7 }));
});

test('clientIp trusts the LAST forwarded address, not one the caller typed', () => {
  const req = (h, ip) => ({ rawRequest: { headers: h, ip } });
  assert.strictEqual(clientIp(req({ 'x-forwarded-for': '6.6.6.6, 203.0.113.9' })), '203.0.113.9');
  assert.strictEqual(clientIp(req({ 'x-forwarded-for': '203.0.113.9' })), '203.0.113.9');
  assert.strictEqual(clientIp(req({}, '198.51.100.4')), '198.51.100.4');
  assert.strictEqual(clientIp(req({})), 'unknown');
});

test('hashKey is stable, short and does not contain the address', () => {
  assert.strictEqual(hashKey('203.0.113.9'), hashKey('203.0.113.9'));
  assert.notStrictEqual(hashKey('203.0.113.9'), hashKey('203.0.113.10'));
  assert.strictEqual(hashKey('203.0.113.9').length, 32);
  assert.ok(!hashKey('203.0.113.9').includes('203'));
});

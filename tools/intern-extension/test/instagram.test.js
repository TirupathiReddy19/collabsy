const test = require('node:test');
const assert = require('node:assert/strict');
const {
  handleFromPath,
  cleanBioText,
  headerMatchesHandle,
} = require('../instagram.js');

test('recognises profile pages and lowercases the handle', () => {
  assert.equal(handleFromPath('/priya.sharma/'), 'priya.sharma');
  assert.equal(handleFromPath('/Priya_Official'), 'priya_official');
  assert.equal(handleFromPath('/priya.sharma/reels/'), 'priya.sharma');
  assert.equal(handleFromPath('/priya.sharma/tagged/'), 'priya.sharma');
});

test('ignores non-profile pages', () => {
  assert.equal(handleFromPath('/'), null);
  assert.equal(handleFromPath('/explore/'), null);
  assert.equal(handleFromPath('/reels/'), null);
  assert.equal(handleFromPath('/direct/inbox/'), null);
  assert.equal(handleFromPath('/p/Cabc123/'), null);
  assert.equal(handleFromPath('/accounts/login/'), null);
  assert.equal(handleFromPath('/priya.sharma/followers/'), null);
});

test('rejects handles with characters Instagram does not allow', () => {
  assert.equal(handleFromPath('/not a handle/'), null);
  assert.equal(handleFromPath('/' + 'a'.repeat(31) + '/'), null);
});

test('cleans and caps bio text', () => {
  assert.equal(cleanBioText('  hello world  '), 'hello world');
  assert.equal(cleanBioText(null), '');
  assert.equal(cleanBioText('x'.repeat(5000)).length, 4000);
});

test('header must contain the handle as a whole word', () => {
  const header = 'priya.sharma\nFollow\n1,204 posts\nFashion ✨ hello@gmail.com';
  assert.equal(headerMatchesHandle(header, 'priya.sharma'), true);
  assert.equal(headerMatchesHandle(header.toUpperCase(), 'priya.sharma'), true);
  // Stale header from the previous profile:
  assert.equal(headerMatchesHandle(header, 'rohan_codes'), false);
  // Prefix collision must not count as a match:
  assert.equal(headerMatchesHandle(header, 'priya'), false);
  assert.equal(headerMatchesHandle('', 'priya.sharma'), false);
});

// Security tests for firestore.rules. Runs ONLY against the local Firestore
// emulator (project "demo-collabsy" never touches production data):
//
//   cd tests/firestore-rules && npm test
//
// Every test asserts the SECURE behavior. A failing test is a real hole in
// the rules, not a bad test.

const fs = require('node:fs');
const path = require('node:path');
const { describe, it, before, after, beforeEach } = require('node:test');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  collection,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
  deleteDoc,
  addDoc,
  serverTimestamp,
  increment,
  arrayUnion,
  setLogLevel,
} = require('firebase/firestore');

setLogLevel('error');

let testEnv;

const ADMIN_EMAIL = 'admin@collabsy.online';
const as = (uid, claims = {}) =>
  testEnv.authenticatedContext(uid, claims).firestore();
const anon = () => testEnv.unauthenticatedContext().firestore();
const admin = () =>
  as('adminUid', { email: ADMIN_EMAIL, email_verified: true });
const staff = (uid) => as(uid);

const ok = assertSucceeds;
const fails = assertFails;

async function seed() {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    const put = (p, data) => setDoc(doc(db, p), data);

    await put('users/creatorA', {
      role: 'creator', displayName: 'Creator A',
      email: 'creator.a@example.com', phone: '+919000000001',
      fcmToken: 'fcm-token-A', suspended: false,
    });
    await put('users/creatorB', {
      role: 'creator', displayName: 'Creator B',
      email: 'creator.b@example.com', phone: '+919000000002',
      fcmToken: 'fcm-token-B',
    });
    await put('users/brandA', { role: 'brand', displayName: 'Brand A', email: 'a@brand.example' });
    await put('users/brandB', { role: 'brand', displayName: 'Brand B', email: 'b@brand.example' });
    await put('users/suspendedC', { role: 'creator', suspended: true, suspendedReason: 'spam' });

    const perms = (p) => ({ active: true, permissions: p });
    await put('staffAccounts/internUid', perms({ '/outreach-leads': true }));
    await put('staffAccounts/otherIntern', perms({ '/outreach-leads': true }));
    await put('staffAccounts/supportStaff', perms({ '/support': true }));
    await put('staffAccounts/verifier', perms({ '/verification/creators': true }));
    await put('staffAccounts/reviewer', perms({ '/campaigns/review': true }));
    await put('staffAccounts/trustStaff', perms({ '/trust-safety': true }));
    await put('staffAccounts/broadcaster', perms({ '/broadcast': true }));
    await put('staffAccounts/auditor', perms({ '/audit': true }));
    await put('staffAccounts/disabledStaff', {
      active: false, permissions: { '/outreach-leads': true, '/support': true },
    });

    await put('creatorProfiles/creatorA', { verificationStatus: 'pending', bio: 'old' });
    await put('brandProfiles/brandA', { verificationStatus: 'pending', bio: 'old' });

    await put('campaigns/cUnderReview', {
      brandId: 'brandA', status: 'underReview', title: 'Glow', viewCount: 0, viewedByCreatorIds: [],
    });
    await put('campaigns/cActive', {
      brandId: 'brandA', status: 'active', title: 'Live', viewCount: 0, viewedByCreatorIds: [],
    });

    for (const [id, status] of [['cPaused', 'paused'], ['cClosed', 'closed'], ['cExpired', 'expired']]) {
      await put(`campaigns/${id}`, {
        brandId: 'brandA', status, title: id, viewCount: 0, viewedByCreatorIds: [],
      });
    }
    await put('campaigns/cViewed', {
      brandId: 'brandA', status: 'active', title: 'Viewed', viewCount: 3, viewedByCreatorIds: ['creatorB'],
    });
    await put('staffAccounts/brandInternUid', perms({ '/brand-outreach-leads': true }));

    await put('applications/app1', {
      creatorId: 'creatorA', brandId: 'brandA', campaignId: 'cActive', status: 'pending',
    });
    await put('deliverables/delPending', {
      creatorId: 'creatorA', brandId: 'brandA', status: 'pending',
    });
    await put('deliverables/delSubmitted', {
      creatorId: 'creatorA', brandId: 'brandA', status: 'submitted',
    });

    await put('chats/chat1', { creatorId: 'creatorA', brandId: 'brandA', status: 'active' });
    await put('chats/chat1/messages/m1', { senderId: 'creatorA', text: 'hi' });
    // Real deterministic id (see ChatRepository.chatId), for the
    // isChatPartnerOf() rule tests — chat1 above predates that convention.
    await put('chats/brandA_creatorA', { creatorId: 'creatorA', brandId: 'brandA', status: 'active' });
    await put('blocks/brandB_creatorA', { blockerId: 'brandB', blockedId: 'creatorA' });

    await put('notifications/n1', {
      userId: 'creatorA', type: 'newMessage', title: 't', body: 'b', read: false,
    });

    await put('reports/r1', { reporterId: 'creatorA' });

    await put('instagram_accounts/creatorA', { username: 'creator_a', status: 'connected' });
    await put('instagram_accounts/creatorA/private/tokens', { accessToken: 'SECRET-TOKEN' });
    await put('instagram_media/media1', { userId: 'creatorA' });

    await put('leads/lead1', {
      internId: 'internUid', status: 'linkGenerated', clickCount: 0,
      internConfirmedSent: false, followUpCount: 0,
    });
    await put('leads/leadOther', {
      internId: 'otherIntern', status: 'linkGenerated', clickCount: 0,
      internConfirmedSent: false, followUpCount: 0,
    });
    await put('internShiftStats/internUid_2026-10-05', {
      internId: 'internUid', internEmail: 'i@x.com', date: '2026-10-05', activeSeconds: 30,
    });

    await put('supportChats/t1', { userId: 'creatorA', status: 'open' });
    await put('supportChats/t1/messages/sm1', { text: 'help', senderRole: 'user' });
    await put('announcements/a1', { title: 'Hello' });
    await put('config/outreachLinks', { messageTemplate: 'hi' });
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-collabsy',
    firestore: {
      rules: fs.readFileSync(
        path.join(__dirname, '..', '..', 'firestore.rules'),
        'utf8',
      ),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed();
});

describe('signed-out visitors', () => {
  it('cannot read or write core collections', async () => {
    const db = anon();
    await fails(getDoc(doc(db, 'users/creatorA')));
    await fails(getDoc(doc(db, 'campaigns/cActive')));
    await fails(getDoc(doc(db, 'instagram_accounts/creatorA')));
    await fails(getDocs(collection(db, 'users')));
    await fails(setDoc(doc(db, 'users/hacker'), { role: 'creator' }));
  });

  // The public website forms go through the submitDeletionRequest /
  // submitCampaignRequest Cloud Functions (validation + rate limiting, Admin
  // SDK). No client may create these documents directly, even a perfectly
  // well-formed one, so a script can't bypass the limits by calling
  // Firestore itself.
  it('cannot create an account deletion request directly, even a well-formed one', async () => {
    const valid = {
      identifier: 'user@example.com', reason: 'leaving', status: 'pending',
      createdAt: serverTimestamp(),
    };
    await fails(setDoc(doc(anon(), 'accountDeletionRequests/r1'), valid));
    await fails(setDoc(doc(as('creatorA'), 'accountDeletionRequests/r2'), valid));
    await fails(getDoc(doc(anon(), 'accountDeletionRequests/r1')));
  });

  it('cannot create a campaign request directly, even a well-formed one', async () => {
    const valid = {
      companyName: 'Acme', contactName: 'Priya', workEmail: 'p@acme.com',
      budgetRange: 'under_50k', campaignBrief: 'Launch', status: 'new',
      createdAt: serverTimestamp(),
    };
    await fails(setDoc(doc(anon(), 'campaignRequests/c1'), valid));
    await fails(setDoc(doc(as('brandA'), 'campaignRequests/c2'), valid));
    await fails(getDoc(doc(anon(), 'campaignRequests/c1')));
  });

  it('cannot touch the rate-limit counters', async () => {
    await fails(setDoc(doc(anon(), 'rateLimits/campaignRequest_all'), { count: 0 }));
    await fails(getDoc(doc(as('creatorA'), 'rateLimits/campaignRequest_all')));
    await fails(setDoc(doc(admin(), 'rateLimits/campaignRequest_all'), { count: 0 }));
  });

  it('staff can still read and triage the queues', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'campaignRequests/cq'), { status: 'new', companyName: 'A' });
      await setDoc(doc(ctx.firestore(), 'accountDeletionRequests/dq'), { status: 'pending', identifier: 'x' });
    });
    await ok(getDoc(doc(admin(), 'campaignRequests/cq')));
    await ok(updateDoc(doc(admin(), 'campaignRequests/cq'), { status: 'contacted' }));
    await ok(getDoc(doc(admin(), 'accountDeletionRequests/dq')));
    await ok(updateDoc(doc(admin(), 'accountDeletionRequests/dq'), { status: 'done' }));
  });
});

describe('privilege escalation', () => {
  it('a user cannot make themselves an admin or an unknown role', async () => {
    await fails(updateDoc(doc(as('creatorA'), 'users/creatorA'), { role: 'admin' }));
    await fails(updateDoc(doc(as('creatorA'), 'users/creatorA'), { role: 'superuser' }));
  });

  it('a user can edit their own profile fields', async () => {
    await ok(updateDoc(doc(as('creatorA'), 'users/creatorA'), { displayName: 'New Name' }));
  });

  it('a user cannot edit someone else', async () => {
    await fails(updateDoc(doc(as('creatorA'), 'users/creatorB'), { displayName: 'pwned' }));
  });

  it('a suspended user cannot un-suspend themselves; others cannot self-suspend', async () => {
    await fails(updateDoc(doc(as('suspendedC'), 'users/suspendedC'), { suspended: false }));
    await fails(updateDoc(doc(as('creatorA'), 'users/creatorA'), { suspended: true }));
    await fails(updateDoc(doc(as('creatorA'), 'users/creatorA'), { suspendedReason: 'x' }));
  });

  it('a creator cannot approve their own profile verification', async () => {
    const db = as('creatorA');
    await fails(updateDoc(doc(db, 'creatorProfiles/creatorA'), { verificationStatus: 'approved' }));
    await ok(setDoc(doc(db, 'creatorProfiles/creatorA'), { bio: 'new bio' }, { merge: true }));
  });

  it('a brand cannot approve their own profile verification', async () => {
    const db = as('brandA');
    await fails(updateDoc(doc(db, 'brandProfiles/brandA'), { verificationStatus: 'approved' }));
    await ok(setDoc(doc(db, 'brandProfiles/brandA'), { bio: 'new bio' }, { merge: true }));
  });

  it('a new creator cannot create their profile already approved', async () => {
    await fails(
      setDoc(doc(as('newCreator'), 'creatorProfiles/newCreator'), {
        verificationStatus: 'approved', bio: 'x',
      }),
    );
  });

  it('only staff with the right permission can verify creators', async () => {
    const patch = { verificationStatus: 'approved' };
    await ok(updateDoc(doc(staff('verifier'), 'creatorProfiles/creatorA'), patch));
    await fails(updateDoc(doc(staff('supportStaff'), 'creatorProfiles/creatorA'), patch));
    await fails(updateDoc(doc(staff('disabledStaff'), 'creatorProfiles/creatorA'), patch));
  });

  it('staff cannot edit their own permissions or reactivate themselves', async () => {
    await fails(
      updateDoc(doc(staff('supportStaff'), 'staffAccounts/supportStaff'), {
        permissions: { '/support': true, '/audit': true },
      }),
    );
    await fails(updateDoc(doc(staff('disabledStaff'), 'staffAccounts/disabledStaff'), { active: true }));
    await fails(getDoc(doc(as('creatorA'), 'staffAccounts/supportStaff')));
  });

  it('collections without a rule are closed, even to admin', async () => {
    await fails(getDoc(doc(admin(), 'secrets/anything')));
    await fails(setDoc(doc(as('creatorA'), 'secrets/anything'), { x: 1 }));
  });
});

describe('admin identity', () => {
  it('the real, verified admin account is recognised', async () => {
    await ok(getDoc(doc(admin(), 'reports/r1')));
  });

  it('look-alike emails are not admin', async () => {
    const fake = as('x', { email: 'admin@collabsy.online.evil.com', email_verified: true });
    await fails(getDoc(doc(fake, 'reports/r1')));
  });

  // Not enforced yet: requiring email_verified locked the real admin out
  // (its email is unverified in Firebase Auth), so it was reverted.
  it('an UNVERIFIED token with the admin email is not admin', { todo: 'GAP E1: isAdmin() never checks email_verified (admin email must be verified first)' }, async () => {
    const unverified = as('attacker', { email: ADMIN_EMAIL, email_verified: false });
    await fails(getDoc(doc(unverified, 'reports/r1')));
    const noClaim = as('attacker2', { email: ADMIN_EMAIL });
    await fails(getDoc(doc(noClaim, 'reports/r1')));
  });
});

describe('personal data exposure', () => {
  // users/{uid} holds email, phone and fcmToken, and the rule lets ANY
  // signed-in account read every one of them.
  it("another signed-in user cannot read someone's email/phone/FCM token", { todo: 'GAP U1: users/{uid} (email, phone, fcmToken) is readable by any signed-in user' }, async () => {
    await fails(getDoc(doc(as('creatorB'), 'users/creatorA')));
  });

  it('a signed-in user cannot bulk-list every user', { todo: 'GAP U1: any signed-in user can list the whole users collection' }, async () => {
    await fails(getDocs(collection(as('creatorB'), 'users')));
  });

  it('a user can still read their own record', async () => {
    await ok(getDoc(doc(as('creatorA'), 'users/creatorA')));
  });

  it("private/contact (email, fcmToken) is self- and admin-only", async () => {
    await ok(setDoc(doc(as('creatorA'), 'users/creatorA/private/contact'),
      { email: 'creator.a@example.com', fcmToken: 'tok' }));
    await ok(getDoc(doc(as('creatorA'), 'users/creatorA/private/contact')));
    await ok(getDoc(doc(admin(), 'users/creatorA/private/contact')));
    await fails(getDoc(doc(as('creatorB'), 'users/creatorA/private/contact')));
    await fails(setDoc(doc(as('creatorB'), 'users/creatorA/private/contact'),
      { email: 'hijack@example.com' }));
    await fails(setDoc(doc(as('creatorA'), 'users/creatorA/private/contact'),
      { email: 'x@example.com', phone: '+910000000000' }));
  });

  it('private/phone is self- and admin-readable, PLUS the other side of a shared chat — nobody else', async () => {
    await ok(setDoc(doc(as('creatorA'), 'users/creatorA/private/phone'), { phone: '+919000000001' }));
    await ok(getDoc(doc(as('creatorA'), 'users/creatorA/private/phone')));
    await ok(getDoc(doc(admin(), 'users/creatorA/private/phone')));
    // brandA shares the chats/brandA_creatorA thread with creatorA.
    await ok(getDoc(doc(as('brandA'), 'users/creatorA/private/phone')));
    // creatorB has no chat with creatorA at all.
    await fails(getDoc(doc(as('creatorB'), 'users/creatorA/private/phone')));
    await fails(setDoc(doc(as('brandA'), 'users/creatorA/private/phone'), { phone: '+911111111111' }));
  });
});

describe('Instagram data', () => {
  it('tokens are unreadable and unwritable by everyone, including owner and admin', async () => {
    const tokens = 'instagram_accounts/creatorA/private/tokens';
    await fails(getDoc(doc(as('creatorA'), tokens)));
    await fails(getDoc(doc(admin(), tokens)));
    await fails(setDoc(doc(as('creatorA'), tokens), { accessToken: 'mine' }));
    await fails(getDoc(doc(as('creatorB'), tokens)));
  });

  it('clients cannot write the Instagram profile snapshot', async () => {
    await fails(updateDoc(doc(as('creatorA'), 'instagram_accounts/creatorA'), { followers: 1e9 }));
    await fails(setDoc(doc(as('creatorB'), 'instagram_accounts/creatorA'), { username: 'hijack' }));
  });

  it('media is readable only by its owner and never writable', async () => {
    await ok(getDoc(doc(as('creatorA'), 'instagram_media/media1')));
    await fails(getDoc(doc(as('creatorB'), 'instagram_media/media1')));
    await fails(updateDoc(doc(as('creatorA'), 'instagram_media/media1'), { userId: 'creatorB' }));
  });
});

describe('campaigns', () => {
  it('a brand can create a campaign only for itself and only under review', async () => {
    const db = as('brandA');
    const base = { brandId: 'brandA', title: 'New', viewCount: 0, viewedByCreatorIds: [] };
    await ok(setDoc(doc(db, 'campaigns/new1'), { ...base, status: 'underReview' }));
    await fails(setDoc(doc(db, 'campaigns/new2'), { ...base, status: 'active' }));
    await fails(setDoc(doc(db, 'campaigns/new3'), { ...base, brandId: 'brandB', status: 'underReview' }));
  });

  it("a brand cannot edit or delete another brand's campaign", async () => {
    const db = as('brandB');
    await fails(updateDoc(doc(db, 'campaigns/cActive'), { title: 'hijacked' }));
    await fails(deleteDoc(doc(db, 'campaigns/cActive')));
  });

  it('a brand cannot move its campaign straight from underReview to active', async () => {
    await fails(updateDoc(doc(as('brandA'), 'campaigns/cUnderReview'), { status: 'active' }));
  });

  // The rule only blocks the direct underReview/rejected -> active jump. Any
  // other status ('paused', 'draft', ...) is a stepping stone, so approval can
  // be skipped in two writes.
  it('a brand cannot reach active from underReview via an intermediate status', async () => {
    const db = as('brandA');
    await updateDoc(doc(db, 'campaigns/cUnderReview'), { status: 'paused' }).catch(() => {});
    await fails(updateDoc(doc(db, 'campaigns/cUnderReview'), { status: 'active' }));
  });

  it('a rejected campaign cannot be revived by its owner via another status', async () => {
    await testEnv.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'campaigns/cRejected'), {
        brandId: 'brandA', status: 'rejected', title: 'x', viewCount: 0, viewedByCreatorIds: [],
      }),
    );
    const db = as('brandA');
    await updateDoc(doc(db, 'campaigns/cRejected'), { status: 'draft' }).catch(() => {});
    await fails(updateDoc(doc(db, 'campaigns/cRejected'), { status: 'active' }));
  });

  it('admin and campaign-review staff can approve', async () => {
    await ok(updateDoc(doc(admin(), 'campaigns/cUnderReview'), { status: 'active' }));
    await ok(updateDoc(doc(staff('reviewer'), 'campaigns/cUnderReview'), { status: 'active' }));
    await fails(updateDoc(doc(staff('supportStaff'), 'campaigns/cUnderReview'), { status: 'active' }));
  });

  it('a creator may only bump the view counter by exactly one, as themselves', async () => {
    const db = as('creatorA');
    await ok(updateDoc(doc(db, 'campaigns/cActive'), {
      viewCount: increment(1), viewedByCreatorIds: arrayUnion('creatorA'),
    }));
    await fails(updateDoc(doc(db, 'campaigns/cActive'), {
      viewCount: increment(50), viewedByCreatorIds: arrayUnion('creatorA'),
    }));
    await fails(updateDoc(doc(db, 'campaigns/cActive'), { title: 'defaced' }));
  });

  // The rule only checks the caller's own id is PRESENT in the array, not
  // that it is the only id added, so other creators' ids can ride along.
  it("a creator cannot inject other creators' ids into viewedByCreatorIds", async () => {
    await fails(updateDoc(doc(as('creatorA'), 'campaigns/cActive'), {
      viewCount: increment(1), viewedByCreatorIds: arrayUnion('creatorA', 'fakeCreator'),
    }));
  });
});

describe('applications and deliverables', () => {
  it('a creator can apply as themselves in pending state only', async () => {
    const db = as('creatorA');
    const base = { creatorId: 'creatorA', brandId: 'brandA', campaignId: 'cActive' };
    await ok(setDoc(doc(db, 'applications/app2'), { ...base, status: 'pending' }));
    await fails(setDoc(doc(db, 'applications/app3'), { ...base, status: 'accepted' }));
    await fails(setDoc(doc(db, 'applications/app4'), { ...base, creatorId: 'creatorB', status: 'pending' }));
  });

  it('a creator cannot accept their own application', async () => {
    await fails(updateDoc(doc(as('creatorA'), 'applications/app1'), { status: 'accepted' }));
  });

  it('the owning brand can accept a pending application, but only change status', async () => {
    const db = as('brandA');
    await fails(updateDoc(doc(db, 'applications/app1'), { status: 'accepted', creatorId: 'creatorB' }));
    await ok(updateDoc(doc(db, 'applications/app1'), { status: 'accepted' }));
  });

  it('uninvolved users cannot read or decide an application', async () => {
    await fails(getDoc(doc(as('creatorB'), 'applications/app1')));
    await fails(getDoc(doc(as('brandB'), 'applications/app1')));
    await fails(updateDoc(doc(as('brandB'), 'applications/app1'), { status: 'accepted' }));
  });

  // Nothing ties the application's brandId to the campaign's real owner, so a
  // creator can drop applications into any brand's inbox.
  it("an application's brandId must be the campaign's real owner", async () => {
    await fails(
      setDoc(doc(as('creatorB'), 'applications/forged'), {
        creatorId: 'creatorB', brandId: 'brandB', campaignId: 'cActive', status: 'pending',
      }),
    );
  });

  // creatorId == brandId makes the creator both parties, so they could accept
  // their own application and run the whole collaboration with themselves.
  it('a user cannot apply to themselves', async () => {
    await fails(
      setDoc(doc(as('creatorB'), 'applications/self'), {
        creatorId: 'creatorB', brandId: 'creatorB', campaignId: 'cActive', status: 'pending',
      }),
    );
  });

  it('deliverables follow submit-then-approve and cannot be self-approved', async () => {
    // Nobody can skip the submit step while it is still pending.
    await fails(updateDoc(doc(as('creatorA'), 'deliverables/delPending'), { status: 'approved' }));
    await fails(updateDoc(doc(as('brandA'), 'deliverables/delPending'), { status: 'approved' }));
    // The creator cannot approve their own already-submitted work.
    await fails(updateDoc(doc(as('creatorA'), 'deliverables/delSubmitted'), {
      status: 'approved', reviewedAt: serverTimestamp(),
    }));
    // The legitimate path: creator submits, then the brand approves.
    await ok(updateDoc(doc(as('creatorA'), 'deliverables/delPending'), {
      status: 'submitted', submissionNote: 'done', submittedAt: serverTimestamp(),
    }));
    await ok(updateDoc(doc(as('brandA'), 'deliverables/delSubmitted'), {
      status: 'approved', reviewedAt: serverTimestamp(),
    }));
    await fails(getDoc(doc(as('creatorB'), 'deliverables/delPending')));
  });
});

describe('notifications', () => {
  const valid = () => ({
    userId: 'brandA', type: 'newApplication', title: 'New application', body: 'hello',
    referenceType: 'application', referenceId: 'app1', read: false, createdAt: serverTimestamp(),
  });

  it('only the recipient can read a notification, and can only mark it read', async () => {
    await ok(getDoc(doc(as('creatorA'), 'notifications/n1')));
    await fails(getDoc(doc(as('creatorB'), 'notifications/n1')));
    await ok(updateDoc(doc(as('creatorA'), 'notifications/n1'), { read: true }));
    await fails(updateDoc(doc(as('creatorA'), 'notifications/n1'), { body: 'edited' }));
  });

  it('a normal user cannot forge admin-only notification types', async () => {
    await fails(setDoc(doc(as('creatorA'), 'notifications/f1'), { ...valid(), userId: 'creatorB', type: 'profileVerified' }));
    await fails(setDoc(doc(as('creatorA'), 'notifications/f2'), { ...valid(), userId: 'creatorB', type: 'supportReply' }));
  });

  it('shape limits are enforced', async () => {
    const db = as('creatorA');
    await ok(setDoc(doc(db, 'notifications/v1'), valid()));
    await fails(setDoc(doc(db, 'notifications/v2'), { ...valid(), read: true }));
    await fails(setDoc(doc(db, 'notifications/v3'), { ...valid(), extra: 'x' }));
    await fails(setDoc(doc(db, 'notifications/v4'), { ...valid(), title: 'x'.repeat(250) }));
  });

  // The rule has to allow cross-user writes (a creator notifies a brand), but
  // it doesn't require any relationship, so any user can push arbitrary text
  // to any other user.
  it('a user cannot push arbitrary text to a user they have no relationship with', { todo: 'GAP N1: notification create needs no relationship to the recipient' }, async () => {
    await fails(
      setDoc(doc(as('creatorA'), 'notifications/spam'), {
        ...valid(), userId: 'creatorB', type: 'newMessage',
        title: 'Account locked', body: 'Verify now at http://evil.example',
      }),
    );
  });
});

describe('chats', () => {
  it('only participants can read a chat and its messages', async () => {
    await ok(getDoc(doc(as('creatorA'), 'chats/chat1')));
    await ok(getDoc(doc(as('brandA'), 'chats/chat1/messages/m1')));
    await fails(getDoc(doc(as('creatorB'), 'chats/chat1')));
    await fails(getDoc(doc(as('brandB'), 'chats/chat1/messages/m1')));
  });

  it('participants can send messages as themselves; outsiders and impersonators cannot', async () => {
    await ok(setDoc(doc(as('brandA'), 'chats/chat1/messages/m2'), { senderId: 'brandA', text: 'yo' }));
    await fails(setDoc(doc(as('brandA'), 'chats/chat1/messages/m3'), { senderId: 'creatorA', text: 'fake' }));
    await fails(setDoc(doc(as('creatorB'), 'chats/chat1/messages/m4'), { senderId: 'creatorB', text: 'intrude' }));
  });

  it('messages cannot be edited or deleted', async () => {
    await fails(updateDoc(doc(as('creatorA'), 'chats/chat1/messages/m1'), { text: 'edited' }));
    await fails(deleteDoc(doc(as('creatorA'), 'chats/chat1/messages/m1')));
  });

  it('a participant cannot reassign the chat to different people', async () => {
    await fails(updateDoc(doc(as('creatorA'), 'chats/chat1'), { brandId: 'brandB' }));
    await ok(updateDoc(doc(as('creatorA'), 'chats/chat1'), { creatorLastReadAt: serverTimestamp() }));
  });

  it('a blocked pair cannot open a chat', async () => {
    await fails(setDoc(doc(as('brandB'), 'chats/chat2'), {
      creatorId: 'creatorA', creatorName: 'Creator A', brandId: 'brandB', brandName: 'Brand B',
      status: 'active', createdAt: serverTimestamp(),
    }));
    await fails(setDoc(doc(as('creatorA'), 'chats/chat3'), {
      creatorId: 'creatorA', creatorName: 'Creator A', brandId: 'brandB', brandName: 'Brand B',
      status: 'active', createdAt: serverTimestamp(),
    }));
  });

  it('a participant can open a new chat with the real shape', async () => {
    await ok(setDoc(doc(as('creatorA'), 'chats/creatorA_newBrand'), {
      creatorId: 'creatorA', creatorName: 'Creator A', brandId: 'brandA', brandName: 'Brand A',
      status: 'request', initiatedBy: 'creator', createdAt: serverTimestamp(),
    }));
  });

  it('a new chat cannot carry extra fields or a bogus status', async () => {
    await fails(setDoc(doc(as('creatorA'), 'chats/creatorA_extra'), {
      creatorId: 'creatorA', creatorName: 'Creator A', brandId: 'brandA', brandName: 'Brand A',
      status: 'request', createdAt: serverTimestamp(), lastMessage: 'planted',
    }));
    await fails(setDoc(doc(as('creatorA'), 'chats/creatorA_bogus'), {
      creatorId: 'creatorA', creatorName: 'Creator A', brandId: 'brandA', brandName: 'Brand A',
      status: 'closed', createdAt: serverTimestamp(),
    }));
  });
});

describe('blocks and reports', () => {
  it('a user can only block as themselves, with a matching id', async () => {
    await ok(setDoc(doc(as('creatorA'), 'blocks/creatorA_brandA'), { blockerId: 'creatorA', blockedId: 'brandA' }));
    await fails(setDoc(doc(as('creatorA'), 'blocks/brandA_creatorA'), { blockerId: 'brandA', blockedId: 'creatorA' }));
    await fails(setDoc(doc(as('creatorA'), 'blocks/wrong_id'), { blockerId: 'creatorA', blockedId: 'brandA' }));
  });

  it('only the blocker can unblock', async () => {
    await ok(deleteDoc(doc(as('brandB'), 'blocks/brandB_creatorA')));
  });

  it("a third party cannot unblock someone else's block", async () => {
    await fails(deleteDoc(doc(as('creatorB'), 'blocks/brandB_creatorA')));
  });

  it('reports are write-only for users and readable by trust-safety staff', async () => {
    await ok(setDoc(doc(as('creatorA'), 'reports/new'), { reporterId: 'creatorA', reason: 'spam' }));
    await fails(setDoc(doc(as('creatorA'), 'reports/forged'), { reporterId: 'creatorB' }));
    await fails(getDoc(doc(as('creatorA'), 'reports/r1')));
    await ok(getDoc(doc(staff('trustStaff'), 'reports/r1')));
    await fails(getDoc(doc(staff('supportStaff'), 'reports/r1')));
  });
});

describe('outreach leads (intern tool)', () => {
  const newLead = (extra = {}) => ({
    instagramHandle: 'fresh', instagramUrl: 'https://instagram.com/fresh',
    internId: 'internUid', internEmail: 'i@x.com', message: 'm', comment: 'c',
    status: 'linkGenerated', clickCount: 0, internConfirmedSent: false,
    createdAt: serverTimestamp(), ...extra,
  });

  it('an intern can create a lead as themselves, including a contact email', async () => {
    await ok(setDoc(doc(staff('internUid'), 'leads/fresh'), newLead({ contactEmail: 'x@gmail.com' })));
  });

  it('an intern cannot create a lead as someone else or in an advanced status', async () => {
    const db = staff('internUid');
    await fails(setDoc(doc(db, 'leads/a'), newLead({ internId: 'otherIntern' })));
    await fails(setDoc(doc(db, 'leads/b'), newLead({ status: 'signedUp' })));
  });

  // Create has no field allow-list, so conversion fields can be pre-filled.
  it('an intern cannot seed conversion numbers when creating a lead', async () => {
    await fails(
      setDoc(doc(staff('internUid'), 'leads/padded'), newLead({
        clickCount: 500, matchedUid: 'creatorA', signedUpAt: serverTimestamp(),
        onboardingCompleteAt: serverTimestamp(), internConfirmedSent: true,
      })),
    );
  });

  it('non-staff, disabled staff and unrelated staff cannot touch leads', async () => {
    await fails(getDoc(doc(as('creatorA'), 'leads/lead1')));
    await fails(getDoc(doc(staff('disabledStaff'), 'leads/lead1')));
    await fails(getDoc(doc(staff('supportStaff'), 'leads/lead1')));
    await fails(setDoc(doc(as('creatorA'), 'leads/x'), newLead()));
  });

  it('an intern can confirm-sent once, and only on their own lead', async () => {
    const patch = { internConfirmedSent: true, internConfirmedSentAt: serverTimestamp() };
    await ok(updateDoc(doc(staff('internUid'), 'leads/lead1'), patch));
    await fails(updateDoc(doc(staff('internUid'), 'leads/lead1'), patch));
    await fails(updateDoc(doc(staff('internUid'), 'leads/leadOther'), patch));
  });

  it('an intern cannot edit status or click counts on an existing lead', async () => {
    const db = staff('internUid');
    await fails(updateDoc(doc(db, 'leads/lead1'), { status: 'onboardingComplete' }));
    await fails(updateDoc(doc(db, 'leads/lead1'), { clickCount: 999 }));
  });

  it('follow-ups increment by exactly one', async () => {
    const db = staff('internUid');
    await ok(updateDoc(doc(db, 'leads/lead1'), { lastFollowUpSentAt: serverTimestamp(), followUpCount: increment(1) }));
    await fails(updateDoc(doc(db, 'leads/lead1'), { lastFollowUpSentAt: serverTimestamp(), followUpCount: increment(5) }));
  });

  it('shift time is capped per write and tied to the intern', async () => {
    const db = staff('internUid');
    const stat = (seconds) => ({
      internId: 'internUid', internEmail: 'i@x.com', date: '2026-10-06',
      activeSeconds: seconds, updatedAt: serverTimestamp(),
    });
    await ok(setDoc(doc(db, 'internShiftStats/internUid_2026-10-06'), stat(60)));
    await fails(setDoc(doc(db, 'internShiftStats/internUid_2026-10-07'), { ...stat(61), date: '2026-10-07' }));
    await fails(setDoc(doc(db, 'internShiftStats/otherIntern_2026-10-06'), stat(10)));
    await fails(updateDoc(doc(db, 'internShiftStats/internUid_2026-10-05'), {
      activeSeconds: 200, updatedAt: serverTimestamp(),
    }));
    await fails(getDoc(doc(staff('otherIntern'), 'internShiftStats/internUid_2026-10-05')));
  });
});

describe('support, announcements, audit and config', () => {
  it('users can open their own ticket, without staff-only fields', async () => {
    const db = as('creatorA');
    await ok(setDoc(doc(db, 'supportChats/new'), { userId: 'creatorA', status: 'open' }));
    await fails(setDoc(doc(db, 'supportChats/n2'), { userId: 'creatorB', status: 'open' }));
    await fails(setDoc(doc(db, 'supportChats/n3'), { userId: 'creatorA', internalNotes: 'x' }));
    await fails(setDoc(doc(db, 'supportChats/n4'), { userId: 'creatorA', category: 'vip' }));
  });

  it("tickets and attachments' messages are private to owner and support staff", async () => {
    await ok(getDoc(doc(as('creatorA'), 'supportChats/t1')));
    await fails(getDoc(doc(as('creatorB'), 'supportChats/t1')));
    await fails(getDoc(doc(as('creatorB'), 'supportChats/t1/messages/sm1')));
    await ok(getDoc(doc(staff('supportStaff'), 'supportChats/t1/messages/sm1')));
    await fails(getDoc(doc(staff('disabledStaff'), 'supportChats/t1')));
  });

  it("a ticket owner cannot edit staff-only fields", async () => {
    await ok(updateDoc(doc(as('creatorA'), 'supportChats/t1'), { lastMessage: 'ping', status: 'open' }));
    await fails(updateDoc(doc(as('creatorA'), 'supportChats/t1'), { internalNotes: 'mine' }));
    await ok(updateDoc(doc(staff('supportStaff'), 'supportChats/t1'), { internalNotes: 'vip', category: 'bug' }));
  });

  it('announcements are readable by all, creatable by broadcast staff, and immutable', async () => {
    await ok(getDoc(doc(as('creatorA'), 'announcements/a1')));
    await fails(setDoc(doc(as('creatorA'), 'announcements/x'), { title: 'spam' }));
    await ok(setDoc(doc(staff('broadcaster'), 'announcements/x'), { title: 'real' }));
    await fails(updateDoc(doc(admin(), 'announcements/a1'), { title: 'edited' }));
    await fails(deleteDoc(doc(admin(), 'announcements/a1')));
  });

  it('audit logs are write-once and readable only with the audit permission', async () => {
    const supportStaffEmail = as('supportStaff', { email: 'support-staff@test.example' });
    const entry = (overrides = {}) => ({
      actorEmail: 'support-staff@test.example', action: 'supportReplySent',
      targetId: 't1', targetName: 'Creator A', timestamp: serverTimestamp(), ...overrides,
    });
    await ok(setDoc(doc(supportStaffEmail, 'auditLogs/l1'), entry()));
    await fails(setDoc(doc(as('creatorA'), 'auditLogs/l2'), entry()));
    await fails(updateDoc(doc(admin(), 'auditLogs/l1'), { action: 'rewritten' }));
    await fails(deleteDoc(doc(admin(), 'auditLogs/l1')));
    await ok(getDoc(doc(staff('auditor'), 'auditLogs/l1')));
    await fails(getDoc(doc(staff('supportStaff'), 'auditLogs/l1')));
  });

  it('cannot forge an audit log under someone else\'s name, or an unknown action', async () => {
    const supportStaffEmail = as('supportStaff', { email: 'support-staff@test.example' });
    const base = {
      action: 'supportReplySent', targetId: 't1', targetName: 'x', timestamp: serverTimestamp(),
    };
    // The actual bug this closes: a staff account writing admin's email as the actor.
    await fails(setDoc(doc(supportStaffEmail, 'auditLogs/forged'),
      { ...base, actorEmail: 'admin@collabsy.online' }));
    await fails(setDoc(doc(supportStaffEmail, 'auditLogs/badaction'),
      { ...base, actorEmail: 'support-staff@test.example', action: 'notARealAction' }));
    await fails(setDoc(doc(supportStaffEmail, 'auditLogs/extra'),
      { ...base, actorEmail: 'support-staff@test.example', extra: 'field' }));
  });

  it('staff login events are pinned to the caller and never forgedLogout from the client', async () => {
    const supportStaffEmail = as('supportStaff', { email: 'support-staff@test.example' });
    const event = (overrides = {}) => ({
      uid: 'supportStaff', email: 'support-staff@test.example', roleName: 'Support',
      type: 'login', timestamp: serverTimestamp(), ...overrides,
    });
    await ok(setDoc(doc(supportStaffEmail, 'staffLoginEvents/e1'), event()));
    await fails(setDoc(doc(supportStaffEmail, 'staffLoginEvents/e2'), event({ uid: 'internUid' })));
    await fails(setDoc(doc(supportStaffEmail, 'staffLoginEvents/e3'),
      event({ email: 'admin@collabsy.online' })));
    await fails(setDoc(doc(supportStaffEmail, 'staffLoginEvents/e4'), event({ type: 'forcedLogout' })));
  });

  it('the force-update config is readable by anyone, even signed out, but only admin-writable', async () => {
    await ok(getDoc(doc(anon(), 'config/appVersion')));
    await ok(getDoc(doc(as('creatorA'), 'config/appVersion')));
    await fails(setDoc(doc(as('creatorA'), 'config/appVersion'), { minBuildAndroid: 1 }));
    await fails(setDoc(doc(staff('internUid'), 'config/appVersion'), { minBuildAndroid: 1 }));
    await ok(setDoc(doc(admin(), 'config/appVersion'), { minBuildAndroid: 31, minBuildIos: 31 }));
  });

  it('outreach config is admin-write and staff-read only', async () => {
    await ok(getDoc(doc(staff('internUid'), 'config/outreachLinks')));
    await fails(getDoc(doc(as('creatorA'), 'config/outreachLinks')));
    await fails(setDoc(doc(staff('internUid'), 'config/outreachLinks'), { messageTemplate: 'pwn' }));
    await ok(setDoc(doc(admin(), 'config/outreachLinks'), { messageTemplate: 'ok' }));
  });
});

// ---------------------------------------------------------------------------
// The payloads below are copied from what the SHIPPED apps actually send
// (campaigns_repository.dart, intern_leads_providers.dart,
// brand_intern_leads_providers.dart). They exist so tightening the rules can
// never silently break an app that is already in users' hands.
// ---------------------------------------------------------------------------
describe('shipped-app compatibility', () => {
  it("the brand's status menu still works: pause, activate, close, reopen", async () => {
    const brand = as('brandA');
    await ok(updateDoc(doc(brand, 'campaigns/cActive'), { status: 'paused' }));
    await ok(updateDoc(doc(brand, 'campaigns/cPaused'), { status: 'active' }));
    await ok(updateDoc(doc(brand, 'campaigns/cPaused'), { status: 'closed' }));
    await ok(updateDoc(doc(brand, 'campaigns/cClosed'), { status: 'active' }));
    await ok(updateDoc(doc(brand, 'campaigns/cExpired'), { status: 'closed' }));
  });

  it("a brand cannot use the status field to bypass review or fake a rejection", async () => {
    const brand = as('brandA');
    // From underReview, no status change is possible...
    for (const status of ['active', 'paused', 'closed', 'draft', 'rejected']) {
      await fails(updateDoc(doc(brand, 'campaigns/cUnderReview'), { status }));
    }
    // ...but re-sending the SAME status is a harmless no-op, which is allowed.
    await ok(updateDoc(doc(brand, 'campaigns/cUnderReview'), { status: 'underReview' }));
    for (const status of ['rejected', 'underReview', 'draft', 'whatever']) {
      await fails(updateDoc(doc(brand, 'campaigns/cActive'), { status }));
    }
  });

  it('campaign view tracking works for a first view, a repeat view, and after others', async () => {
    const creator = as('creatorA');
    const view = { viewCount: increment(1), viewedByCreatorIds: arrayUnion('creatorA') };
    await ok(updateDoc(doc(creator, 'campaigns/cActive'), view));
    await ok(updateDoc(doc(creator, 'campaigns/cActive'), view));
    await ok(updateDoc(doc(creator, 'campaigns/cViewed'), view));
  });

  it('applying with the exact client payload works', async () => {
    await ok(setDoc(doc(as('creatorA'), 'applications/cActive_creatorA'), {
      campaignId: 'cActive', campaignTitle: 'Live', creatorId: 'creatorA',
      creatorName: 'Creator A', brandId: 'brandA', status: 'pending',
      appliedAt: serverTimestamp(), agreedDeliverablesSummary: '1 reel', agreedBudget: 500,
    }));
  });

  it('a brand cannot apply to its own campaign', async () => {
    await fails(setDoc(doc(as('brandA'), 'applications/cActive_brandA'), {
      campaignId: 'cActive', creatorId: 'brandA', brandId: 'brandA', status: 'pending',
      appliedAt: serverTimestamp(),
    }));
  });

  it('the intern tool can create a lead with and without a contact email', async () => {
    const db = staff('internUid');
    const payload = (handle) => ({
      instagramHandle: handle, instagramUrl: `https://instagram.com/${handle}`,
      internId: 'internUid', internEmail: 'i@x.com', message: 'm', comment: 'c',
      status: 'linkGenerated', createdAt: serverTimestamp(), clickCount: 0,
      internConfirmedSent: false,
    });
    await ok(setDoc(doc(db, 'leads/old_version'), payload('old_version')));
    await ok(setDoc(doc(db, 'leads/new_version'), { ...payload('new_version'), contactEmail: 'p@gmail.com' }));
  });

  it('lead creation rejects extra fields, a huge email, and a backdated createdAt', async () => {
    const db = staff('internUid');
    const base = {
      instagramHandle: 'h', instagramUrl: 'u', internId: 'internUid', internEmail: 'i@x.com',
      message: 'm', comment: 'c', status: 'linkGenerated', createdAt: serverTimestamp(),
      clickCount: 0, internConfirmedSent: false,
    };
    await fails(setDoc(doc(db, 'leads/x1'), { ...base, matchedUid: 'someone' }));
    await fails(setDoc(doc(db, 'leads/x2'), { ...base, contactEmail: 'a'.repeat(400) }));
    await fails(setDoc(doc(db, 'leads/x3'), { ...base, createdAt: new Date('2020-01-01') }));
    await fails(setDoc(doc(db, 'leads/x4'), { ...base, clickCount: 1 }));
  });

  it('the brand-outreach tool can create a lead, but not a padded one', async () => {
    const db = staff('brandInternUid');
    const payload = () => ({
      linkedinUrl: 'https://linkedin.com/in/x', internId: 'brandInternUid',
      internEmail: 'b@x.com', message: 'm', status: 'linkGenerated',
      createdAt: serverTimestamp(), clickCount: 0,
    });
    await ok(setDoc(doc(db, 'brandLeads/x'), payload()));
    await fails(setDoc(doc(db, 'brandLeads/y'), { ...payload(), clickCount: 99 }));
    await fails(setDoc(doc(db, 'brandLeads/z'), { ...payload(), signedUpAt: serverTimestamp() }));
  });
});

describe('campaign ownership', () => {
  it('an owner cannot reassign a campaign to a different brand', async () => {
    await fails(updateDoc(doc(as('brandA'), 'campaigns/cActive'), { brandId: 'brandB' }));
    // Staff/admin review still needs to be able to touch other fields without
    // this new check getting in the way of a write that leaves brandId alone.
    await ok(updateDoc(doc(as('brandA'), 'campaigns/cActive'), { status: 'paused' }));
  });
});

describe('account suspension', () => {
  // suspendUserAccount puts a `suspended` custom claim on the account (and
  // revokes its refresh tokens so the next token carries it). The rules refuse
  // a suspended token's platform writes, but leave Support, the account's own
  // user doc, and reads alone so the "suspended" screen keeps working.
  const suspended = (uid = 'suspendedC') => as(uid, { suspended: true });
  const sampleApplication = (uid) => ({
    creatorId: uid, brandId: 'brandA', campaignId: 'cActive', status: 'pending',
  });

  it('a suspended creator cannot apply to a campaign', async () => {
    await fails(setDoc(doc(suspended(), 'applications/sApp'), sampleApplication('suspendedC')));
  });

  it('the same account is fine without the claim (sanity check)', async () => {
    await ok(setDoc(doc(as('creatorB'), 'applications/okApp'), sampleApplication('creatorB')));
  });

  it('a suspended user cannot keep messaging in an existing chat', async () => {
    await testEnv.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'chats/chatS'), {
        creatorId: 'suspendedC', brandId: 'brandA', status: 'active',
      }));
    await fails(setDoc(doc(suspended(), 'chats/chatS/messages/sm'), {
      senderId: 'suspendedC', text: 'still here',
    }));
    await fails(updateDoc(doc(suspended(), 'chats/chatS'), { lastMessage: 'still here' }));
    await ok(setDoc(doc(as('suspendedC'), 'chats/chatS/messages/sm2'), {
      senderId: 'suspendedC', text: 'no claim yet',
    }));
  });

  it('a suspended user cannot open new chats', async () => {
    await fails(setDoc(doc(suspended(), 'chats/newChat'), {
      creatorId: 'suspendedC', brandId: 'brandA', status: 'active',
    }));
  });

  it('a suspended brand cannot create or change campaigns', async () => {
    await fails(setDoc(doc(suspended('brandA'), 'campaigns/newC'), {
      brandId: 'brandA', status: 'underReview', title: 'x',
    }));
    await fails(updateDoc(doc(suspended('brandA'), 'campaigns/cActive'), { status: 'paused' }));
    await fails(deleteDoc(doc(suspended('brandA'), 'campaigns/cActive')));
  });

  it('a suspended user cannot push notifications or touch deliverables', async () => {
    await fails(addDoc(collection(suspended('brandA'), 'notifications'), {
      userId: 'creatorA', type: 'newMessage', title: 't', body: 'b',
      read: false, createdAt: serverTimestamp(),
    }));
    await fails(updateDoc(doc(suspended('creatorA'), 'deliverables/delPending'), {
      status: 'submitted', submissionNote: 'n', submittedAt: serverTimestamp(),
    }));
  });

  it('a suspended user can still see their data and reach Support (must stay allowed)', async () => {
    const db = suspended();
    await ok(getDoc(doc(db, 'users/suspendedC')));
    await ok(setDoc(doc(db, 'supportChats/sTicket'), { userId: 'suspendedC', status: 'open' }));
    await ok(setDoc(doc(db, 'supportChats/sTicket/messages/m1'), { text: 'please help', senderRole: 'user' }));
    // The sign-in activity ping the app sends on every launch.
    await ok(setDoc(doc(db, 'dailyActivity/suspendedC_20261011'), { userId: 'suspendedC' }));
  });

  it('the account still cannot un-suspend itself', async () => {
    await fails(updateDoc(doc(suspended(), 'users/suspendedC'), { suspended: false }));
  });
});

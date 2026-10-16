// Seeds the LOCAL Firebase Emulator Suite with fake accounts and data, so
// the website/admin/intern/brand-intern staging builds have something
// realistic to render and sign in to. Never touches a real Firebase
// project: it only talks to the emulator ports below, and refuses to run
// unless FIRESTORE_EMULATOR_HOST / FIREBASE_AUTH_EMULATOR_HOST are set (see
// staging/README.md — `npm run seed` sets them for you).
//
// All values here (emails, passwords, names, numbers) are fake, made up for
// this script, and only ever exist inside the local emulator.

if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error(
    'Refusing to run: FIRESTORE_EMULATOR_HOST / FIREBASE_AUTH_EMULATOR_HOST ' +
      'are not set. Run this via `npm run seed` from staging/, with the ' +
      'emulators already running (npm start).'
  );
  process.exit(1);
}

process.env.GCLOUD_PROJECT = 'demo-collabsy';

const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');

initializeApp({ projectId: 'demo-collabsy' });
const auth = getAuth();
const db = getFirestore();

const ADMIN_EMAIL = 'admin@collabsy.online';
const ADMIN_PASSWORD = 'StagingAdmin123!';
const STAFF_EMAIL = 'staff@collabsy.online';
const STAFF_PASSWORD = 'StagingStaff123!';
const CREATOR_PHONE = '+919000000001';
const BRAND_EMAIL = 'brand@example.test';
const BRAND_PASSWORD = 'StagingBrand123!';

async function upsertUser(props) {
  try {
    return await auth.getUserByEmail(props.email);
  } catch (_) {
    return auth.createUser(props);
  }
}

async function upsertPhoneUser(props) {
  try {
    return await auth.getUserByPhoneNumber(props.phoneNumber);
  } catch (_) {
    return auth.createUser(props);
  }
}

async function main() {
  console.log('Seeding the local emulator (project demo-collabsy)...');

  const admin = await upsertUser({
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
    emailVerified: true,
    displayName: 'Collabsy Admin',
  });

  const staff = await upsertUser({
    email: STAFF_EMAIL,
    password: STAFF_PASSWORD,
    emailVerified: true,
    displayName: 'Staging Staff',
  });

  const creator = await upsertPhoneUser({
    phoneNumber: CREATOR_PHONE,
    displayName: 'Staging Creator',
  });

  const brand = await upsertUser({
    email: BRAND_EMAIL,
    password: BRAND_PASSWORD,
    emailVerified: true,
    displayName: 'Staging Brand',
  });

  const put = (path, data) => db.doc(path).set(data, { merge: true });
  const now = Timestamp.now();

  await put(`staffAccounts/${staff.uid}`, {
    email: STAFF_EMAIL,
    roleName: 'Outreach Intern (staging)',
    active: true,
    permissions: {
      '/outreach-leads': true,
      '/brand-outreach-leads': true,
      '/support': true,
      '/campaigns/review': true,
      '/verification/creators': true,
      '/verification/brands': true,
      '/trust-safety': true,
      '/broadcast': true,
      '/audit': true,
      '/analytics': true,
      '/crash-analytics': true,
      '/deletion-requests': true,
      '/campaign-requests': true,
    },
    createdAt: now,
    createdBy: ADMIN_EMAIL,
  });

  await put(`users/${creator.uid}`, {
    role: 'creator',
    displayName: 'Staging Creator',
    email: null,
    phone: CREATOR_PHONE,
    onboardingCompleted: true,
    createdAt: now,
  });
  await put(`creatorProfiles/${creator.uid}`, {
    verificationStatus: 'approved',
    bio: 'A seeded creator account for staging.',
    languages: ['English', 'Hindi'],
    location: 'Bengaluru, India',
    categories: ['fashion', 'lifestyle'],
  });
  await put(`instagram_accounts/${creator.uid}`, {
    status: 'connected',
    username: 'staging_creator',
    name: 'Staging Creator',
    followersCount: 24000,
    followsCount: 410,
    mediaCount: 180,
    lastSyncedAt: now,
  });

  await put(`users/${brand.uid}`, {
    role: 'brand',
    displayName: 'Staging Brand Co.',
    email: BRAND_EMAIL,
    onboardingCompleted: true,
    createdAt: now,
  });
  await put(`brandProfiles/${brand.uid}`, {
    verificationStatus: 'approved',
    bio: 'A seeded brand account for staging.',
    industries: ['D2C', 'Beauty'],
    website: 'https://example.test',
  });

  await put('campaigns/stagingCampaign1', {
    brandId: brand.uid,
    status: 'active',
    title: 'Staging launch campaign',
    description: 'Seeded campaign for staging security testing.',
    viewCount: 0,
    viewedByCreatorIds: [],
    createdAt: now,
  });

  await put('applications/stagingApp1', {
    creatorId: creator.uid,
    brandId: brand.uid,
    campaignId: 'stagingCampaign1',
    status: 'pending',
    createdAt: now,
  });

  await put('leads/staging_handle', {
    instagramHandle: 'staging_handle',
    instagramUrl: 'https://www.instagram.com/staging_handle/',
    internId: staff.uid,
    internEmail: STAFF_EMAIL,
    status: 'linkGenerated',
    clickCount: 0,
    internConfirmedSent: false,
    createdAt: now,
  });

  await put('brandLeads/in_staging-brand', {
    linkedinUrl: 'https://www.linkedin.com/in/staging-brand',
    internId: staff.uid,
    internEmail: STAFF_EMAIL,
    status: 'linkGenerated',
    clickCount: 0,
    createdAt: now,
  });

  await put('config/outreachLinks', {
    messageTemplate:
      "Hi! 👋 Staging test message — Download the app here: {{link}}",
    comingSoonEnabled: false,
    androidStoreUrl:
      'https://play.google.com/store/apps/details?id=online.collabsy.app',
    iosStoreUrl: 'https://apps.apple.com/in/app/collabsy/id6808197823',
  });
  await put('config/brandOutreachLinks', {
    messageTemplate:
      "Hi! 👋 Staging test message — Download the app here: {{link}}",
    comingSoonEnabled: false,
    androidStoreUrl:
      'https://play.google.com/store/apps/details?id=online.collabsy.app',
    iosStoreUrl: 'https://apps.apple.com/in/app/collabsy/id6808197823',
  });

  console.log('\nSeeded. Sign-in accounts for staging:');
  console.log(`  Admin portal:        ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}`);
  console.log(`  Intern/brand tools:  ${STAFF_EMAIL} / ${STAFF_PASSWORD}`);
  console.log(`  Creator (app, OTP):  ${CREATOR_PHONE} — any 6-digit code works in the Auth emulator`);
  console.log(`  Brand (app):         ${BRAND_EMAIL} / ${BRAND_PASSWORD}`);
  console.log(`  Admin uid: ${admin.uid}`);
}

main().then(
  () => process.exit(0),
  (err) => {
    console.error(err);
    process.exit(1);
  }
);

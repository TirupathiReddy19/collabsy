// Builds the four web targets for the staging environment, with
// --dart-define=USE_FIREBASE_EMULATOR=true so they connect to the local
// Emulator Suite instead of production (see lib/core/config/emulator_config.dart).
// Output goes to build/staging/web-*, never build/web-* — that directory is
// what `firebase deploy` reads, and this script never touches it.
const { spawnSync } = require('child_process');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');

const targets = [
  { entry: 'lib/main_website.dart', out: 'build/staging/web-website' },
  { entry: 'lib/main_admin.dart', out: 'build/staging/web-admin' },
  { entry: 'lib/main_intern.dart', out: 'build/staging/web-intern' },
  { entry: 'lib/main_brand_intern.dart', out: 'build/staging/web-brand-intern' },
];

for (const t of targets) {
  console.log(`\nBuilding ${t.entry} -> ${t.out} ...`);
  const result = spawnSync(
    'flutter',
    [
      'build',
      'web',
      '-t',
      t.entry,
      '--output',
      t.out,
      '--release',
      '--dart-define=USE_FIREBASE_EMULATOR=true',
    ],
    { cwd: repoRoot, stdio: 'inherit', shell: true }
  );
  if (result.status !== 0) {
    console.error(`Build failed for ${t.entry}`);
    process.exit(result.status ?? 1);
  }
}

console.log('\nAll four staging builds succeeded.');

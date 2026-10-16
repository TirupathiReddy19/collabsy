// Starts the Firebase Emulator Suite for staging. A thin wrapper instead of
// a shell one-liner so the FUNCTIONS_DISCOVERY_TIMEOUT env var, the repo
// root as cwd, and the `firebase` binary resolution (staging/node_modules
// /.bin, via inherited PATH — see package.json's "start" script, which npm
// always prepends) all stay unambiguous across Windows and POSIX shells.
const { spawnSync } = require('child_process');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');

const result = spawnSync(
  'firebase',
  [
    'emulators:start',
    '--config',
    'firebase.staging.json',
    '--project',
    'demo-collabsy',
  ],
  {
    cwd: repoRoot,
    stdio: 'inherit',
    shell: true,
    env: {
      ...process.env,
      // The Functions emulator's first load of functions/ can take longer
      // than the 10s default on a cold start (seen on real deploys too);
      // without this it sometimes fails with "Cannot determine backend
      // specification. Timeout after 10000" and silently loads zero
      // functions, even though the overall suite still reports ready.
      FUNCTIONS_DISCOVERY_TIMEOUT: '60',
    },
  }
);

process.exit(result.status ?? 1);

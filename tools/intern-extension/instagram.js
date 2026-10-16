// Runs on instagram.com. Adds a "Send to Collabsy" button on profile pages
// that reads the bio text already loaded in the intern's own browser and
// hands it to the Collabsy intern tool. It makes no requests to Instagram.

const RESERVED_PATHS = new Set([
  'explore', 'reels', 'reel', 'p', 'tv', 'stories', 'accounts', 'direct',
  'about', 'legal', 'privacy', 'terms', 'developers', 'directory', 'web',
  'api', 'challenge', 'emails', 'session', 'nametag', 'oauth', 'login',
]);
const PROFILE_SUBPAGES = new Set(['reels', 'tagged', 'saved', 'channel']);
const HANDLE_PATTERN = /^[a-z0-9._]{1,30}$/i;
const MAX_BIO_LENGTH = 4000;

/** The profile handle for an instagram.com pathname, or null if it isn't one. */
function handleFromPath(pathname) {
  const parts = pathname.split('/').filter(Boolean);
  if (parts.length < 1 || parts.length > 2) return null;
  if (parts.length === 2 && !PROFILE_SUBPAGES.has(parts[1].toLowerCase())) {
    return null;
  }
  const handle = parts[0];
  if (!HANDLE_PATTERN.test(handle)) return null;
  if (RESERVED_PATHS.has(handle.toLowerCase())) return null;
  return handle.toLowerCase();
}

/** Trims header text to something safe and small to send along. */
function cleanBioText(text) {
  return String(text || '')
    .replace(/ /g, ' ')
    .trim()
    .slice(0, MAX_BIO_LENGTH);
}

/**
 * True when [text] contains [handle] as a whole word. Instagram navigates
 * without reloading, so for a moment the header can still show the previous
 * profile — this stops one profile's bio being sent under another's handle.
 * Whole-word so "priya" doesn't match a header for "priya.sharma".
 */
function headerMatchesHandle(text, handle) {
  const escaped = handle.toLowerCase().replace(/[.]/g, '\\.');
  const pattern = new RegExp(`(^|[^a-z0-9._])${escaped}($|[^a-z0-9._])`);
  return pattern.test(String(text || '').toLowerCase());
}

if (typeof module !== 'undefined') {
  module.exports = { handleFromPath, cleanBioText, headerMatchesHandle };
}

if (typeof document !== 'undefined') {
  const BUTTON_ID = 'collabsy-send-btn';
  const MORE_PATTERN = /^(…|\.\.\.)?\s*more$/i;

  const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  // Long bios are collapsed behind "… more" — an email after the cut would
  // be missed, so expand it the same way a person would.
  function expandBio(header) {
    const candidates = header.querySelectorAll(
      '[role="button"], button, span',
    );
    for (const el of candidates) {
      if (MORE_PATTERN.test((el.textContent || '').trim())) el.click();
    }
  }

  async function readProfileText() {
    const header =
      document.querySelector('main header') || document.querySelector('header');
    if (!header) return '';
    expandBio(header);
    await wait(250);
    return cleanBioText(header.innerText);
  }

  function setLabel(button, text, background) {
    button.textContent = text;
    if (background) button.style.background = background;
  }

  async function sendProfile(button) {
    const handle = handleFromPath(location.pathname);
    if (!handle) return;

    setLabel(button, 'Reading…');
    const bio = await readProfileText();
    if (!bio) {
      setLabel(button, "Couldn't read bio", '#b91c1c');
      setTimeout(() => setLabel(button, 'Send to Collabsy', '#f97316'), 2500);
      return;
    }
    if (!headerMatchesHandle(bio, handle)) {
      setLabel(button, 'Page still loading — retry', '#b91c1c');
      setTimeout(() => setLabel(button, 'Send to Collabsy', '#f97316'), 2500);
      return;
    }

    try {
      const response = await chrome.runtime.sendMessage({
        type: 'collabsy:profile',
        handle,
        bio,
      });
      if (response && response.ok) {
        setLabel(button, 'Sent ✓', '#15803d');
      } else {
        setLabel(button, 'Send failed', '#b91c1c');
      }
    } catch (_) {
      // The extension was reloaded or updated while this tab stayed open.
      setLabel(button, 'Reload this page', '#b91c1c');
    }
    setTimeout(() => setLabel(button, 'Send to Collabsy', '#f97316'), 2500);
  }

  function addButton() {
    const button = document.createElement('button');
    button.id = BUTTON_ID;
    button.type = 'button';
    Object.assign(button.style, {
      position: 'fixed',
      right: '20px',
      bottom: '20px',
      zIndex: '2147483647',
      padding: '10px 16px',
      border: 'none',
      borderRadius: '999px',
      background: '#f97316',
      color: '#fff',
      font: '600 14px system-ui, sans-serif',
      cursor: 'pointer',
      boxShadow: '0 4px 14px rgba(0,0,0,0.25)',
    });
    button.textContent = 'Send to Collabsy';
    button.addEventListener('click', () => sendProfile(button));
    document.body.appendChild(button);
  }

  // Instagram navigates without reloading the page, so re-check the URL
  // on a light timer instead of relying on load events.
  function syncButton() {
    const existing = document.getElementById(BUTTON_ID);
    const onProfile = handleFromPath(location.pathname) !== null;
    if (onProfile && !existing) addButton();
    if (!onProfile && existing) existing.remove();
  }

  syncButton();
  setInterval(syncButton, 800);
}

// Service worker: receives a profile from an Instagram tab and delivers it
// to the Collabsy intern tool, opening the tool first if it isn't open.

const TOOL_URL = 'https://collabsy-leads.web.app/';
const TOOL_PATTERN = 'https://collabsy-leads.web.app/*';

async function stashPending(payload) {
  await chrome.storage.session.set({ pending: payload });
}

// Handed to the tool tab once its page script announces it has loaded.
async function takePending() {
  const { pending } = await chrome.storage.session.get('pending');
  if (pending) await chrome.storage.session.remove('pending');
  return pending || null;
}

async function focusTab(tab) {
  await chrome.tabs.update(tab.id, { active: true });
  await chrome.windows.update(tab.windowId, { focused: true });
}

async function deliver(message) {
  const payload = { handle: message.handle, bio: message.bio };

  const [tab] = await chrome.tabs.query({ url: TOOL_PATTERN });
  if (!tab) {
    await stashPending(payload);
    await chrome.tabs.create({ url: TOOL_URL });
    return;
  }

  try {
    await chrome.tabs.sendMessage(tab.id, { type: 'collabsy:deliver', payload });
  } catch (_) {
    // The tool tab was opened before the extension was installed, so its
    // page script isn't there yet. Reloading injects it and picks up the
    // stashed profile on load.
    await stashPending(payload);
    await chrome.tabs.reload(tab.id);
  }
  await focusTab(tab);
}

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message && message.type === 'collabsy:profile') {
    deliver(message).then(
      () => sendResponse({ ok: true }),
      () => sendResponse({ ok: false }),
    );
    return true;
  }
  if (message && message.type === 'collabsy:ready') {
    takePending().then((payload) => sendResponse({ payload }));
    return true;
  }
  return false;
});

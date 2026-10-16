// Runs on the Collabsy intern tool. Relays a profile from the extension
// into the page via same-origin postMessage. The page announces when it is
// ready and acknowledges receipt, so a profile sent while the tool was
// still loading (or on the sign-in screen) isn't lost, and isn't replayed
// once it has been used.

let latest = null;

function post(payload) {
  window.postMessage(
    { source: 'collabsy-extension', type: 'profile', payload },
    location.origin,
  );
}

chrome.runtime.onMessage.addListener((message) => {
  if (message && message.type === 'collabsy:deliver') {
    latest = message.payload;
    post(latest);
  }
});

window.addEventListener('message', (event) => {
  if (event.source !== window || event.origin !== location.origin) return;
  const data = event.data;
  if (!data || data.source !== 'collabsy-app') return;
  if (data.type === 'ready' && latest) post(latest);
  if (data.type === 'received') latest = null;
});

// Picks up a profile stashed while this page was being opened or reloaded.
chrome.runtime.sendMessage({ type: 'collabsy:ready' }, (response) => {
  void chrome.runtime.lastError;
  if (response && response.payload) {
    latest = response.payload;
    post(latest);
  }
});

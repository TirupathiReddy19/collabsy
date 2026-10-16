# Collabsy Outreach Helper

A Chrome extension for the intern outreach tool (https://collabsy-leads.web.app). On an Instagram profile it adds a **Send to Collabsy** button. Clicking it reads the bio already on screen and sends it to the intern tool, which fills in the profile link and any contact email it finds. It makes no requests to Instagram and sends the bio nowhere except the intern tool.

## Install (per intern)
1. Open `chrome://extensions` and turn on **Developer mode**.
2. Click **Load unpacked** and pick this `intern-extension` folder.
3. Keep the intern tool open in one tab, then open any Instagram profile in another.

## Use
Click **Send to Collabsy** on the profile page. The tool tab comes to the front with the link, bio, and email filled in; then click **Generate link** as usual. If the tool isn't open, the extension opens it first.

## Notes
- After updating these files, click the reload icon on the extension in `chrome://extensions`, then reload open Instagram tabs.
- If the tool is ever served from another domain, add it to `host_permissions` and the `tool.js` match in `manifest.json`.
- Instagram changes its page layout now and then. The extension only reads the profile header's text, so it should survive most changes, but if the button reports "Couldn't read bio", `readProfileText` in `instagram.js` is the place to look.
- Logic tests: `node --test test/instagram.test.js`

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.wrapEmailHtml = wrapEmailHtml;
exports.escapeHtml = escapeHtml;
/** Wraps [bodyHtml] in a minimal, inline-styled shell — email clients
 * strip external stylesheets, so everything here is inline on purpose.
 * Shared by every transactional email this codebase sends. */
function wrapEmailHtml(bodyHtml) {
    return `
    <div style="font-family: -apple-system, 'Segoe UI', Roboto, sans-serif; max-width: 560px; margin: 0 auto; padding: 32px 24px; color: #1f2937;">
      <div style="font-size: 20px; font-weight: 700; color: #F97316; margin-bottom: 24px;">Collabsy</div>
      ${bodyHtml}
      <div style="margin-top: 32px; padding-top: 16px; border-top: 1px solid #e5e7eb; font-size: 12px; color: #9ca3af;">
        Collabsy &middot; collabsy.online
      </div>
    </div>
  `;
}
function escapeHtml(value) {
    return value
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BUDGET_RANGES = void 0;
exports.parseCampaignRequest = parseCampaignRequest;
exports.parseDeletionRequest = parseDeletionRequest;
const https_1 = require("firebase-functions/v2/https");
/** Same allow-list as the `campaignRequests` rule and the website form's
 * `CampaignBudgetRange` enum — keep all three in step. */
exports.BUDGET_RANGES = [
    "under_50k",
    "50k_2l",
    "2l_10l",
    "10l_plus",
    "not_sure",
];
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
/** Returns the trimmed string, or throws `invalid-argument` naming the field.
 * Length limits match the Firestore rules these forms used to rely on. */
function text(data, field, opts) {
    const value = data[field];
    if (value === undefined || value === null || value === "") {
        if (opts.optional)
            return undefined;
        throw new https_1.HttpsError("invalid-argument", `${field} is required.`);
    }
    if (typeof value !== "string") {
        throw new https_1.HttpsError("invalid-argument", `${field} must be text.`);
    }
    const trimmed = value.trim();
    if (trimmed.length === 0) {
        if (opts.optional)
            return undefined;
        throw new https_1.HttpsError("invalid-argument", `${field} is required.`);
    }
    if (trimmed.length < (opts.min ?? 1) || trimmed.length > opts.max) {
        throw new https_1.HttpsError("invalid-argument", `${field} has an invalid length.`);
    }
    return trimmed;
}
function asObject(data) {
    if (typeof data !== "object" || data === null || Array.isArray(data)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid request.");
    }
    return data;
}
function parseCampaignRequest(data) {
    const d = asObject(data);
    const workEmail = text(d, "workEmail", { max: 319 });
    if (!EMAIL_PATTERN.test(workEmail)) {
        throw new https_1.HttpsError("invalid-argument", "workEmail is not a valid email.");
    }
    const budgetRange = d.budgetRange;
    if (!exports.BUDGET_RANGES.includes(budgetRange)) {
        throw new https_1.HttpsError("invalid-argument", "budgetRange is not allowed.");
    }
    return {
        companyName: text(d, "companyName", { max: 199 }),
        contactName: text(d, "contactName", { max: 199 }),
        workEmail,
        phone: text(d, "phone", { max: 39, optional: true }),
        budgetRange: budgetRange,
        campaignBrief: text(d, "campaignBrief", { max: 2999 }),
    };
}
function parseDeletionRequest(data) {
    const d = asObject(data);
    return {
        identifier: text(d, "identifier", { max: 199 }),
        reason: text(d, "reason", { max: 999, optional: true }),
    };
}

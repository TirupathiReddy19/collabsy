"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCrashAnalytics = void 0;
const bigquery_1 = require("@google-cloud/bigquery");
const firebase_functions_1 = require("firebase-functions");
const https_1 = require("firebase-functions/v2/https");
const adminAuth_1 = require("../shared/adminAuth");
/** Firebase Crashlytics' BigQuery export — see
 * https://firebase.google.com/docs/crashlytics/bigquery-dataset-schema.
 * Table names are the app's bundle ID / package name (same value on both
 * platforms here) with dots replaced by underscores, plus a platform
 * suffix — PLUS a `_REALTIME` suffix, since this project's export only has
 * "Streaming" enabled for Crashlytics (no separate "Daily" batch option
 * exists for Crashlytics the way it does for Analytics), so the
 * unsuffixed batch table this originally queried never gets created at
 * all. Confirmed directly in the BigQuery console: the real table is
 * `online_collabsy_app_ANDROID_REALTIME`. Requires the Crashlytics ->
 * BigQuery link to be turned on in Firebase Console (Project Settings ->
 * Integrations) and the Cloud Functions service account to have BigQuery
 * Data Viewer + Job User. */
const DATASET = "firebase_crashlytics";
const TABLES = {
    ANDROID: "online_collabsy_app_ANDROID_REALTIME",
    IOS: "online_collabsy_app_IOS_REALTIME",
};
const bigquery = new bigquery_1.BigQuery();
async function fetchDailyTrend(platform, days) {
    const table = `${DATASET}.${TABLES[platform]}`;
    const query = `
    SELECT DATE(event_timestamp) AS day, COUNT(*) AS count
    FROM \`${table}\`
    WHERE error_type = 'FATAL'
      AND event_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL @days DAY)
    GROUP BY day
    ORDER BY day
  `;
    try {
        const [rows] = await bigquery.query({ query, params: { days } });
        return rows.map((r) => ({
            day: String(r.day?.value ?? r.day),
            platform,
            count: Number(r.count),
        }));
    }
    catch (error) {
        // Most likely cause: this platform's table doesn't exist yet because
        // BigQuery export was only just turned on, or it has never recorded a
        // crash — treat as "no data" rather than failing the whole request.
        firebase_functions_1.logger.warn(`Crash trend query failed for ${platform}`, error);
        return [];
    }
}
async function fetchTopIssues(platform, days) {
    const table = `${DATASET}.${TABLES[platform]}`;
    // Android exposes a real exception type/message; iOS's export doesn't,
    // so the closest readable label there is the root-cause frame's symbol,
    // falling back to the thread title.
    const labelFields = platform === "ANDROID"
        ? "exceptions[SAFE_OFFSET(0)].type AS exc_type, exceptions[SAFE_OFFSET(0)].exception_message AS exc_message"
        : "blame_frame.symbol AS exc_type, error[SAFE_OFFSET(0)].title AS exc_message";
    const query = `
    WITH filtered AS (
      SELECT issue_id, installation_uuid, event_timestamp, ${labelFields}
      FROM \`${table}\`
      WHERE error_type = 'FATAL'
        AND event_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL @days DAY)
    ),
    agg AS (
      SELECT
        issue_id,
        COUNT(*) AS event_count,
        COUNT(DISTINCT installation_uuid) AS affected_installs,
        MAX(event_timestamp) AS last_seen_at
      FROM filtered
      GROUP BY issue_id
    ),
    latest AS (
      SELECT issue_id, exc_type, exc_message
      FROM filtered
      QUALIFY ROW_NUMBER() OVER (PARTITION BY issue_id ORDER BY event_timestamp DESC) = 1
    )
    SELECT agg.issue_id, agg.event_count, agg.affected_installs, agg.last_seen_at,
           latest.exc_type, latest.exc_message
    FROM agg JOIN latest USING (issue_id)
    ORDER BY agg.event_count DESC
    LIMIT 20
  `;
    try {
        const [rows] = await bigquery.query({ query, params: { days } });
        return rows.map((r) => {
            const type = r.exc_type || "Unknown";
            const message = r.exc_message || "";
            return {
                issueId: r.issue_id,
                platform,
                label: message ? `${type}: ${message}` : type,
                eventCount: Number(r.event_count),
                affectedInstalls: Number(r.affected_installs),
                lastSeenAt: String(r.last_seen_at?.value ?? r.last_seen_at),
            };
        });
    }
    catch (error) {
        firebase_functions_1.logger.warn(`Top crash issues query failed for ${platform}`, error);
        return [];
    }
}
/** Which make/model of device each fatal crash actually happened on — the
 * `device` RECORD (manufacturer, model, architecture) confirmed directly
 * against this table's live BigQuery schema. `manufacturer` is dropped
 * from the label when `model` already starts with it (e.g. Android's own
 * "Google Pixel 6" model strings), so devices aren't double-labelled. */
async function fetchDeviceBreakdown(platform, days) {
    const table = `${DATASET}.${TABLES[platform]}`;
    const query = `
    SELECT
      device.manufacturer AS manufacturer,
      device.model AS model,
      COUNT(*) AS event_count,
      COUNT(DISTINCT installation_uuid) AS affected_installs
    FROM \`${table}\`
    WHERE error_type = 'FATAL'
      AND event_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL @days DAY)
    GROUP BY manufacturer, model
    ORDER BY event_count DESC
    LIMIT 10
  `;
    try {
        const [rows] = await bigquery.query({ query, params: { days } });
        return rows.map((r) => {
            const manufacturer = (r.manufacturer || "").trim();
            const model = (r.model || "Unknown device").trim();
            const label = manufacturer && !model.toLowerCase().startsWith(manufacturer.toLowerCase())
                ? `${manufacturer} ${model}`
                : model;
            return {
                platform,
                model: label,
                eventCount: Number(r.event_count),
                affectedInstalls: Number(r.affected_installs),
            };
        });
    }
    catch (error) {
        firebase_functions_1.logger.warn(`Device breakdown query failed for ${platform}`, error);
        return [];
    }
}
/** Callable from the admin portal's dedicated Crash Analytics page — gated
 * on its own `/crash-analytics` nav permission, granted independently of
 * `/analytics` via Role Management. */
exports.getCrashAnalytics = (0, https_1.onCall)(async (request) => {
    await (0, adminAuth_1.requireAdminOrPermission)(request, "/crash-analytics");
    const requestedDays = request.data?.days;
    const days = Math.min(Math.max(requestedDays ?? 14, 1), 90);
    const [androidTrend, iosTrend, androidIssues, iosIssues, androidDevices, iosDevices,] = await Promise.all([
        fetchDailyTrend("ANDROID", days),
        fetchDailyTrend("IOS", days),
        fetchTopIssues("ANDROID", days),
        fetchTopIssues("IOS", days),
        fetchDeviceBreakdown("ANDROID", days),
        fetchDeviceBreakdown("IOS", days),
    ]);
    return {
        trend: [...androidTrend, ...iosTrend],
        topIssues: [...androidIssues, ...iosIssues]
            .sort((a, b) => b.eventCount - a.eventCount)
            .slice(0, 20),
        topDevices: [...androidDevices, ...iosDevices]
            .sort((a, b) => b.eventCount - a.eventCount)
            .slice(0, 10),
    };
});

"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onAuthUserDeleted = void 0;
const functionsV1 = __importStar(require("firebase-functions/v1"));
const cleanupUserData_1 = require("./cleanupUserData");
/**
 * Safety net for every way an Auth user can disappear *other* than the
 * in-app `deleteAccount` flow — most importantly, deleting a user straight
 * from the Firebase Console (Authentication tab), which only removes the
 * Auth record and never touches Firestore at all. That's exactly how a
 * "deleted" creator kept showing up in Discover and the Admin Creators
 * list — this trigger fires on *any* Auth deletion, regardless of source,
 * and runs the same cleanup `deleteAccount` does. Idempotent, so it's
 * harmless overlap when `deleteAccount` already cleaned up first.
 *
 * Still on the v1 SDK namespace deliberately — `onDelete`/`onCreate`
 * reactive Auth lifecycle triggers haven't been ported to v2; v2's auth
 * triggers (`beforeUserCreated`/`beforeUserSignedIn`) are a different,
 * blocking-function concept and aren't a substitute for this.
 */
exports.onAuthUserDeleted = functionsV1.auth.user().onDelete(async (user) => {
    await (0, cleanupUserData_1.cleanupUserData)(user.uid);
});

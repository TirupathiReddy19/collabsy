"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.encryptMailPassword = encryptMailPassword;
exports.decryptMailPassword = decryptMailPassword;
const crypto_1 = __importDefault(require("crypto"));
const emailConfig_1 = require("./emailConfig");
/**
 * Encrypts/decrypts a brand intern's own mailbox password for at-rest
 * storage in `brandMailCredentials/{uid}` (see `connectBrandMailbox.ts`),
 * which `firestore.rules` denies to every client — only these Cloud
 * Functions, via the Admin SDK, ever read it. AES-256-GCM with a random IV
 * per call, so the same password never produces the same ciphertext twice.
 * Encoded as `iv.authTag.ciphertext`, each base64.
 */
function encryptMailPassword(plaintext) {
    const key = Buffer.from(emailConfig_1.mailCredentialEncryptionKey.value(), "base64");
    const iv = crypto_1.default.randomBytes(12);
    const cipher = crypto_1.default.createCipheriv("aes-256-gcm", key, iv);
    const ciphertext = Buffer.concat([cipher.update(plaintext, "utf8"), cipher.final()]);
    const authTag = cipher.getAuthTag();
    return [iv, authTag, ciphertext].map((buf) => buf.toString("base64")).join(".");
}
function decryptMailPassword(stored) {
    const [ivB64, authTagB64, ciphertextB64] = stored.split(".");
    const key = Buffer.from(emailConfig_1.mailCredentialEncryptionKey.value(), "base64");
    const decipher = crypto_1.default.createDecipheriv("aes-256-gcm", key, Buffer.from(ivB64, "base64"));
    decipher.setAuthTag(Buffer.from(authTagB64, "base64"));
    return Buffer.concat([
        decipher.update(Buffer.from(ciphertextB64, "base64")),
        decipher.final(),
    ]).toString("utf8");
}

import crypto from "crypto";

import { mailCredentialEncryptionKey } from "./emailConfig";

/**
 * Encrypts/decrypts a brand intern's own mailbox password for at-rest
 * storage in `brandMailCredentials/{uid}` (see `connectBrandMailbox.ts`),
 * which `firestore.rules` denies to every client — only these Cloud
 * Functions, via the Admin SDK, ever read it. AES-256-GCM with a random IV
 * per call, so the same password never produces the same ciphertext twice.
 * Encoded as `iv.authTag.ciphertext`, each base64.
 */
export function encryptMailPassword(plaintext: string): string {
  const key = Buffer.from(mailCredentialEncryptionKey.value(), "base64");
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
  const ciphertext = Buffer.concat([cipher.update(plaintext, "utf8"), cipher.final()]);
  const authTag = cipher.getAuthTag();
  return [iv, authTag, ciphertext].map((buf) => buf.toString("base64")).join(".");
}

export function decryptMailPassword(stored: string): string {
  const [ivB64, authTagB64, ciphertextB64] = stored.split(".");
  const key = Buffer.from(mailCredentialEncryptionKey.value(), "base64");
  const decipher = crypto.createDecipheriv(
    "aes-256-gcm",
    key,
    Buffer.from(ivB64, "base64")
  );
  decipher.setAuthTag(Buffer.from(authTagB64, "base64"));
  return Buffer.concat([
    decipher.update(Buffer.from(ciphertextB64, "base64")),
    decipher.final(),
  ]).toString("utf8");
}

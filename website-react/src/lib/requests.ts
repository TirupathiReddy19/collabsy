import { addDoc, collection, serverTimestamp } from 'firebase/firestore'
import { db } from './firebase'

// Matches the `campaignRequests` Firestore rule's `budgetRange in [...]`
// allow-list exactly (see lib/website/providers/campaign_request_providers.dart)
// — keep the two in sync if this ever changes.
export const BUDGET_RANGES = [
  { value: 'under_50k', label: 'Under ₹50,000/mo' },
  { value: '50k_2l', label: '₹50,000 – ₹2,00,000/mo' },
  { value: '2l_10l', label: '₹2,00,000 – ₹10,00,000/mo' },
  { value: '10l_plus', label: '₹10,00,000+/mo' },
  { value: 'not_sure', label: 'Not sure yet' },
] as const

export type BudgetRangeValue = (typeof BUDGET_RANGES)[number]['value']

export interface CampaignRequestInput {
  companyName: string
  contactName: string
  workEmail: string
  phone: string
  budgetRange: BudgetRangeValue
  campaignBrief: string
}

/** Same collection/shape as the Flutter site's Brands page form — a strict
 * field-allowlist Firestore `create` rule enforces this shape, not a Cloud
 * Function, so no backend changes were needed to submit from here too. */
export async function submitCampaignRequest(input: CampaignRequestInput) {
  await addDoc(collection(db, 'campaignRequests'), {
    companyName: input.companyName.trim(),
    contactName: input.contactName.trim(),
    workEmail: input.workEmail.trim(),
    ...(input.phone.trim() ? { phone: input.phone.trim() } : {}),
    budgetRange: input.budgetRange,
    campaignBrief: input.campaignBrief.trim(),
    status: 'new',
    createdAt: serverTimestamp(),
  })
}

export interface DeleteAccountRequestInput {
  identifier: string
  reason: string
}

/** Same `accountDeletionRequests` collection the in-app and old
 * web-legal/delete-account/ flows use. */
export async function submitDeleteAccountRequest(
  input: DeleteAccountRequestInput,
) {
  await addDoc(collection(db, 'accountDeletionRequests'), {
    identifier: input.identifier.trim(),
    ...(input.reason.trim() ? { reason: input.reason.trim() } : {}),
    status: 'pending',
    createdAt: serverTimestamp(),
  })
}

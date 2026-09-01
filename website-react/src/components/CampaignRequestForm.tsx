import { useState } from 'react'
import { BUDGET_RANGES, submitCampaignRequest, type BudgetRangeValue } from '../lib/requests'
import './Form.css'

const EMAIL_PATTERN = /^[^@\s]+@[^@\s]+\.[^@\s]+$/

/** The Brands page's "let us run it for you" lead form — submits straight
 * to Firestore, no email confirmation loop, just an in-page success state.
 * Same collection/shape as the in-app Flutter site's version. */
export function CampaignRequestForm() {
  const [companyName, setCompanyName] = useState('')
  const [contactName, setContactName] = useState('')
  const [workEmail, setWorkEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [budgetRange, setBudgetRange] = useState<BudgetRangeValue>('not_sure')
  const [campaignBrief, setCampaignBrief] = useState('')
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const validate = () => {
    const next: Record<string, string> = {}
    if (!companyName.trim()) next.companyName = 'Enter your company name'
    if (!contactName.trim()) next.contactName = 'Enter your name'
    if (!workEmail.trim()) next.workEmail = 'Enter your work email'
    else if (!EMAIL_PATTERN.test(workEmail.trim())) next.workEmail = 'Enter a valid email'
    if (!campaignBrief.trim()) next.campaignBrief = 'Tell us a bit about your campaign'
    setErrors(next)
    return Object.keys(next).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return
    setSubmitting(true)
    setError(null)
    try {
      await submitCampaignRequest({
        companyName,
        contactName,
        workEmail,
        phone,
        budgetRange,
        campaignBrief,
      })
      setSubmitted(true)
    } catch {
      setError("Couldn't send your request. Please try again.")
    } finally {
      setSubmitting(false)
    }
  }

  if (submitted) {
    return (
      <div className="form-card form-success">
        <div className="form-success-icon">
          <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
            <path d="M5 13l4 4L19 7" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </div>
        <h3>Thanks — we've got it</h3>
        <p>
          Our team will reach out on your work email or WhatsApp within 1 business
          day with your free campaign plan.
        </p>
      </div>
    )
  }

  return (
    <form className="form-card" onSubmit={handleSubmit} noValidate>
      <h3 className="form-title">Get a free campaign plan</h3>
      <p className="form-subtitle">
        Tell us about your brand — our team runs the campaign end to end, you just
        review the results.
      </p>

      <Field label="Company name" error={errors.companyName}>
        <input
          type="text"
          placeholder="e.g. Acme Skincare"
          value={companyName}
          onChange={(e) => setCompanyName(e.target.value)}
        />
      </Field>

      <Field label="Your name" error={errors.contactName}>
        <input
          type="text"
          placeholder="e.g. Priya Sharma"
          value={contactName}
          onChange={(e) => setContactName(e.target.value)}
        />
      </Field>

      <Field label="Work email" error={errors.workEmail}>
        <input
          type="email"
          placeholder="you@company.com"
          value={workEmail}
          onChange={(e) => setWorkEmail(e.target.value)}
        />
      </Field>

      <Field label="Phone (optional)">
        <input
          type="tel"
          placeholder="+91 98765 43210"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
        />
      </Field>

      <Field label="Monthly campaign budget">
        <select value={budgetRange} onChange={(e) => setBudgetRange(e.target.value as BudgetRangeValue)}>
          {BUDGET_RANGES.map((r) => (
            <option key={r.value} value={r.value}>
              {r.label}
            </option>
          ))}
        </select>
      </Field>

      <Field label="What are you looking to achieve?" error={errors.campaignBrief}>
        <textarea
          rows={4}
          placeholder="Tell us about your brand, product, and campaign goals"
          value={campaignBrief}
          onChange={(e) => setCampaignBrief(e.target.value)}
        />
      </Field>

      {error && <p className="form-error-banner">{error}</p>}

      <button type="submit" className="btn btn-primary btn-expanded form-submit" disabled={submitting}>
        {submitting ? 'Sending…' : 'Get Free Campaign Plan'}
      </button>
      <p className="form-fineprint">
        No commitment. Get your free campaign strategy before you spend a single
        rupee.
      </p>
    </form>
  )
}

function Field({
  label,
  error,
  children,
}: {
  label: string
  error?: string
  children: React.ReactNode
}) {
  return (
    <label className="form-field">
      <span className="form-label">{label}</span>
      {children}
      {error && <span className="form-error">{error}</span>}
    </label>
  )
}

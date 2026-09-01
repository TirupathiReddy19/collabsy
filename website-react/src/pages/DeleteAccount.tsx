import { useState } from 'react'
import { submitDeleteAccountRequest } from '../lib/requests'
import '../components/Form.css'
import './DeleteAccount.css'

export function DeleteAccount() {
  const [identifier, setIdentifier] = useState('')
  const [reason, setReason] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!identifier.trim()) {
      setFieldError('Enter the email or phone number on your account')
      return
    }
    setFieldError(null)
    setSubmitting(true)
    setError(null)
    try {
      await submitDeleteAccountRequest({ identifier, reason })
      setSubmitted(true)
    } catch {
      setError("Couldn't send your request. Please try again.")
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <section className="section">
      <div className="container" style={{ maxWidth: 640 }}>
        <h1 className="display-heading" style={{ fontSize: 34, marginBottom: 8 }}>
          Request account deletion
        </h1>
        <p className="body-lead" style={{ maxWidth: 'none', marginBottom: 32 }}>
          You don't need the Collabsy app installed to use this page. Tell us the
          email address or phone number on your account, and we'll delete your
          account and personal data within 30 days.
        </p>

        <div className="form-card">
          {submitted ? (
            <div className="form-success">
              <div className="form-success-icon">
                <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
                  <path d="M5 13l4 4L19 7" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </div>
              <h3>Request received</h3>
              <p>
                We'll process this within 30 days — you'll no longer be able to
                sign in once it's done.
              </p>
            </div>
          ) : (
            <form onSubmit={handleSubmit} noValidate>
              <div className="delete-account-notice">
                <strong>Already have the app? </strong>
                It's faster to delete your account directly from{' '}
                <strong>Settings → Danger Zone → Delete Account</strong> — that
                happens immediately, no waiting required. Use this form only if you
                no longer have the app installed, or can't sign in.
              </div>

              <label className="form-field">
                <span className="form-label">Email or phone number on your account</span>
                <input
                  type="text"
                  placeholder="you@example.com or +91 98765 43210"
                  value={identifier}
                  onChange={(e) => setIdentifier(e.target.value)}
                />
                {fieldError && <span className="form-error">{fieldError}</span>}
              </label>

              <label className="form-field">
                <span className="form-label">Anything else we should know? (optional)</span>
                <textarea
                  rows={3}
                  placeholder="Optional — helps us find your account faster"
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                />
              </label>

              {error && <p className="form-error-banner">{error}</p>}

              <button type="submit" className="btn btn-primary btn-expanded form-submit" disabled={submitting}>
                {submitting ? 'Sending…' : 'Submit Deletion Request'}
              </button>
            </form>
          )}
        </div>

        <p style={{ fontSize: 13.5, color: 'var(--color-text-secondary)', marginTop: 24, lineHeight: 1.6 }}>
          What happens next: this creates a request our team reviews manually — we
          verify it's really your account before anything is deleted, the same care
          the in-app flow takes. Once processed, your profile and personal data are
          removed the same way they would be through the in-app deletion. Questions?
          Email support@collabsy.online.
        </p>
      </div>
    </section>
  )
}

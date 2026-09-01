const WAITLIST_PHONE = '919381487811'
const WAITLIST_MESSAGE = "Hi Collabsy! I'd like to join the waitlist for the app."

/** "Get the app" CTA — the app isn't live on the Play/App Store yet, so this
 * opens WhatsApp on the same number the Contact page uses, exactly matching
 * the Flutter site's `WaitlistCtaButton`. Swap for real store badges once
 * the app is published. */
export function waitlistUrl(message = WAITLIST_MESSAGE) {
  return `https://wa.me/${WAITLIST_PHONE}?text=${encodeURIComponent(message)}`
}

export function WaitlistButton({
  label = 'Join the App Waitlist',
  compact = false,
  className,
}: {
  label?: string
  compact?: boolean
  className?: string
}) {
  return (
    <a
      href={waitlistUrl()}
      target="_blank"
      rel="noopener noreferrer"
      className={`btn btn-primary ${compact ? 'btn-compact' : 'btn-expanded'} ${className ?? ''}`}
    >
      {label}
    </a>
  )
}

export function WhatsAppButton({
  label = 'Chat on WhatsApp',
  className,
}: {
  label?: string
  className?: string
}) {
  return (
    <a
      href={waitlistUrl('Hi Collabsy! I have a question.')}
      target="_blank"
      rel="noopener noreferrer"
      className={`btn btn-ghost ${className ?? ''}`}
    >
      {label}
    </a>
  )
}

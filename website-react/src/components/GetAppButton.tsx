import { useState } from 'react'
import { useLocation } from 'react-router-dom'
import { trackEvent } from '../lib/firebase'
import './GetAppButton.css'

// Google Play reads a real `referrer` param and surfaces it in Play Console's
// acquisition reports — that's a genuine, supported attribution channel.
// Apple has no equivalent for a plain query string on an apps.apple.com link;
// real iOS attribution needs Custom Product Pages/marketing codes set up in
// App Store Connect first, which is out of scope here, so that link stays
// plain and the GA4 click event is the only signal on that side for now.
const PLAY_STORE_URL =
  'https://play.google.com/store/apps/details?id=online.collabsy.app&referrer=utm_source%3Dwebsite%26utm_medium%3Dcta'
const APP_STORE_URL = 'https://apps.apple.com/in/app/collabsy/id6808197823'

function detectStoreUrl(): string | null {
  const ua = navigator.userAgent
  if (/Android/i.test(ua)) return PLAY_STORE_URL
  if (/iPhone|iPad|iPod/i.test(ua)) return APP_STORE_URL
  return null
}

/** "Get the app" CTA — matches the live Flutter site's `GetAppButton`
 * exactly: on an Android or iPhone browser it opens that platform's store
 * listing directly; anywhere else (desktop, unknown) it asks which store,
 * since a desktop visitor can't tell which one they need on their phone. */
export function GetAppButton({
  label = 'Download the App',
  compact = false,
  className,
}: {
  label?: string
  compact?: boolean
  className?: string
}) {
  const [open, setOpen] = useState(false)
  const { pathname } = useLocation()

  const handleClick = () => {
    const url = detectStoreUrl()
    const store = url === PLAY_STORE_URL ? 'android' : url === APP_STORE_URL ? 'ios' : 'unknown'
    trackEvent('app_download_click', { store, page: pathname })
    if (url) {
      window.open(url, '_blank', 'noopener,noreferrer')
    } else {
      setOpen(true)
    }
  }

  return (
    <>
      <button
        type="button"
        onClick={handleClick}
        className={`btn btn-primary ${compact ? 'btn-compact' : 'btn-expanded'} ${className ?? ''}`}
      >
        {label}
      </button>
      {open && <ChooseStoreDialog onClose={() => setOpen(false)} page={pathname} />}
    </>
  )
}

function ChooseStoreDialog({ onClose, page }: { onClose: () => void; page: string }) {
  return (
    <div className="store-dialog-overlay" onClick={onClose}>
      <div className="store-dialog" onClick={(e) => e.stopPropagation()}>
        <h3 className="store-dialog-title">Get the Collabsy app</h3>
        <p className="store-dialog-body">
          Available on Android and iPhone in India. Pick your phone's store to open the
          listing.
        </p>
        <a
          className="btn btn-primary btn-expanded store-dialog-option"
          href={PLAY_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => trackEvent('app_download_click', { store: 'android', page })}
        >
          Google Play (Android)
        </a>
        <a
          className="btn btn-primary btn-expanded store-dialog-option"
          href={APP_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => trackEvent('app_download_click', { store: 'ios', page })}
        >
          App Store (iPhone)
        </a>
        <button type="button" className="store-dialog-close" onClick={onClose}>
          Close
        </button>
      </div>
    </div>
  )
}

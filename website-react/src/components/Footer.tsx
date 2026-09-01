import { Link } from 'react-router-dom'
import { CollabsyMark } from './CollabsyMark'
import { waitlistUrl } from './WaitlistButton'
import './Footer.css'

const COMPANY_LINKS = [
  { path: '/', label: 'Home' },
  { path: '/creators', label: 'Creators' },
  { path: '/brands', label: 'Brands' },
  { path: '/about', label: 'About' },
  { path: '/contact', label: 'Contact' },
]

const LEGAL_LINKS = [
  { path: '/privacy', label: 'Privacy Policy' },
  { path: '/terms', label: 'Terms of Service' },
  { path: '/delete-account', label: 'Delete Account' },
]

export function Footer() {
  return (
    <footer className="footer">
      <div className="container footer-inner">
        <div className="footer-grid">
          <div className="footer-brand">
            <div className="footer-brand-row">
              <span className="footer-mark">
                <CollabsyMark />
              </span>
              <span className="footer-wordmark">Collabsy</span>
            </div>
            <p className="footer-tagline">
              Influencer marketing that connects Creators and Brands — built for real
              campaigns, not vanity metrics.
            </p>
          </div>

          <div className="footer-column">
            <h3 className="footer-heading">Company</h3>
            {COMPANY_LINKS.map((link) => (
              <Link key={link.path} to={link.path} className="footer-link">
                {link.label}
              </Link>
            ))}
          </div>

          <div className="footer-column">
            <h3 className="footer-heading">Legal</h3>
            {LEGAL_LINKS.map((link) => (
              <Link key={link.path} to={link.path} className="footer-link">
                {link.label}
              </Link>
            ))}
          </div>

          <div className="footer-column">
            <h3 className="footer-heading">Contact</h3>
            <a className="footer-link footer-contact-line" href="mailto:hello@collabsy.online">
              <MailIcon /> hello@collabsy.online
            </a>
            <a
              className="footer-link footer-contact-line"
              href={waitlistUrl()}
              target="_blank"
              rel="noopener noreferrer"
            >
              <ChatIcon /> +91 93814 87811
            </a>
            <span className="footer-link footer-contact-line footer-static">
              <PinIcon /> Bangalore, India
            </span>
          </div>
        </div>

        <div className="footer-divider" />
        <p className="footer-copyright">© {new Date().getFullYear()} Collabsy. All rights reserved.</p>
      </div>
    </footer>
  )
}

function MailIcon() {
  return (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path
        d="M3 6.5 12 13l9-6.5M4 5h16a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1Z"
        stroke="currentColor"
        strokeWidth="1.6"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function ChatIcon() {
  return (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path
        d="M4 20l1.6-4.2A8 8 0 1 1 9 18.6L4 20Z"
        stroke="currentColor"
        strokeWidth="1.6"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function PinIcon() {
  return (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path
        d="M12 21s-7-6.2-7-11.5A7 7 0 0 1 19 9.5C19 14.8 12 21 12 21Z"
        stroke="currentColor"
        strokeWidth="1.6"
        strokeLinejoin="round"
      />
      <circle cx="12" cy="9.5" r="2.4" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

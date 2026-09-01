import { SectionHeading } from '../components/SectionHeading'
import { waitlistUrl } from '../components/WaitlistButton'
import './Contact.css'

export function Contact() {
  return (
    <section className="section">
      <div className="container">
        <SectionHeading
          title="Get in touch"
          subtitle="Have a question, or want a campaign plan for your brand? Reach us any of these ways — or use the Brands page's form for a full campaign brief."
        />
        <div className="contact-row">
          <a className="contact-card" href="mailto:hello@collabsy.online">
            <span className="contact-card-icon">
              <MailIcon />
            </span>
            <span className="contact-card-label">Email</span>
            <span className="contact-card-value">hello@collabsy.online</span>
          </a>
          <a
            className="contact-card"
            href={waitlistUrl()}
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="contact-card-icon">
              <ChatIcon />
            </span>
            <span className="contact-card-label">WhatsApp</span>
            <span className="contact-card-value">+91 93814 87811</span>
          </a>
          <div className="contact-card contact-card-static">
            <span className="contact-card-icon">
              <PinIcon />
            </span>
            <span className="contact-card-label">Based in</span>
            <span className="contact-card-value">Bangalore, India</span>
          </div>
        </div>
      </div>
    </section>
  )
}

function MailIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="M3 6.5 12 13l9-6.5M4 5h16a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1Z" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}
function ChatIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="M4 20l1.6-4.2A8 8 0 1 1 9 18.6L4 20Z" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}
function PinIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="M12 21s-7-6.2-7-11.5A7 7 0 0 1 19 9.5C19 14.8 12 21 12 21Z" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round" />
      <circle cx="12" cy="9.5" r="2.4" stroke="currentColor" strokeWidth="1.6" />
    </svg>
  )
}

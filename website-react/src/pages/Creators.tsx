import { useScrollReveal } from '../lib/useScrollReveal'
import { SectionHeading } from '../components/SectionHeading'
import { Bullet } from '../components/Bullet'
import { WaitlistButton } from '../components/WaitlistButton'
import './Creators.css'

const STEPS = [
  {
    n: '01',
    title: 'Create your profile',
    body: 'Sign up and connect your Instagram Business account — your follower count and recent posts show up automatically.',
  },
  {
    n: '02',
    title: 'Browse open campaigns',
    body: 'Filter by niche and category to find D2C brands looking for someone like you.',
  },
  {
    n: '03',
    title: 'Apply and chat',
    body: 'Apply in a tap, then talk deliverables, timelines, and compensation directly with the brand in-app.',
  },
  {
    n: '04',
    title: 'Collaborate and grow',
    body: 'Deliver the campaign, build a track record, and keep discovering your next collaboration.',
  },
]

export function Creators() {
  const stepsRef = useScrollReveal<HTMLDivElement>('.step-card')

  return (
    <>
      <section className="page-hero">
        <div className="container">
          <h1 className="page-hero-title display-heading">
            Turn your influence into
            <br />
            real brand partnerships
          </h1>
          <p className="page-hero-sub body-lead" style={{ margin: '0 auto 32px' }}>
            Collabsy connects you with D2C brands looking for creators like you —
            discover campaigns, apply, and work directly with brands you actually
            want to collaborate with.
          </p>
          <div style={{ display: 'flex', justifyContent: 'center' }}>
            <div style={{ width: 260 }}>
              <WaitlistButton />
            </div>
          </div>
        </div>
      </section>

      <section className="section">
        <div className="container creators-grid">
          <div>
            <h2 className="display-heading" style={{ fontSize: 30, marginBottom: 20 }}>
              Why creators use Collabsy
            </h2>
            <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
              <Bullet>Discover paid campaigns from real D2C brands, filtered by your niche</Bullet>
              <Bullet>Apply in a tap — no lengthy pitch decks or cold DMs</Bullet>
              <Bullet>
                Chat and agree on deliverables and compensation directly with the brand
              </Bullet>
              <Bullet>A verified profile that builds trust with every brand you apply to</Bullet>
              <Bullet>
                Built around micro-influencers (10K–50K) — your engaged audience is the
                point, not just reach
              </Bullet>
            </ul>
          </div>
          <div className="creators-info-panel">
            <InfoIcon />
            <h3 style={{ fontSize: 18, margin: '14px 0 8px' }}>How compensation works</h3>
            <p style={{ fontSize: 14.5, color: 'var(--color-text-secondary)', lineHeight: 1.6, margin: 0 }}>
              Collabsy helps you discover and connect with brands — any agreement on
              deliverables or compensation is worked out directly between you and the
              brand, the same way it would be if they'd reached out to you directly.
            </p>
          </div>
        </div>
      </section>

      <section className="section" style={{ background: 'var(--color-background)' }}>
        <div className="container">
          <SectionHeading eyebrow="How it works" title="Four steps to your next collaboration" />
          <div className="step-grid" ref={stepsRef}>
            {STEPS.map((s) => (
              <div className="step-card" key={s.n}>
                <span className="step-card-number" style={{ color: 'var(--color-creator)' }}>
                  {s.n}
                </span>
                <h3 className="step-card-title">{s.title}</h3>
                <p className="step-card-body">{s.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section section-dark" style={{ textAlign: 'center' }}>
        <div className="container">
          <h2 className="display-heading" style={{ color: 'white', fontSize: 'clamp(28px,4vw,42px)' }}>
            Ready to find your next brand partner?
          </h2>
          <p className="body-lead on-dark" style={{ margin: '12px auto 28px' }}>
            Join the waitlist and we'll let you know the moment you're in.
          </p>
          <WaitlistButton />
        </div>
      </section>
    </>
  )
}

function InfoIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" style={{ color: 'var(--color-creator)' }}>
      <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.6" />
      <path d="M12 11v5M12 8v.01" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  )
}

import { useRef } from 'react'
import { useScrollReveal } from '../lib/useScrollReveal'
import { SectionHeading } from '../components/SectionHeading'
import { Bullet } from '../components/Bullet'
import { WaitlistButton } from '../components/WaitlistButton'
import { CampaignRequestForm } from '../components/CampaignRequestForm'
import './Brands.css'

const SERVICES = [
  {
    icon: <MegaphoneIcon />,
    title: 'Influencer Marketing Campaigns',
    body: 'Connect with the right influencers to drive sales and conversions for your D2C brand.',
  },
  {
    icon: <FilmIcon />,
    title: 'UGC Content Creation',
    body: 'High-quality user-generated content that resonates with your target audience and boosts ROI.',
  },
  {
    icon: <HandshakeIcon />,
    title: 'Brand Collaborations',
    body: 'Strategic partnerships that align with your brand values and drive measurable results.',
  },
  {
    icon: <MapIcon />,
    title: 'Campaign Strategy & Execution',
    body: 'End-to-end campaign management focused on performance and conversions.',
  },
  {
    icon: <InsightsIcon />,
    title: 'Performance Tracking & Optimization',
    body: 'Real-time analytics and continuous optimization to maximize ROI.',
  },
]

const MANAGED_STEPS = [
  {
    n: '01',
    title: 'Understand your brand goals',
    body: 'We analyze your objectives, target market, and sales goals to shape a tailored strategy.',
  },
  {
    n: '02',
    title: 'Build a custom campaign plan',
    body: 'A data-driven plan focused on conversions and measurable results, with budget allocated for maximum ROI.',
  },
  {
    n: '03',
    title: 'Execute with targeted creators',
    body: 'We select micro-influencers (10K–50K) and run a content-first, performance-driven campaign.',
  },
  {
    n: '04',
    title: 'Track results and optimize',
    body: 'Conversion tracking, ROI reporting, and ongoing optimization as the campaign runs.',
  },
]

const ENGINE_INPUTS = [
  { label: 'Right Creator', detail: 'Micro-influencers, 10K–50K followers' },
  { label: 'Right Audience', detail: 'Niche-targeted, not just reach' },
  { label: 'Right Content', detail: 'Content-first — Reels & short-form video' },
  { label: 'Right Strategy', detail: 'Data-driven, conversion-focused planning' },
]

export function Brands() {
  const formRef = useRef<HTMLDivElement>(null)
  const scrollToForm = () => formRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' })

  const serviceRef = useScrollReveal<HTMLDivElement>('.info-card')
  const stepRef = useScrollReveal<HTMLDivElement>('.step-card')
  const engineRef = useScrollReveal<HTMLDivElement>('.engine-input')

  return (
    <>
      <section className="page-hero">
        <div className="container">
          <h1 className="page-hero-title display-heading">Get sales, not just views</h1>
          <p className="page-hero-sub body-lead">
            Whether you want hands-on control or a team to run it end to end,
            Collabsy has a path for your D2C brand.
          </p>
        </div>
      </section>

      <section className="section">
        <div className="container">
          <SectionHeading title="Two ways to work with Collabsy" />
          <div className="brands-plans">
            <div className="plan-card">
              <span className="plan-tag plan-tag-serve">SELF-SERVE</span>
              <h3 className="plan-title">Use the platform yourself</h3>
              <ul style={{ listStyle: 'none', padding: 0, margin: '20px 0 24px' }}>
                <Bullet>Post campaigns and set your own budget and requirements</Bullet>
                <Bullet>Browse verified micro-influencers (10K–50K followers)</Bullet>
                <Bullet>Review applications and message creators directly</Bullet>
                <Bullet>Full control, no management fee</Bullet>
              </ul>
              <WaitlistButton />
            </div>
            <div className="plan-card plan-card-highlight">
              <span className="plan-tag plan-tag-managed">MANAGED</span>
              <h3 className="plan-title">Let us run it for you</h3>
              <ul style={{ listStyle: 'none', padding: 0, margin: '20px 0 24px' }}>
                <Bullet>Our team plans, sources creators, and executes the full campaign</Bullet>
                <Bullet>Content-first strategy focused on Reels and short-form video</Bullet>
                <Bullet>Real-time performance tracking and optimization</Bullet>
                <Bullet>Custom pricing based on your campaign size — no fixed rate card, ask us for a plan</Bullet>
              </ul>
              <button className="btn btn-primary btn-expanded" style={{ width: '100%' }} onClick={scrollToForm}>
                Get Free Campaign Plan
              </button>
            </div>
          </div>
        </div>
      </section>

      <section className="section brands-engine">
        <div className="container">
          <SectionHeading
            eyebrow="Our approach"
            title="The campaign engine behind every managed plan"
            subtitle="Four inputs our team controls for — the same four things that separate a campaign that converts from one that just gets views."
          />
          <div className="engine-row" ref={engineRef}>
            {ENGINE_INPUTS.map((input, i) => (
              <div className="engine-input" key={input.label}>
                <span className="engine-input-label">{input.label}</span>
                <span className="engine-input-detail">{input.detail}</span>
                {i < ENGINE_INPUTS.length - 1 && <span className="engine-plus">+</span>}
              </div>
            ))}
          </div>
          <div className="engine-equals">
            <span className="engine-equals-line" />
            <span className="engine-equals-result">Better ROI</span>
            <span className="engine-equals-line" />
          </div>
        </div>
      </section>

      <section className="section" style={{ background: 'var(--color-background)' }}>
        <div className="container">
          <SectionHeading
            eyebrow="Managed campaigns"
            title="What our team handles for you"
            subtitle="Comprehensive influencer marketing solutions designed to drive sales and ROI for D2C brands."
          />
          <div className="card-grid" ref={serviceRef}>
            {SERVICES.map((s) => (
              <div className="info-card" key={s.title}>
                <div className="info-card-icon">{s.icon}</div>
                <h3 className="info-card-title">{s.title}</h3>
                <p className="info-card-body">{s.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section">
        <div className="container">
          <SectionHeading eyebrow="How it works" title="Our proven 4-step process" />
          <div className="step-grid" ref={stepRef}>
            {MANAGED_STEPS.map((s) => (
              <div className="step-card" key={s.n}>
                <span className="step-card-number" style={{ color: 'var(--color-brand)' }}>
                  {s.n}
                </span>
                <h3 className="step-card-title">{s.title}</h3>
                <p className="step-card-body">{s.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section" style={{ background: 'var(--color-primary-light)' }} ref={formRef}>
        <div className="container" style={{ display: 'flex', justifyContent: 'center' }}>
          <div style={{ maxWidth: 640, width: '100%' }}>
            <CampaignRequestForm />
          </div>
        </div>
      </section>
    </>
  )
}

function MegaphoneIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M3 10v4a1 1 0 0 0 1 1h2l7 4V5L6 9H4a1 1 0 0 0-1 1Z" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round" />
      <path d="M17 9a4 4 0 0 1 0 6" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  )
}
function FilmIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" strokeWidth="1.6" />
      <path d="M9 5v14M15 5v14M3 9h4M3 15h4M17 9h4M17 15h4" stroke="currentColor" strokeWidth="1.4" />
    </svg>
  )
}
function HandshakeIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M2 12l4-4 4 3 3-3 4 4M6 8l3 3-2 2-3-3M18 8l-3 3M9 15l2 2 4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}
function MapIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2-6-2Z" stroke="currentColor" strokeWidth="1.6" strokeLinejoin="round" />
      <path d="M9 4v14M15 6v14" stroke="currentColor" strokeWidth="1.4" />
    </svg>
  )
}
function InsightsIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M4 20V10M11 20V4M18 20v-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
    </svg>
  )
}

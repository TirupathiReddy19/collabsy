import { useEffect, useRef } from 'react'
import { Link } from 'react-router-dom'
import { gsap } from '../lib/gsap'
import { useScrollReveal } from '../lib/useScrollReveal'
import { HeroCanvas } from '../three/HeroCanvas'
import { SectionHeading } from '../components/SectionHeading'
import { WaitlistButton } from '../components/WaitlistButton'
import './Home.css'

const FLOW_STEPS = ['Profile', 'Match', 'Chat', 'Collaborate']

const HOW_IT_WORKS = [
  {
    n: '01',
    title: 'Create your profile',
    body: "Creators connect Instagram and set up a profile; Brands describe what they're looking for.",
  },
  {
    n: '02',
    title: 'Discover a match',
    body: 'Brands browse verified micro-influencers; Creators browse open campaigns in their niche.',
  },
  {
    n: '03',
    title: 'Talk it through',
    body: 'Apply, chat, and agree on deliverables directly — no middleman reading your messages.',
  },
  {
    n: '04',
    title: 'Collaborate & grow',
    body: 'Run the campaign, build a track record, and do it again with your next match.',
  },
]

const PRINCIPLES = [
  {
    n: '01',
    title: 'Built for conversions',
    body: 'Every feature is designed around real campaign outcomes, not vanity metrics.',
  },
  {
    n: '02',
    title: 'Micro-influencers, real trust',
    body: "We're built around creators with 10K–50K followers — smaller, more engaged audiences.",
  },
  {
    n: '03',
    title: 'Verified on both sides',
    body: 'Creators and Brands are both reviewed before they can post or apply, so conversations stay genuine.',
  },
]

export function Home() {
  const heroRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!heroRef.current) return
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    const ctx = gsap.context(() => {
      const lines = heroRef.current!.querySelectorAll('.home-hero-line-inner')
      const rest = heroRef.current!.querySelectorAll('.home-hero-fade')
      if (reduced) {
        gsap.set(lines, { yPercent: 0 })
        gsap.set(rest, { opacity: 1, y: 0 })
        return
      }
      gsap.set(lines, { yPercent: 100 })
      gsap.set(rest, { opacity: 0, y: 18 })
      const tl = gsap.timeline({ delay: 0.15 })
      tl.to(lines, {
        yPercent: 0,
        duration: 1,
        stagger: 0.12,
        ease: 'power4.out',
      }).to(
        rest,
        { opacity: 1, y: 0, duration: 0.7, stagger: 0.1, ease: 'power2.out' },
        '-=0.5',
      )
    }, heroRef)
    return () => ctx.revert()
  }, [])

  const stepsRef = useScrollReveal<HTMLDivElement>('.home-step')
  const audienceRef = useScrollReveal<HTMLDivElement>('.home-audience-card')
  const principleRef = useScrollReveal<HTMLDivElement>('.home-principle')

  return (
    <>
      <section className="home-hero section-dark" ref={heroRef}>
        <HeroCanvas />
        <div className="home-hero-scrim" aria-hidden="true" />
        <div className="container home-hero-inner">
          <h1 className="home-hero-headline display-heading">
            <span className="home-hero-line">
              <span className="home-hero-line-inner">Where Creators and Brands</span>
            </span>
            <span className="home-hero-line">
              <span className="home-hero-line-inner">actually get work done</span>
            </span>
          </h1>
          <p className="body-lead on-dark home-hero-fade home-hero-sub">
            Collabsy connects D2C brands with micro-influencers for campaigns that
            convert — discover, apply, chat, and collaborate, all in one place.
          </p>

          <div className="home-hero-fade home-flow" aria-label="How Collabsy works, in short">
            {FLOW_STEPS.map((step, i) => (
              <span className="home-flow-step" key={step}>
                <span className="home-flow-dot" />
                {step}
                {i < FLOW_STEPS.length - 1 && <span className="home-flow-arrow">→</span>}
              </span>
            ))}
          </div>

          <div className="home-hero-fade home-hero-ctas">
            <Link to="/creators" className="btn btn-primary btn-expanded">
              For Creators
            </Link>
            <Link to="/brands" className="btn btn-outline btn-on-dark btn-expanded">
              For Brands
            </Link>
          </div>
        </div>
      </section>

      <section className="section">
        <div className="container">
          <SectionHeading
            eyebrow="How it works"
            title="From first message to finished campaign"
            subtitle="The same four steps, whichever side of the table you're on."
          />
          <div className="home-steps" ref={stepsRef}>
            {HOW_IT_WORKS.map((step) => (
              <div className="home-step" key={step.n}>
                <span className="home-step-number">{step.n}</span>
                <h3 className="home-step-title">{step.title}</h3>
                <p className="home-step-body">{step.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section" style={{ background: 'var(--color-primary-light)' }}>
        <div className="container home-audience" ref={audienceRef}>
          <AudienceCard
            title="For Creators"
            accent="var(--color-creator)"
            bullets={[
              'Discover paid campaigns from real D2C brands',
              'Apply in a tap, chat with brands directly',
              'Get verified and build a trustworthy profile',
            ]}
            ctaLabel="Explore for Creators"
            to="/creators"
          />
          <AudienceCard
            title="For Brands"
            accent="var(--color-brand)"
            bullets={[
              'Browse verified micro-influencers (10K–50K followers)',
              'Post a campaign or apply for a managed one',
              'Review applications and message creators directly',
            ]}
            ctaLabel="Explore for Brands"
            to="/brands"
          />
        </div>
      </section>

      <section className="section">
        <div className="container">
          <SectionHeading
            title="Why Collabsy"
            subtitle="We're just getting started, so instead of borrowed logos and made-up numbers, here's what actually guides how we build this."
          />
          <div className="home-principles" ref={principleRef}>
            {PRINCIPLES.map((p) => (
              <div className="home-principle" key={p.n}>
                <span className="home-principle-number">{p.n}</span>
                <div>
                  <h3 className="home-principle-title">{p.title}</h3>
                  <p className="home-principle-body">{p.body}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section section-dark home-final-cta">
        <div className="home-final-glow" aria-hidden="true" />
        <div className="container home-final-inner">
          <h2 className="display-heading home-final-title">Ready to get started?</h2>
          <p className="body-lead on-dark">
            Creators and Brands both start the same way — join the waitlist and
            we'll bring you in as we roll out.
          </p>
          <WaitlistButton />
        </div>
      </section>
    </>
  )
}

function AudienceCard({
  title,
  accent,
  bullets,
  ctaLabel,
  to,
}: {
  title: string
  accent: string
  bullets: string[]
  ctaLabel: string
  to: string
}) {
  const cardRef = useRef<HTMLDivElement>(null)

  const handleMove = (e: React.MouseEvent) => {
    const el = cardRef.current
    if (!el) return
    const rect = el.getBoundingClientRect()
    const x = ((e.clientX - rect.left) / rect.width - 0.5) * 8
    const y = ((e.clientY - rect.top) / rect.height - 0.5) * -8
    gsap.to(el, { rotateY: x, rotateX: y, duration: 0.4, ease: 'power2.out' })
  }
  const handleLeave = () => {
    if (!cardRef.current) return
    gsap.to(cardRef.current, { rotateY: 0, rotateX: 0, duration: 0.5, ease: 'power3.out' })
  }

  return (
    <div
      className="home-audience-card"
      ref={cardRef}
      onMouseMove={handleMove}
      onMouseLeave={handleLeave}
      style={{ '--accent': accent } as React.CSSProperties}
    >
      <h3 className="home-audience-title" style={{ color: accent }}>
        {title}
      </h3>
      <ul className="home-audience-bullets">
        {bullets.map((b) => (
          <li key={b}>
            <CheckIcon />
            {b}
          </li>
        ))}
      </ul>
      <Link to={to} className="home-audience-link">
        {ctaLabel} <span aria-hidden="true">→</span>
      </Link>
    </div>
  )
}

function CheckIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path
        d="M5 13l4 4L19 7"
        stroke="currentColor"
        strokeWidth="2.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

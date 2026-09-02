import { useScrollReveal } from '../lib/useScrollReveal'
import { SectionHeading } from '../components/SectionHeading'
import { LazyCanvas } from '../three/LazyCanvas'

const VALUES = [
  {
    icon: <TrendingIcon />,
    title: 'Sales over vanity metrics',
    body: 'Every feature we build is judged by whether it moves a real campaign closer to a conversion — not by follower counts or impressions.',
  },
  {
    icon: <GroupsIcon />,
    title: 'Micro-influencers, real trust',
    body: 'We believe smaller, more engaged audiences (10K–50K) build more trust with buyers than reach alone ever could.',
  },
  {
    icon: <HandshakeIcon />,
    title: 'Direct relationships',
    body: 'Creators and Brands talk to each other, not through us. We build the tools; you build the relationship.',
  },
  {
    icon: <VerifiedIcon />,
    title: 'Verified, not anonymous',
    body: "Both sides are reviewed before they can post a campaign or apply to one, so who you're talking to is who they say they are.",
  },
]

export function About() {
  const cardsRef = useScrollReveal<HTMLDivElement>('.info-card')

  return (
    <>
      <section className="page-hero">
        <LazyCanvas loader={() => import('../three/JourneyCanvasScene')} />
        <div className="container">
          <h1 className="page-hero-title display-heading">Why we built Collabsy</h1>
        </div>
      </section>

      <section className="section">
        <div className="container" style={{ maxWidth: 720 }}>
          <p className="body-lead" style={{ maxWidth: 'none', marginBottom: 16 }}>
            Influencer marketing in India runs on two broken defaults: brands paying
            for reach they can't trace to a single sale, and creators fielding cold
            DMs from brands they've never heard of. Collabsy exists to fix both
            sides of that at once.
          </p>
          <p className="body-lead" style={{ maxWidth: 'none', marginBottom: 16 }}>
            We started with D2C brands who wanted campaigns judged on sales, not
            screenshots — and built a platform where Creators and Brands can find
            each other directly, verify who they're working with, and run a
            campaign end to end without either side guessing.
          </p>
          <p className="body-lead" style={{ maxWidth: 'none' }}>
            We're early. Rather than fill this page with client logos we haven't
            earned yet, here's what we're actually optimizing for as we build.
          </p>
        </div>
      </section>

      <section className="section" style={{ background: 'var(--color-background)' }}>
        <div className="container">
          <SectionHeading title="What we optimize for" />
          <div className="card-grid" ref={cardsRef}>
            {VALUES.map((v) => (
              <div className="info-card" key={v.title}>
                <div className="info-card-icon">{v.icon}</div>
                <h3 className="info-card-title">{v.title}</h3>
                <p className="info-card-body">{v.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  )
}

function TrendingIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="M3 17l6-6 4 4 8-8M21 7h-6" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}
function GroupsIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <circle cx="9" cy="8" r="3" stroke="currentColor" strokeWidth="1.6" />
      <circle cx="17" cy="10" r="2.4" stroke="currentColor" strokeWidth="1.6" />
      <path d="M3 20c0-3 3-5 6-5s6 2 6 5M15 20c0-2 1.5-4 5-4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  )
}
function HandshakeIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="M2 12l4-4 4 3 3-3 4 4M6 8l3 3-2 2-3-3M18 8l-3 3M9 15l2 2 4-4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}
function VerifiedIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="m9 12 2 2 4-4" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M12 3l2.4 1.2 2.6-.3 1 2.4 2.4 1-.3 2.6L21 12l-1.2 2.4.3 2.6-2.4 1-1 2.4-2.6-.3L12 21l-2.4-1.2-2.6.3-1-2.4-2.4-1 .3-2.6L3 12l1.2-2.4-.3-2.6 2.4-1 1-2.4 2.6.3Z" stroke="currentColor" strokeWidth="1.4" strokeLinejoin="round" />
    </svg>
  )
}

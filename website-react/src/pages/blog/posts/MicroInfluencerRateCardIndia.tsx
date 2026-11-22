import { Link } from 'react-router-dom'

export function MicroInfluencerRateCardIndia() {
  return (
    <article className="blog-prose">
      <p>
        Most rate card guides online are built for US creators quoting in dollars.
        If you're a 10,000–50,000 follower Instagram creator in India, those numbers
        don't map onto what brands here actually pay — and brands have noticed that
        most creators your size don't have a rate card at all, which means every
        negotiation starts from zero.
      </p>
      <p>Here's a rate card built for your actual tier and your actual market.</p>

      <h2>Why a rate card changes the negotiation</h2>
      <p>
        Without a rate card, a brand's first offer sets the anchor — and it's rarely
        in your favor. A one-page rate card flips that: you name your price before
        they do, you look like you've done this before (even if it's your first
        deal), and you stop re-deciding your rates from scratch every single time
        someone DMs you.
      </p>

      <h2>What to actually charge (India, 10K–50K tier)</h2>
      <p>
        Published 2026 rate-card guides from Indian creator-economy platforms and
        agencies give wide, overlapping ranges for this tier — treat these as a
        starting point to anchor your own number, not a fixed price list. Niche,
        engagement rate, and content complexity swing the number a lot:
      </p>
      <ul>
        <li><strong>Instagram feed post:</strong> roughly ₹8,000–₹40,000</li>
        <li><strong>Instagram Reel:</strong> roughly ₹8,000–₹75,000</li>
        <li><strong>Story series (3–5 stories):</strong> roughly ₹5,000–₹20,000</li>
      </ul>
      <p>
        Sources:{' '}
        <a href="https://ticktime.media/blogs/influencer-rate-card-india-2026-instagram-reel-story-youtube-video-pricing" target="_blank" rel="noopener noreferrer">Ticktime Media</a>,{' '}
        <a href="https://www.tring.co.in/influencer-marketing/influencer-price-list-in-india" target="_blank" rel="noopener noreferrer">Tring</a>,{' '}
        <a href="https://bosswallah.com/blog/brand-collaborations/micro-influencer-rates-in-india-what-to-actually-charge-in-2026/" target="_blank" rel="noopener noreferrer">Bosswallah</a>,{' '}
        <a href="https://upgrowth.in/influencer-marketing-pricing-india-2026/" target="_blank" rel="noopener noreferrer">upGrowth</a>. These are agency/platform estimates, not a fixed rate card from any single authority — your actual number depends on your real engagement rate and niche, not just follower count.
      </p>
      <p>
        <strong>Usage rights and exclusivity cost extra</strong> — if a brand wants to
        run your content as a paid ad, repost it on their own page, or wants you to
        not work with competing brands for a period, that's a separate line item on
        top of the base rate, not something to throw in for free.
      </p>

      <h2>The rate card template</h2>
      <p>Keep it to one page. Here's the structure that covers what brands actually ask for:</p>
      <blockquote>
        <strong>[Your Name] — Creator Rate Card {new Date().getFullYear()}</strong>
        <br />
        Followers: [count] · Engagement rate: [%] · Niche: [your niche] · Location: [city, India]
        <br />
        <br />
        <strong>Content</strong>
        <br />
        Instagram Reel — ₹[your rate]
        <br />
        Instagram Feed Post — ₹[your rate]
        <br />
        Story Series (3–5 stories) — ₹[your rate]
        <br />
        Bundle (Reel + 3 Stories) — ₹[your rate, usually ~20% off the sum]
        <br />
        <br />
        <strong>Add-ons</strong>
        <br />
        Usage rights (brand repost/paid ad, 30 days) — +₹[amount]
        <br />
        Exclusivity (no competing brand for 30 days) — +₹[amount]
        <br />
        Raw footage / additional edits — +₹[amount]
        <br />
        <br />
        <strong>Terms</strong>
        <br />
        50% advance, 50% on delivery · Content delivered within [X] days of product receipt · 1 round of revisions included
      </blockquote>
      <p>
        Fill in your own engagement rate honestly — Instagram's Insights tab gives
        you this directly, and brands increasingly check it against your follower
        count before they even reply.
      </p>

      <h2>How to present it</h2>
      <p>
        Turn this into a single clean image or one-page PDF (Canva's free tier has
        rate-card templates you can adapt) and keep a copy ready to send the moment
        a brand says "send your rates." Don't lead with it unprompted in a cold
        pitch — send the pitch first, then the rate card when they show interest.
      </p>

      <h2>When to go above or below your card</h2>
      <p>
        Your rate card is a starting anchor, not a fixed law. It's reasonable to go
        below it for your first few deals with a brand you genuinely want to work
        with, in exchange for portfolio content and a testimonial — and reasonable
        to go above it when a brand wants usage rights, exclusivity, or a fast
        turnaround. What matters is that you're deciding the adjustment on purpose,
        not improvising a number under pressure mid-conversation.
      </p>

      <h2>Let your rate card do the talking</h2>
      <p>
        A rate card only helps once a brand actually sees it — which still means
        getting discovered in the first place.{' '}
        <Link to="/creators">Collabsy</Link> connects Instagram creators in the
        10K–50K range directly with D2C brands looking for exactly that tier, so
        your rate card reaches a brand that's already looking for someone like you,
        instead of sitting in your DMs waiting for the right person to ask.
      </p>
      <p>
        Haven't landed your first paid deal yet? Start with{' '}
        <Link to="/blog/first-brand-deal-instagram-micro-influencer">
          how to get your first brand deal on Instagram as a micro-influencer
        </Link>
        .
      </p>
    </article>
  )
}

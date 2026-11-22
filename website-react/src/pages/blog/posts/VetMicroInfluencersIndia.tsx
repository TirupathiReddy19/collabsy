/*
 * EDITORIAL NOTE: DRAFT, NOT REVIEWED. Do not publish until a human has checked everything below.
 * (Automated SEO pass, 2026-11-22. This file is not registered in posts.ts, the sitemap, or routes yet.)
 *
 * 1. Vendor / agency-sourced figures (labelled as such in the copy):
 *    - HypeAuditor ER benchmark table for 10K–50K (low < 2.02%, average 2.02–5.37%, high >= 5.37%),
 *      from HypeAuditor's free engagement calculator page, "data updated November 2026". HypeAuditor
 *      sells audit tools. The page does NOT say if the table is global or India-specific; the copy
 *      treats it as a general (not India-specific) benchmark. Re-check the numbers before publishing,
 *      since the page updates.
 *    - HypeAuditor's "State of Instagram Influencer Marketing in India": 68%+ of Indian creators inflate
 *      followers/engagement; 59%+ of 5K–20K creators show growth anomalies; 30%+ of 5K–20K creators have
 *      used follow/unfollow; 9.54% of 5K–20K use comment pods; nano (1K–5K) ER 5.90%. The underlying
 *      data is from EARLY 2020 (page last updated May 2026). It is old, and its tiers (5K–20K) don't match
 *      our 10K–50K framing. The copy says so.
 *    - Qoruz (influencer-marketing platform, May 2025): Indian influencer average Instagram ER of 2–3%;
 *      10%+ ER "without justification" is suspicious; 5,000+ followers overnight suggests purchased
 *      followers. Qoruz gives no methodology for the 2–3% figure.
 *    - Storyboard18 (Sept 2025): describes vetting practices at Dabur, Duroflex and the agency Nofiltr,
 *      and quotes fractional CMO Amarpreet Singh. These are descriptions of practice, not statistics.
 *
 * 2. Unverified / deliberately excluded:
 *    - Statista's India ER-by-tier chart (statista.com/statistics/1295110) returned 403. It is NOT used.
 *    - Khaleej Times / IANS 2019 "16 million fake accounts" (HypeAuditor + A Good Company) is NOT used.
 *      The article's 16M figure is larger than the study's stated 1.84M-account sample and isn't explained.
 *    - Qoruz's other stats (₹7,500 crore lost, Cheq 15%, Linqia 3.7x, Kantar 73%, ISA 22%) are NOT used.
 *      Qoruz attributes them to studies but doesn't link them, and I could not verify them.
 *    - Influencer Marketing Hub's fraud report covers 2018/2019 global data with no India numbers. NOT used.
 *    - What Instagram Insights shows (top cities/countries, age range, gender, reach, active times)
 *      comes from general product knowledge plus third-party guides. The official Instagram Help Center
 *      page would not load for verification. Check the current Insights UI before publishing.
 *    - There are NO sourced thresholds for like:comment ratio or Reel-views-vs-followers. The checklist
 *      keeps these qualitative on purpose. Don't add numbers without a source.
 *    - The worked ER example (25,000 followers, ~2.1%) is illustrative arithmetic, not data.
 *
 * 3. OPEN QUESTION for the product/founder: which vetting steps does Collabsy actually perform?
 *    Confirmed (per internal notes): creators must connect Instagram via Instagram's official login at
 *    signup, and a Collabsy admin must approve each creator before the profile goes live.
 *    NOT confirmed, so NOT claimed: any automated fake-follower or fraud detection, ER scoring, audience
 *    audits, or which Instagram data brands can see inside the app. The "Where Collabsy fits" section is
 *    written conservatively to match this. Confirm what admin approval actually checks, and edit if
 *    there's more (or less) to say.
 *
 * 4. Brand voice: check the tone matches the existing posts, and confirm the section headings and CTA.
 */
import { Link } from 'react-router-dom'

export function VetMicroInfluencersIndia() {
  return (
    <article className="blog-prose">
      <p>
        You've shortlisted a dozen Instagram creators in the 10,000–50,000 follower
        range for your next launch. Their grids look good, their follower counts fit
        your budget, and their rates line up with what you've seen in{' '}
        <Link to="/blog/micro-influencer-rate-card-india">
          published rate cards for this tier
        </Link>
        . What you can't tell from the profile is how many of those followers are
        real, how much of the engagement is bought, and whether the audience lives
        anywhere near the cities you ship to.
      </p>
      <p>
        Most guides to spotting fake followers start with "use an audit tool." This
        one doesn't. Below is a manual checklist you can run in about ten minutes per
        creator, using only the creator's public profile and a few screenshots you
        ask them for. It also covers when a paid tool is actually worth it.
      </p>

      <h2>Why fraud hurts more at 10K–50K</h2>
      <p>
        At this tier, faking it is cheap. Adding a few thousand bought followers or a
        steady trickle of pod comments to a 15,000-follower account costs very
        little, and it changes the numbers that matter to you a lot. The same
        purchase barely registers on a celebrity account.
      </p>
      <p>
        The most detailed India-specific data on this is old, so read it as a
        starting point, not a current measurement. HypeAuditor (an influencer
        analytics vendor) analysed Indian Instagram creators using early-2020 data.
        It reported that more than 68% artificially inflated their followers or
        engagement, and that over 59% of creators in the 5K–20K band showed follower
        growth anomalies that suggest buying. It also found that over 30% of that
        band had used follow/unfollow tactics, and 9.54% used comment pods (
        <a href="https://blog.hypeauditor.com/state-of-instagram-influencer-marketing-in-india" target="_blank" rel="noopener noreferrer">
          HypeAuditor, India report
        </a>
        ). In the same data, only about 10% of mega-influencers and celebrities
        showed the same behaviour. The pattern is the useful part: fraud was most
        common exactly where you're shopping.
      </p>
      <p>
        There's a second reason it hurts more here. With a big creator, a few
        thousand fake followers is a rounding error. With a 20,000-follower creator,
        it can be a quarter of the audience you're paying to reach.
      </p>

      <h2>Engagement rate: the formula and the benchmarks</h2>
      <p>The standard follower-based formula is:</p>
      <blockquote>
        Engagement rate = (average likes + average comments per post) ÷ followers × 100
      </blockquote>
      <p>
        Use the last 10–12 posts, and leave out pinned posts and obvious one-off
        viral hits. For example, a 25,000-follower creator averaging 500 likes and
        25 comments works out to (500 + 25) ÷ 25,000 × 100 = 2.1%. Some tools,
        including HypeAuditor, divide by Reel <em>views</em> instead of followers
        when an account posts enough Reels. That gives a different number, so make
        sure you're comparing like with like (
        <a href="https://hypeauditor.com/free-tools/instagram-engagement-calculator/" target="_blank" rel="noopener noreferrer">
          HypeAuditor engagement calculator
        </a>
        ).
      </p>
      <p>What counts as normal? Two reference points, both from vendors:</p>
      <ul>
        <li>
          <strong>HypeAuditor's tier benchmark (updated November 2026):</strong> for
          10K–50K accounts, below 2.02% is low, 2.02% to 5.37% is average, and 5.37%
          or more is high. The page doesn't say whether this is India-specific, so
          treat it as a general benchmark (
          <a href="https://hypeauditor.com/free-tools/instagram-engagement-calculator/" target="_blank" rel="noopener noreferrer">
            HypeAuditor
          </a>
          ).
        </li>
        <li>
          <strong>Qoruz's India figure (2025):</strong> Indian influencer
          marketing platform Qoruz puts the average Instagram engagement rate for
          Indian influencers at 2–3%. It flags a rate of 10% or more "without
          justification" as suspicious (
          <a href="https://qoruz.com/blog/how-to-identify-fake-followers-and-engagement-in-influencer-marketing/" target="_blank" rel="noopener noreferrer">
            Qoruz
          </a>
          ).
        </li>
      </ul>
      <p>
        The key point is that <strong>both ends are red flags</strong>. An
        unusually low rate usually means a big share of the followers are inactive
        or fake: they were bought, and they don't engage. An unusually high rate can
        mean the engagement itself is bought or arranged through a pod. A creator
        sitting at 12% on every single post deserves as much scrutiny as one at
        0.4%. A high rate isn't automatically fake, since small, tight-knit niche
        communities can genuinely run hot. Treat it as a reason to check where the
        engagement comes from, not as proof of quality.
      </p>

      <h2>The 10-minute manual vetting checklist</h2>
      <p>Run these in order. Most fake profiles fail one of the first three.</p>
      <ol>
        <li>
          <strong>Follower growth spikes.</strong> Real accounts usually grow in a
          gradual line with occasional bumps when a post does well. Watch for
          step-like jumps, sharp drops after a plateau, or thousands of followers
          appearing overnight with no viral post to explain it. Qoruz cites 5,000+
          new followers overnight as a typical sign of purchased followers (
          <a href="https://qoruz.com/blog/how-to-identify-fake-followers-and-engagement-in-influencer-marketing/" target="_blank" rel="noopener noreferrer">
            Qoruz
          </a>
          ). You can't see follower history on a public profile, so ask for it
          (see the next section) or use a free growth-tracker lookup.
        </li>
        <li>
          <strong>Comment quality and pods.</strong> Open the last five posts and
          read the comments. Lots of "🔥🔥", "Nice pic!", or "Amazing 😍" with nothing
          specific to the post is a warning sign. So is the same handful of
          accounts commenting first on every post, often other creators in the same
          niche, which is the typical comment-pod pattern. Real comments ask about
          the product, the price, the location, or reply to something the creator
          actually said.
        </li>
        <li>
          <strong>Like-to-comment balance.</strong> Compare likes and comments
          across posts. A post with thousands of likes and almost no comments, or a
          comment count that jumps around wildly from post to post while likes stay
          flat, suggests one of the two is being topped up. There's no single
          "correct" ratio. What you're looking for is inconsistency.
        </li>
        <li>
          <strong>Ghost followers.</strong> Tap into the follower list and scroll
          through 30–50 accounts. Count how many have no profile picture, zero
          posts, or patterned usernames like a name followed by a long string of
          digits. A few are normal. A large share is not.
        </li>
        <li>
          <strong>Reel views vs followers.</strong> Look at the view counts on the
          last 8–10 Reels. Views that are tiny compared with follower count, on
          every Reel, suggest the followers aren't real people watching. Views that
          swing from very low to very high with no change in content quality are
          also worth asking about.
        </li>
        <li>
          <strong>Audience location and language.</strong> Check that the comments
          are in the languages your customers speak and come from accounts that look
          Indian, ideally from the cities or regions you serve. A Bengaluru skincare
          creator whose comments are mostly in languages and from regions that have
          nothing to do with India is a mismatch, whatever the follower count says.
        </li>
      </ol>
      <p>
        If a creator passes all six, you've ruled out the obvious fakes. The next
        step confirms the rest with real data.
      </p>

      <h2>What to ask the creator for</h2>
      <p>
        Creators with professional (Creator or Business) Instagram accounts have
        access to Insights. Genuine creators at this tier are usually happy to
        share them. Ask for:
      </p>
      <ul>
        <li>
          <strong>A screen recording, not just screenshots,</strong> of their
          Insights dashboard. A recording that scrolls from the profile into
          Insights is much harder to fake than an edited screenshot.
        </li>
        <li>
          <strong>Audience city and country split.</strong> What share of their
          followers are in India, and which cities make up the top of the list.
        </li>
        <li>
          <strong>Age range and gender split,</strong> so you can check them
          against your actual customer.
        </li>
        <li>
          <strong>Reach and views over the last 30 days,</strong> plus per-post
          reach on two or three recent posts, especially any past brand
          collaborations.
        </li>
        <li>
          <strong>Results from past brand work.</strong> Promo-code redemptions,
          link clicks, or a contact at a previous brand you can ask. Even a
          rough "this code got around N uses" tells you more than a follower
          count.
        </li>
      </ul>
      <p>
        Reluctance to share any of this isn't proof of fraud. Some creators simply
        haven't been asked before. But a flat refusal to share basic audience data
        before a paid deal tells you something. Indian brands describe the same
        habit: Duroflex's CMO told Storyboard18 the company reviews influencer
        Insights and manually checks comments and follower quality before it signs
        creators (
        <a href="https://www.storyboard18.com/amp/how-it-works/brands-turn-to-ai-tools-data-audits-to-tackle-fake-influencers-81490.htm" target="_blank" rel="noopener noreferrer">
          Storyboard18, 2025
        </a>
        ).
      </p>

      <h2>When a paid audit tool is worth it</h2>
      <p>
        The manual checklist works when you're evaluating a handful of creators.
        Paid audit tools (HypeAuditor, Modash, Qoruz, and similar) start to earn
        their cost when:
      </p>
      <ul>
        <li>you're screening dozens of creators per campaign and ten minutes each becomes days;</li>
        <li>you need historical follower-growth charts the creator can't or won't provide;</li>
        <li>a single creator fee is large enough that a subscription is cheap insurance.</li>
      </ul>
      <p>
        Even then, don't treat the tool's score as the final word. In the same
        Storyboard18 report, Dabur describes using third-party audit tools to flag
        sudden follower spikes, low-quality comments, and engagement that doesn't
        match follower count. Agency Nofiltr describes pairing automated flags with
        a manual review of profiles, comments, and engagement patterns, because
        automation alone misses things (
        <a href="https://www.storyboard18.com/amp/how-it-works/brands-turn-to-ai-tools-data-audits-to-tackle-fake-influencers-81490.htm" target="_blank" rel="noopener noreferrer">
          Storyboard18, 2025
        </a>
        ). The tool narrows the list, and a person still makes the call.
      </p>

      <h2>Red flags that end the conversation</h2>
      <p>Some findings aren't worth negotiating past:</p>
      <ul>
        <li>Refusing to share any Insights at all before a paid deal.</li>
        <li>Insights screenshots that don't match the public profile, such as different follower counts or mismatched dates.</li>
        <li>A majority of the audience outside India when you sell only in India.</li>
        <li>Comment sections made up almost entirely of generic emoji comments from the same rotating accounts.</li>
        <li>A follower jump of thousands in a few days with no post that explains it.</li>
        <li>Reel views consistently a tiny fraction of follower count.</li>
      </ul>
      <p>
        Fractional CMO Amarpreet Singh told Storyboard18 that smarter brands track
        "cost per authentic engagement, watch time, and saves" instead of likes and
        follower counts alone (
        <a href="https://www.storyboard18.com/amp/how-it-works/brands-turn-to-ai-tools-data-audits-to-tackle-fake-influencers-81490.htm" target="_blank" rel="noopener noreferrer">
          Storyboard18, 2025
        </a>
        ). A modest, real audience is worth more than an inflated one.
      </p>

      <h2>Where Collabsy fits</h2>
      <p>
        Vetting is one of the reasons{' '}
        <Link to="/blog/agency-vs-platform-india">
          the agency-versus-platform choice is harder at this tier
        </Link>
        . On Collabsy, every creator connects their Instagram account through
        Instagram's official login when they sign up, and each creator profile is
        approved by the Collabsy team before it goes live to brands. That means the
        account you see is linked to a real Instagram account, and every profile
        has passed a human check before you see it.
      </p>
      <p>
        It isn't a substitute for the checklist above. Run your own ten-minute
        check and ask for Insights on anyone you're about to pay, just as you would
        anywhere else. What Collabsy changes is the starting pool: a 10K–50K
        shortlist built from approved, Instagram-connected profiles, rather than
        cold DMs to accounts you know nothing about.
      </p>

      <h2>Next step</h2>
      <p>
        Shortlisting 10K–50K creators for your next campaign?{' '}
        <Link to="/brands">See how Collabsy works for brands</Link>.
      </p>
    </article>
  )
}

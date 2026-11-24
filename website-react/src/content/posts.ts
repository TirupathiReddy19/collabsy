import { lazy } from 'react'
import type { ComponentType, LazyExoticComponent } from 'react'

export interface BlogPostMeta {
  slug: string
  title: string
  seoTitle: string
  description: string
  audience: 'Creator' | 'Brand'
  publishedDate: string
  readingTime: string
  Component: LazyExoticComponent<ComponentType>
}

// Each post's body lives in its own file under pages/blog/posts/ and is
// lazy-loaded, same as every other route — a growing blog never adds weight
// to pages that aren't the blog.
export const POSTS: BlogPostMeta[] = [
  {
    slug: 'first-brand-deal-instagram-micro-influencer',
    title: 'How to Get Your First Brand Deal on Instagram as a Micro-Influencer',
    seoTitle: 'Get Your First Instagram Brand Deal (10K–50K)',
    description:
      "You don't need a million followers to land brand deals. Here's exactly how creators with 10K–50K Instagram followers can land their first paid partnership.",
    audience: 'Creator',
    publishedDate: '2026-11-20',
    readingTime: '7 min read',
    Component: lazy(() =>
      import('../pages/blog/posts/FirstBrandDealInstagram').then((m) => ({
        default: m.FirstBrandDealInstagram,
      })),
    ),
  },
  {
    slug: 'micro-influencer-rate-card-india',
    title: 'The Micro-Influencer Rate Card & Media Kit Template for Indian Creators',
    seoTitle: 'India Micro-Influencer Rate Card (10K–50K)',
    description:
      "A one-page rate card template for Indian Instagram creators with 10K–50K followers, with real 2026 INR rate ranges — not a generic US template.",
    audience: 'Creator',
    publishedDate: '2026-11-20',
    readingTime: '6 min read',
    Component: lazy(() =>
      import('../pages/blog/posts/MicroInfluencerRateCardIndia').then((m) => ({
        default: m.MicroInfluencerRateCardIndia,
      })),
    ),
  },
  {
    slug: 'agency-vs-platform-india',
    title: 'Influencer Marketing Agency vs. Platform: What Should an Indian D2C Brand Actually Use for 10K–50K Creators?',
    seoTitle: 'Agency vs. Platform for Micro-Influencers (India)',
    description:
      "Most agency-vs-platform guides target enterprise brands. Here's the real cost and decision framework for Indian D2C brands with 10K–50K creators.",
    audience: 'Brand',
    publishedDate: '2026-11-20',
    readingTime: '7 min read',
    Component: lazy(() =>
      import('../pages/blog/posts/AgencyVsPlatformIndia').then((m) => ({
        default: m.AgencyVsPlatformIndia,
      })),
    ),
  },
]

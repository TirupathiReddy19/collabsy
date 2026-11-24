const SITE_URL = 'https://collabsy.online'

/** Renders nothing visible - just the BlogPosting JSON-LD for one post, so
 * it can appear as an article result (and in Google Discover) instead of a
 * generic page. No per-post image field exists yet in posts.ts, so this
 * falls back to the site's own logo rather than inventing one; author is
 * "Collabsy" since no post is attributed to an individual elsewhere on the
 * site either. */
export function BlogPostingSchema({
  title,
  description,
  path,
  publishedDate,
}: {
  title: string
  description: string
  path: string
  publishedDate: string
}) {
  const url = `${SITE_URL}${path}`
  const data = {
    '@context': 'https://schema.org',
    '@type': 'BlogPosting',
    headline: title,
    description,
    image: `${SITE_URL}/collabsy-icon.png`,
    datePublished: publishedDate,
    dateModified: publishedDate,
    author: { '@type': 'Organization', name: 'Collabsy', url: SITE_URL },
    publisher: {
      '@type': 'Organization',
      name: 'Collabsy',
      logo: { '@type': 'ImageObject', url: `${SITE_URL}/collabsy-icon.png` },
    },
    mainEntityOfPage: { '@type': 'WebPage', '@id': url },
  }

  return <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }} />
}

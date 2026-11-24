const SITE_URL = 'https://collabsy.online'

/** Per-page <title>/description/canonical/OG/Twitter tags. React 19 hoists
 * title/meta/link tags rendered anywhere in the tree into <head> and swaps
 * them on navigation — so each page renders its own instead of every route
 * sharing one static tag set from index.html (which previously gave every
 * page the same title/description in search results). */
export function Seo({
  title,
  description,
  path,
  type = 'website',
}: {
  title: string
  description: string
  path: string
  /** index.html's static og:type is "website", correct for every page
   * except blog posts - those override it to "article" here. */
  type?: 'website' | 'article'
}) {
  const url = `${SITE_URL}${path}`

  return (
    <>
      <title>{title}</title>
      <meta name="description" content={description} />
      <link rel="canonical" href={url} />
      <meta property="og:type" content={type} />
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
      <meta property="og:url" content={url} />
      <meta name="twitter:title" content={title} />
      <meta name="twitter:description" content={description} />
    </>
  )
}

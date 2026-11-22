const SITE_URL = 'https://collabsy.online'

/** Renders nothing visible — just the BreadcrumbList JSON-LD for this page's
 * position in the site, so Google can show a breadcrumb trail in search
 * results instead of the raw URL. Omitted on Home, since a single-item
 * breadcrumb pointing at itself isn't meaningful. */
export function BreadcrumbSchema({ items }: { items: { name: string; path: string }[] }) {
  const data = {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: item.name,
      item: `${SITE_URL}${item.path}`,
    })),
  }

  return <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }} />
}

import { useLocation } from 'react-router-dom'
import { BreadcrumbSchema } from './BreadcrumbSchema'
import { Seo } from './Seo'
import './Legal.css'

export function LegalPage({
  title,
  description,
  effectiveDate,
  children,
}: {
  title: string
  description: string
  effectiveDate: string
  children: React.ReactNode
}) {
  const { pathname } = useLocation()

  return (
    <section className="section legal-page">
      <Seo title={`${title} | Collabsy`} description={description} path={pathname} />
      <BreadcrumbSchema items={[{ name: 'Home', path: '/' }, { name: title, path: pathname }]} />
      <div className="container">
        <div className="legal-container">
          <h1 className="display-heading legal-title">{title}</h1>
          <p className="legal-date">Effective {effectiveDate}</p>
          {children}
        </div>
      </div>
    </section>
  )
}

export function LegalH2({ children }: { children: React.ReactNode }) {
  return <h2 className="legal-h2">{children}</h2>
}

export function LegalP({ children }: { children: React.ReactNode }) {
  return <p className="legal-p">{children}</p>
}

export function LegalBullets({ items }: { items: React.ReactNode[] }) {
  return (
    <ul className="legal-bullets">
      {items.map((item, i) => (
        <li key={i}>{item}</li>
      ))}
    </ul>
  )
}

export function MailLink({ children }: { children: React.ReactNode }) {
  return (
    <a className="legal-link" href="mailto:support@collabsy.online">
      {children}
    </a>
  )
}

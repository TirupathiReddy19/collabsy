import './Legal.css'

export function LegalPage({
  title,
  effectiveDate,
  children,
}: {
  title: string
  effectiveDate: string
  children: React.ReactNode
}) {
  return (
    <section className="section legal-page">
      <div className="container legal-container">
        <h1 className="display-heading legal-title">{title}</h1>
        <p className="legal-date">Effective {effectiveDate}</p>
        {children}
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

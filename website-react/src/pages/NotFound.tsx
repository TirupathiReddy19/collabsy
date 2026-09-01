import { Link } from 'react-router-dom'

export function NotFound() {
  return (
    <section
      className="section"
      style={{ minHeight: '60vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
    >
      <div style={{ textAlign: 'center' }}>
        <h1 className="display-heading" style={{ fontSize: 64, margin: '0 0 8px' }}>
          404
        </h1>
        <p className="body-lead" style={{ margin: '0 auto 24px' }}>
          This page doesn't exist.
        </p>
        <Link to="/" className="btn btn-primary btn-expanded">
          Back to Home
        </Link>
      </div>
    </section>
  )
}

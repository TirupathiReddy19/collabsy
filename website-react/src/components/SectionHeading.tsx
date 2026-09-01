import './SectionHeading.css'

export function SectionHeading({
  eyebrow,
  title,
  subtitle,
  align = 'center',
  onDark = false,
}: {
  eyebrow?: string
  title: string
  subtitle?: string
  align?: 'center' | 'left'
  onDark?: boolean
}) {
  return (
    <div className={`section-heading section-heading-${align}`}>
      {eyebrow && <span className={`eyebrow ${onDark ? 'on-dark' : ''}`}>{eyebrow}</span>}
      <h2 className="section-heading-title display-heading">{title}</h2>
      {subtitle && (
        <p className={`body-lead ${onDark ? 'on-dark' : ''} section-heading-subtitle`}>
          {subtitle}
        </p>
      )}
    </div>
  )
}

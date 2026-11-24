import type { ReactNode } from 'react'
import './SectionHeading.css'

export function SectionHeading({
  eyebrow,
  title,
  subtitle,
  align = 'center',
  onDark = false,
  as: Heading = 'h2',
}: {
  eyebrow?: string
  title: string
  subtitle?: ReactNode
  align?: 'center' | 'left'
  onDark?: boolean
  /** Defaults to h2, since most pages use this for a section below their
   * own h1. Pages with no other h1 (e.g. Contact) pass "h1" instead. */
  as?: 'h1' | 'h2'
}) {
  return (
    <div className={`section-heading section-heading-${align}`}>
      {eyebrow && <span className={`eyebrow ${onDark ? 'on-dark' : ''}`}>{eyebrow}</span>}
      <Heading className="section-heading-title display-heading">{title}</Heading>
      {subtitle && (
        <p className={`body-lead ${onDark ? 'on-dark' : ''} section-heading-subtitle`}>
          {subtitle}
        </p>
      )}
    </div>
  )
}

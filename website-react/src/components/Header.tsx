import { useEffect, useRef, useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import gsap from 'gsap'
import { CollabsyMark } from './CollabsyMark'
import { WaitlistButton } from './WaitlistButton'
import './Header.css'

const NAV_ITEMS = [
  { path: '/', label: 'Home' },
  { path: '/creators', label: 'Creators' },
  { path: '/brands', label: 'Brands' },
  { path: '/about', label: 'About' },
  { path: '/contact', label: 'Contact' },
]

export function Header() {
  const [scrolled, setScrolled] = useState(false)
  const [menuOpen, setMenuOpen] = useState(false)
  const menuRef = useRef<HTMLDivElement>(null)
  const location = useLocation()

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 12)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    setMenuOpen(false)
  }, [location.pathname])

  useEffect(() => {
    if (!menuRef.current) return
    if (menuOpen) {
      gsap.fromTo(
        menuRef.current,
        { clipPath: 'inset(0 0 100% 0)' },
        { clipPath: 'inset(0 0 0% 0)', duration: 0.5, ease: 'power3.out' },
      )
      gsap.fromTo(
        menuRef.current.querySelectorAll('a, .header-menu-cta'),
        { opacity: 0, y: 14 },
        { opacity: 1, y: 0, duration: 0.4, stagger: 0.05, delay: 0.15, ease: 'power2.out' },
      )
    }
  }, [menuOpen])

  return (
    <header className={`header ${scrolled ? 'header-scrolled' : ''}`}>
      <div className="container header-inner">
        <Link to="/" className="header-brand" aria-label="Collabsy home">
          <span className="header-mark">
            <CollabsyMark />
          </span>
          <span className="header-wordmark">Collabsy</span>
        </Link>

        <nav className="header-nav" aria-label="Primary">
          {NAV_ITEMS.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`header-link ${location.pathname === item.path ? 'header-link-active' : ''}`}
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="header-cta">
          <WaitlistButton compact label="Get the App" />
        </div>

        <button
          className="header-hamburger"
          aria-label={menuOpen ? 'Close menu' : 'Open menu'}
          aria-expanded={menuOpen}
          onClick={() => setMenuOpen((v) => !v)}
        >
          <span className={`header-hamburger-line ${menuOpen ? 'is-open' : ''}`} />
          <span className={`header-hamburger-line ${menuOpen ? 'is-open' : ''}`} />
        </button>
      </div>

      {menuOpen && (
        <div className="header-menu" ref={menuRef}>
          <nav className="header-menu-nav" aria-label="Mobile">
            {NAV_ITEMS.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                className={`header-menu-link ${location.pathname === item.path ? 'header-menu-link-active' : ''}`}
              >
                {item.label}
              </Link>
            ))}
          </nav>
          <div className="header-menu-cta">
            <WaitlistButton />
          </div>
        </div>
      )}
    </header>
  )
}

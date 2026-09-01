import { Suspense, lazy, useEffect, useRef, useState } from 'react'
import './HeroCanvas.css'

// The Canvas + scene graph pull in three.js/@react-three/fiber, easily the
// heaviest dependency on the page — split into its own chunk and only
// fetched once this component actually mounts, never blocking first paint
// of the hero's text/CTAs.
const CanvasScene = lazy(() => import('./CanvasScene'))

export function HeroCanvas() {
  const containerRef = useRef<HTMLDivElement>(null)
  const [visible, setVisible] = useState(false)
  const [lowPower, setLowPower] = useState(false)

  useEffect(() => {
    setLowPower(window.innerWidth < 768)
    const el = containerRef.current
    if (!el) return
    const observer = new IntersectionObserver(
      ([entry]) => setVisible(entry.isIntersecting),
      { threshold: 0.1 },
    )
    observer.observe(el)
    return () => observer.disconnect()
  }, [])

  return (
    <div className="hero-canvas-wrap" ref={containerRef}>
      <div className="hero-canvas-glow" aria-hidden="true" />
      {visible && (
        <Suspense fallback={null}>
          <CanvasScene lowPower={lowPower} />
        </Suspense>
      )}
    </div>
  )
}

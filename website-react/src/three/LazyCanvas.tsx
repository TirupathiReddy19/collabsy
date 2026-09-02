import { useEffect, useRef, useState, type ComponentType } from 'react'
import './LazyCanvas.css'

export interface ScenePropsBase {
  lowPower: boolean
}

/** Shared mount/unmount machinery for every 3D scene on the site — each
 * scene is its own lazy-loaded chunk, only fetched and mounted once its
 * section actually scrolls near the viewport (`rootMargin` gives it a
 * head start so the canvas is ready by the time it's visible), and fully
 * unmounted (WebGL context released) once scrolled away. This is what
 * keeps having 3D on every section affordable — there is never more than
 * one or two live WebGL contexts on screen at once, regardless of how
 * many sections use one somewhere on the page. */
export function LazyCanvas({
  loader,
  glow,
  minHeight,
}: {
  loader: () => Promise<{ default: ComponentType<ScenePropsBase> }>
  glow?: React.ReactNode
  minHeight?: number
}) {
  const containerRef = useRef<HTMLDivElement>(null)
  const [visible, setVisible] = useState(false)
  const [lowPower, setLowPower] = useState(false)
  const [Comp, setComp] = useState<ComponentType<ScenePropsBase> | null>(null)

  useEffect(() => {
    setLowPower(window.innerWidth < 768)
    const el = containerRef.current
    if (!el) return
    const observer = new IntersectionObserver(
      ([entry]) => setVisible(entry.isIntersecting),
      { threshold: 0.05, rootMargin: '250px 0px' },
    )
    observer.observe(el)
    return () => observer.disconnect()
  }, [])

  useEffect(() => {
    if (!visible || Comp) return
    let cancelled = false
    loader().then((m) => {
      if (!cancelled) setComp(() => m.default)
    })
    return () => {
      cancelled = true
    }
  }, [visible, Comp, loader])

  return (
    <div className="lazy-canvas-wrap" ref={containerRef} style={minHeight ? { minHeight } : undefined}>
      {glow}
      {visible && Comp && <Comp lowPower={lowPower} />}
    </div>
  )
}

import { useEffect, useRef, useState, type ComponentType } from 'react'
import './LazyCanvas.css'

export interface ScenePropsBase {
  lowPower: boolean
}

/** Shared mount/unmount machinery for every 3D scene on the site — each
 * scene is its own lazy-loaded chunk, only fetched and mounted once its
 * section actually scrolls into the viewport, and fully unmounted (WebGL
 * context released) once scrolled away. This is what keeps having 3D on
 * every section affordable — there is never more than one live WebGL
 * context on screen at once, regardless of how many sections use one
 * somewhere on the page.
 *
 * No rootMargin preload: on Home, the hero is close to full-viewport
 * height, so a 250px preload margin put the *next* section's canvas
 * within the "nearly visible" zone from the very first frame — two full
 * WebGL contexts with their own render loops running concurrently before
 * the user had scrolled at all, which is what blew up Total Blocking
 * Time (confirmed via PageSpeed Insights: ~8s TBT, two canvases mounted
 * on a fresh, unscrolled load). */
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
      { threshold: 0.05 },
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

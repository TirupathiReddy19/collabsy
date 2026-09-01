import { useEffect, useRef } from 'react'
import { gsap, ScrollTrigger } from './gsap'

/** Fades/rises the given selector's matches in as the container scrolls
 * into view, staggered — the one repeated scroll-reveal treatment used
 * across every section on the site, so motion reads as one system rather
 * than a different animation per component. No-ops under
 * prefers-reduced-motion (content is simply visible immediately). */
export function useScrollReveal<T extends HTMLElement>(
  selector: string,
  options?: { stagger?: number; y?: number; start?: string },
) {
  const ref = useRef<T>(null)

  useEffect(() => {
    if (!ref.current) return
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return

    const ctx = gsap.context(() => {
      const targets = ref.current!.querySelectorAll(selector)
      if (targets.length === 0) return
      gsap.set(targets, { opacity: 0, y: options?.y ?? 28 })
      ScrollTrigger.batch(targets, {
        start: options?.start ?? 'top 85%',
        onEnter: (batch) =>
          gsap.to(batch, {
            opacity: 1,
            y: 0,
            duration: 0.8,
            ease: 'power3.out',
            stagger: options?.stagger ?? 0.08,
          }),
        once: true,
      })
    }, ref)

    return () => ctx.revert()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selector])

  return ref
}

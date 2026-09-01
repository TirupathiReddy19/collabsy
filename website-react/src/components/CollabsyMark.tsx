/**
 * The Collabsy mark: an open white ring (a "C") with a smaller two-tone
 * accent ring nested in its gap — same geometry as the app icon and the
 * in-app `CollabsyMark` CustomPainter (lib/core/widgets/app_logo.dart), so
 * this site's logo reads as the identical brand mark, not a reinterpretation.
 * Reproduced here as arc paths in the same 100x100 local coordinate space.
 */
function arcPath(cx: number, cy: number, r: number, startDeg: number, sweepDeg: number) {
  const startRad = (startDeg * Math.PI) / 180
  const endRad = ((startDeg + sweepDeg) * Math.PI) / 180
  const x1 = cx + r * Math.cos(startRad)
  const y1 = cy + r * Math.sin(startRad)
  const x2 = cx + r * Math.cos(endRad)
  const y2 = cy + r * Math.sin(endRad)
  const largeArc = Math.abs(sweepDeg) > 180 ? 1 : 0
  const sweepFlag = sweepDeg > 0 ? 1 : 0
  return `M ${x1} ${y1} A ${r} ${r} 0 ${largeArc} ${sweepFlag} ${x2} ${y2}`
}

export function CollabsyMark({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 100 100"
      className={className}
      role="img"
      aria-label="Collabsy"
    >
      <path
        d={arcPath(53.345, 50, 32, -54.3665, -251.267)}
        fill="none"
        stroke="white"
        strokeWidth={14}
        strokeLinecap="round"
      />
      <path
        d={arcPath(64.247, 50, 18, -117.25, 234.5)}
        fill="none"
        stroke="#B85C18"
        strokeWidth={14}
        strokeLinecap="round"
      />
    </svg>
  )
}

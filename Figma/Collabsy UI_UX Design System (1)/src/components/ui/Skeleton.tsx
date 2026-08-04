export function SkeletonCard() {
  return (
    <div className="bg-white rounded-3xl border border-[#F1E6DD] p-5 space-y-3" style={{ boxShadow: '0 4px 16px rgba(0,0,0,0.06)' }}>
      <div className="flex items-center gap-3">
        <div className="skeleton w-12 h-12 rounded-2xl" />
        <div className="flex-1 space-y-2">
          <div className="skeleton h-4 w-3/4 rounded-lg" />
          <div className="skeleton h-3 w-1/2 rounded-lg" />
        </div>
      </div>
      <div className="skeleton h-3 w-full rounded-lg" />
      <div className="skeleton h-3 w-4/5 rounded-lg" />
      <div className="flex gap-2 mt-2">
        <div className="skeleton h-8 flex-1 rounded-xl" />
        <div className="skeleton h-8 flex-1 rounded-xl" />
      </div>
    </div>
  )
}

export function SkeletonList({ count = 3 }: { count?: number }) {
  return (
    <div className="space-y-3">
      {Array.from({ length: count }).map((_, i) => <SkeletonCard key={i} />)}
    </div>
  )
}

export function SkeletonStat() {
  return (
    <div className="bg-white rounded-3xl border border-[#F1E6DD] p-5 space-y-3" style={{ boxShadow: '0 4px 16px rgba(0,0,0,0.06)' }}>
      <div className="skeleton h-3 w-20 rounded-lg" />
      <div className="skeleton h-8 w-28 rounded-xl" />
      <div className="skeleton h-3 w-16 rounded-lg" />
    </div>
  )
}

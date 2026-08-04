import { useState, useEffect } from 'react'
import { AreaChart, Area, BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import { Button, Badge, Card, AICard, Avatar, ProgressBar, SearchBar, StatCard, SectionHeader, TabBar, Input, Select, Chip, Icon, Toggle } from '../components/ui'
import { ToastProvider, useToast } from '../components/ui/Toast'
import { SkeletonCard, SkeletonStat } from '../components/ui/Skeleton'
import SmartLogin from '../components/SmartLogin'

const CATEGORIES = ['Fashion','Beauty','Food','Travel','Tech','Gaming','Fitness','Lifestyle','Education','Parenting','Finance','Entertainment']

// ─── SHARED MICRO-INTERACTION HOOK ───────────────────────────────────────────
function useLoading(ms = 1200) {
  const [loading, setLoading] = useState(true)
  useEffect(() => { const t = setTimeout(() => setLoading(false), ms); return () => clearTimeout(t) }, [ms])
  return loading
}

// ─── AUTH ─────────────────────────────────────────────────────────────────────
function BrandSplash({ onNext }: { onNext: () => void }) {
  return (
    <div className="flex flex-col items-center justify-center h-full relative overflow-hidden px-8 cursor-pointer"
      style={{ background: 'linear-gradient(160deg, #111827 0%, #1f2937 100%)' }} onClick={onNext}>
      <div className="absolute top-0 right-0 w-64 h-64 rounded-full opacity-10" style={{ background: 'radial-gradient(circle, #F97316, transparent)', transform: 'translate(30%,-30%)' }} />
      <div className="absolute bottom-0 left-0 w-48 h-48 rounded-full opacity-10" style={{ background: 'radial-gradient(circle, #F97316, transparent)', transform: 'translate(-30%,30%)' }} />
      <div className="relative z-10 flex flex-col items-center gap-4">
        <div className="w-24 h-24 bg-[#F97316] rounded-3xl flex items-center justify-center shadow-orange">
          <span className="text-4xl font-black text-white">C</span>
        </div>
        <h1 className="text-4xl font-black text-white tracking-tight">Collabsy</h1>
        <Badge variant="orange">For Brands & Agencies</Badge>
        <p className="text-white/60 text-sm text-center mt-2 leading-relaxed">Run AI-powered influencer campaigns<br/>across India's largest creator network</p>
        <div className="mt-8 text-white/40 text-sm animate-pulse">Tap to continue</div>
      </div>
    </div>
  )
}

function BrandLogin({ onNext, onSignup, onCreatorLogin }: { onNext: () => void; onSignup: () => void; onCreatorLogin?: () => void }) {
  return (
    <SmartLogin
      defaultTab="brand"
      onBrandLogin={onNext}
      onCreatorLogin={onCreatorLogin ?? onNext}
      onBrandSignup={onSignup}
      onCreatorSignup={onSignup}
    />
  )
}

function BrandOnboarding({ onNext }: { onNext: () => void }) {
  const [step, setStep] = useState(0)
  const toast = useToast()
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] px-6 pt-14 pb-6">
      <div className="mb-6">
        <div className="flex gap-1 mb-4">{[0,1,2].map(i => <div key={i} className={`flex-1 h-1 rounded-full transition-all ${i <= step ? 'bg-[#F97316]' : 'bg-[#F1E6DD]'}`} />)}</div>
        <h1 className="text-2xl font-bold text-[#111827]">{['Brand details','Campaign goals','Team setup'][step]}</h1>
        <p className="text-[#6B7280] mt-1 text-sm">{['Tell us about your company','What do you want to achieve?','Who manages campaigns?'][step]}</p>
      </div>
      <div className="flex flex-col gap-4 flex-1">
        {step === 0 && <>
          <Input label="Brand / Company Name" placeholder="e.g. Nykaa Beauty" icon={<Icon.Briefcase />} />
          <Select label="Industry" options={CATEGORIES.map(c => ({ value: c.toLowerCase(), label: c }))} />
          <Input label="Website" placeholder="https://yourwebsite.com" icon={<Icon.Globe />} />
          <Select label="Company Size" options={[{ value: 'startup', label: 'Startup (1–50)' },{ value: 'sme', label: 'SME (50–500)' },{ value: 'enterprise', label: 'Enterprise (500+)' }]} />
        </>}
        {step === 1 && <>
          <div>
            <label className="text-sm font-medium text-[#374151] mb-2 block">Campaign Goal</label>
            <div className="space-y-2">
              {['Brand Awareness','Product Launch','Drive Sales','Boost Engagement','App Installs'].map((g, i) => (
                <button key={g} className={`w-full flex items-center gap-3 px-4 py-3 rounded-2xl border text-sm font-medium text-left transition-all ${i === 0 ? 'border-[#F97316] bg-[#FFF1E8] text-[#C2410C]' : 'border-[#F1E6DD] bg-white text-[#374151]'}`}>
                  <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${i === 0 ? 'border-[#F97316] bg-[#F97316]' : 'border-[#D1D5DB]'}`}>
                    {i === 0 && <div className="w-2 h-2 bg-white rounded-full" />}
                  </div>
                  {g}
                </button>
              ))}
            </div>
          </div>
          <Input label="Monthly Budget (₹)" placeholder="5,00,000" icon={<Icon.DollarSign />} />
        </>}
        {step === 2 && <>
          <Input label="Your Name" placeholder="Rahul Mehta" icon={<Icon.User />} />
          <Input label="Job Title" placeholder="Marketing Manager" />
          <Input label="Phone" type="tel" placeholder="+91 98765 43210" icon={<Icon.Phone />} />
          <div className="bg-[#FFF1E8] rounded-2xl p-4">
            <p className="text-xs font-semibold text-[#C2410C] mb-1">🎉 Almost there!</p>
            <p className="text-xs text-[#6B7280]">Our AI will suggest the best creators for your first campaign within minutes.</p>
          </div>
        </>}
      </div>
      <Button fullWidth size="lg" className="mt-4" onClick={() => {
        if (step < 2) { setStep(s => s + 1) }
        else { toast('Brand account created! 🚀', 'success'); setTimeout(onNext, 600) }
      }}>{step < 2 ? 'Continue' : 'Launch Dashboard'}</Button>
    </div>
  )
}

// ─── DASHBOARD ───────────────────────────────────────────────────────────────
const reachData = [
  { month: 'Jul', reach: 18 }, { month: 'Aug', reach: 14 }, { month: 'Sep', reach: 22 },
  { month: 'Oct', reach: 31 }, { month: 'Nov', reach: 26 }, { month: 'Dec', reach: 38 },
]

function BrandDashboard({ navigate }: { navigate: (s: string) => void }) {
  const loading = useLoading(900)
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-[#111827] rounded-2xl flex items-center justify-center font-black text-[#F97316]">N</div>
            <div>
              <p className="text-xs text-[#6B7280]">Good morning 👋</p>
              <p className="text-base font-bold text-[#111827]">Nykaa Beauty</p>
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={() => navigate('notifications')} className="w-10 h-10 bg-white rounded-2xl border border-[#F1E6DD] flex items-center justify-center relative">
              <Icon.Bell />
              <span className="absolute -top-1 -right-1 w-4 h-4 bg-[#F97316] rounded-full text-[9px] text-white flex items-center justify-center font-bold">5</span>
            </button>
            <button onClick={() => navigate('messages')} className="w-10 h-10 bg-white rounded-2xl border border-[#F1E6DD] flex items-center justify-center">
              <Icon.Message />
            </button>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-3 mb-1">
          <div className="rounded-3xl p-4 text-white" style={{ background: 'linear-gradient(135deg, #F97316 0%, #EA580C 100%)' }}>
            <p className="text-white/70 text-xs mb-1">Active Campaigns</p>
            <p className="text-2xl font-black">8</p>
            <p className="text-white/70 text-xs mt-1">↑ 2 new this week</p>
          </div>
          <div className="rounded-3xl p-4 text-white" style={{ background: 'linear-gradient(135deg, #111827 0%, #1f2937 100%)' }}>
            <p className="text-white/70 text-xs mb-1">Total Reach</p>
            <p className="text-2xl font-black">48.2M</p>
            <p className="text-white/70 text-xs mt-1">↑ +22% MoM</p>
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-5">
        {/* Reach Sparkline */}
        <Card>
          <SectionHeader title="Reach Trend" subtitle="Last 6 months (M impressions)" />
          <ResponsiveContainer width="100%" height={100}>
            <AreaChart data={reachData} margin={{ top: 4, right: 4, left: -28, bottom: 0 }}>
              <defs>
                <linearGradient id="reachGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#F97316" stopOpacity={0.25} />
                  <stop offset="95%" stopColor="#F97316" stopOpacity={0} />
                </linearGradient>
              </defs>
              <XAxis dataKey="month" tick={{ fontSize: 10, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 10, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ background: '#111827', border: 'none', borderRadius: 12, color: '#fff', fontSize: 12 }} formatter={(v) => [`${v}M`, 'Reach']} />
              <Area type="monotone" dataKey="reach" stroke="#F97316" strokeWidth={2.5} fill="url(#reachGrad)" dot={false} activeDot={{ r: 4, fill: '#F97316' }} />
            </AreaChart>
          </ResponsiveContainer>
        </Card>

        {/* AI Insight */}
        <AICard title="AI Campaign Recommendation" subtitle="Based on your brand goals">
          <p className="text-xs text-[#374151] leading-relaxed">Launch a <strong>Collab Reel campaign</strong> with 15–20 micro-creators (50K–200K) for your skincare launch. Collab Reels drive <strong className="text-[#F97316]">3× more reach</strong> than solo Reels. Expected ROI: <strong className="text-[#16A34A]">5.1x</strong></p>
          <Button variant="primary" fullWidth size="sm" className="mt-3" onClick={() => navigate('create-campaign')}><Icon.Sparkles /> Generate Campaign Brief</Button>
        </AICard>

        {/* Active Campaigns */}
        <div>
          <SectionHeader title="Active Campaigns" action={<button onClick={() => navigate('campaigns')} className="text-xs text-[#F97316] font-semibold">See all</button>} />
          {loading ? (
            <div className="space-y-3"><SkeletonCard /><SkeletonCard /></div>
          ) : (
            <div className="space-y-3">
              {[
                { name: 'Holiday Glow 2024', creators: 12, reach: '18.4M', roi: '4.8x', progress: 65, img: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=60&h=60&fit=crop&auto=format', collab: true },
                { name: 'Winter Skincare Push', creators: 6, reach: '8.2M', roi: '3.2x', progress: 40, img: 'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?w=60&h=60&fit=crop&auto=format', collab: false },
              ].map(c => (
                <Card key={c.name} hover onClick={() => navigate('campaign-detail')}>
                  <div className="flex gap-3 mb-3">
                    <img src={c.img} alt="" className="w-12 h-12 rounded-2xl object-cover bg-[#F3F4F6] flex-shrink-0" />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <p className="text-sm font-bold text-[#111827] flex-1">{c.name}</p>
                        {c.collab && <Badge variant="purple">Collab Reel</Badge>}
                      </div>
                      <p className="text-xs text-[#6B7280]">{c.creators} creators · {c.reach} · ROI <span className="text-[#16A34A] font-bold">{c.roi}</span></p>
                    </div>
                  </div>
                  <ProgressBar value={c.progress} />
                </Card>
              ))}
            </div>
          )}
        </div>

        {/* Quick Actions */}
        <div>
          <SectionHeader title="Quick Actions" />
          <div className="grid grid-cols-4 gap-3">
            {[
              { label: 'New Campaign', icon: <Icon.Plus />, color: '#F97316', screen: 'create-campaign' },
              { label: 'Discover', icon: <Icon.Search />, color: '#2563EB', screen: 'discover' },
              { label: 'Analytics', icon: <Icon.Chart />, color: '#7C3AED', screen: 'analytics' },
              { label: 'Payments', icon: <Icon.Wallet />, color: '#16A34A', screen: 'payments' },
            ].map(a => (
              <button key={a.label} onClick={() => navigate(a.screen)} className="flex flex-col items-center gap-2 p-3 bg-white rounded-2xl border border-[#F1E6DD] hover:border-[#F97316] transition-colors">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: a.color + '15', color: a.color }}>{a.icon}</div>
                <span className="text-[10px] font-medium text-[#374151] text-center leading-tight">{a.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Top Creators */}
        <div>
          <SectionHeader title="Top Creators" action={<button onClick={() => navigate('discover')} className="text-xs text-[#F97316] font-semibold">Discover</button>} />
          <div className="space-y-2">
            {[
              { name: 'Priya Sharma', cat: 'Fashion', roi: '5.1x', score: 94, img: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=60&h=60&fit=crop&auto=format' },
              { name: 'Kavya Nair', cat: 'Beauty', roi: '4.8x', score: 91, img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=60&h=60&fit=crop&auto=format' },
              { name: 'Ananya Gupta', cat: 'Lifestyle', roi: '4.1x', score: 88, img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=60&h=60&fit=crop&auto=format' },
            ].map(c => (
              <Card key={c.name} hover onClick={() => navigate('creator-profile')} className="flex items-center gap-3 p-3">
                <Avatar src={c.img} name={c.name} size="md" verified />
                <div className="flex-1"><p className="text-sm font-semibold text-[#111827]">{c.name}</p><p className="text-xs text-[#6B7280]">{c.cat}</p></div>
                <div className="text-right"><p className="text-sm font-bold text-[#16A34A]">{c.roi}</p><p className="text-xs text-[#6B7280]">ROI</p></div>
                <Badge variant="orange">{c.score}%</Badge>
              </Card>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

// ─── CAMPAIGNS LIST ───────────────────────────────────────────────────────────
function BrandCampaigns({ navigate }: { navigate: (s: string) => void }) {
  const [tab, setTab] = useState(0)
  const loading = useLoading(800)
  const campaigns = [
    { name: 'Holiday Glow 2024', status: 'Active', budget: '₹8L', creators: 12, reach: '18.4M', roi: '4.8x', deadline: 'Dec 25', progress: 65, collab: true, img: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=80&h=80&fit=crop&auto=format' },
    { name: 'New Year Beauty Drop', status: 'Draft', budget: '₹5L', creators: 0, reach: '—', roi: '—', deadline: 'Jan 5', progress: 0, collab: false, img: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=80&h=80&fit=crop&auto=format' },
    { name: 'Winter Skincare Push', status: 'Active', budget: '₹3.5L', creators: 6, reach: '8.2M', roi: '3.2x', deadline: 'Dec 31', progress: 40, collab: true, img: 'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?w=80&h=80&fit=crop&auto=format' },
    { name: 'Diwali Glow Campaign', status: 'Completed', budget: '₹10L', creators: 20, reach: '28.4M', roi: '6.8x', deadline: 'Nov 15', progress: 100, collab: true, img: 'https://images.unsplash.com/photo-1603400521630-9f2de124b33b?w=80&h=80&fit=crop&auto=format' },
    { name: 'Lip Color Launch', status: 'Draft', budget: '₹2L', creators: 0, reach: '—', roi: '—', deadline: 'Jan 15', progress: 0, collab: false, img: 'https://images.unsplash.com/photo-1586495777744-4e6232bf2178?w=80&h=80&fit=crop&auto=format' },
  ]
  const tabs = ['All', 'Active', 'Draft', 'Done']
  const statusMap: Record<string,string> = { Active: 'Active', Draft: 'Draft', Done: 'Completed' }
  const shown = tab === 0 ? campaigns : campaigns.filter(c => c.status === statusMap[tabs[tab]])

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Campaigns</h1>
          <Button size="sm" className="ml-auto" onClick={() => navigate('create-campaign')}><Icon.Plus /> New</Button>
        </div>
        <TabBar tabs={tabs} active={tab} onChange={setTab} />
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-3">
        {loading ? <><SkeletonCard /><SkeletonCard /><SkeletonCard /></> : shown.map(c => (
          <Card key={c.name} hover onClick={() => navigate('campaign-detail')}>
            <div className="flex gap-3 mb-3">
              <img src={c.img} alt="" className="w-14 h-14 rounded-2xl object-cover bg-[#F3F4F6] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-1.5 mb-1 flex-wrap">
                  <p className="text-sm font-bold text-[#111827] truncate flex-1">{c.name}</p>
                  <Badge variant={c.status === 'Active' ? 'green' : c.status === 'Completed' ? 'blue' : 'gray'}>{c.status}</Badge>
                  {c.collab && <Badge variant="purple">Collab</Badge>}
                </div>
                <p className="text-xs text-[#6B7280]">{c.budget} · Due {c.deadline}</p>
                {c.roi !== '—' && <p className="text-xs text-[#16A34A] font-semibold">ROI {c.roi}</p>}
              </div>
            </div>
            {c.progress > 0 && <div className="mb-2"><ProgressBar value={c.progress} /></div>}
            <div className="flex gap-3 text-xs text-[#6B7280] pt-2 border-t border-[#F9FAFB]">
              <span><strong className="text-[#111827]">{c.creators}</strong> creators</span>
              <span>·</span>
              <span><strong className="text-[#111827]">{c.reach}</strong> reach</span>
            </div>
          </Card>
        ))}
      </div>
    </div>
  )
}

// ─── CAMPAIGN DETAIL ──────────────────────────────────────────────────────────
const perfData = [
  { day: 'Mon', reach: 2.1, eng: 0.14 }, { day: 'Tue', reach: 3.4, eng: 0.22 },
  { day: 'Wed', reach: 2.8, eng: 0.19 }, { day: 'Thu', reach: 4.2, eng: 0.28 },
  { day: 'Fri', reach: 5.1, eng: 0.33 }, { day: 'Sat', reach: 4.8, eng: 0.31 },
  { day: 'Sun', reach: 3.9, eng: 0.26 },
]

function CampaignDetail({ navigate }: { navigate: (s: string) => void }) {
  const [tab, setTab] = useState(0)
  const toast = useToast()
  const loading = useLoading(700)

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      {/* Hero */}
      <div className="relative">
        <img src="https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=180&fit=crop&auto=format" alt="" className="w-full h-40 object-cover bg-[#F3F4F6]" />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent to-black/50" />
        <button onClick={() => navigate('campaigns')} className="absolute top-12 left-4 w-9 h-9 bg-white/80 backdrop-blur-sm rounded-xl flex items-center justify-center"><Icon.ChevronLeft /></button>
        <div className="absolute bottom-3 left-4 right-4 flex items-end justify-between">
          <div>
            <h1 className="text-white font-black text-lg leading-tight">Holiday Glow 2024</h1>
            <div className="flex items-center gap-2 mt-1">
              <Badge variant="green">Active</Badge>
              <Badge variant="purple">Collab Reel</Badge>
            </div>
          </div>
          <Badge variant="orange">ROI 4.8x</Badge>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-24">
        {/* Stats Row */}
        <div className="grid grid-cols-4 gap-2 px-4 py-3 border-b border-[#F1E6DD]">
          {[['₹8L', 'Budget'], ['12', 'Creators'], ['18.4M', 'Reach'], ['65%', 'Progress']].map(([v,l]) => (
            <div key={l} className="text-center">
              <p className="text-base font-black text-[#111827]">{v}</p>
              <p className="text-[10px] text-[#6B7280]">{l}</p>
            </div>
          ))}
        </div>

        <div className="px-4 pt-3">
          <TabBar tabs={['Overview','Creators','Analytics']} active={tab} onChange={setTab} className="mb-4" />
        </div>

        {tab === 0 && (
          <div className="px-4 space-y-4">
            {/* Progress */}
            <Card>
              <SectionHeader title="Campaign Progress" subtitle="Dec 15 – Dec 25, 2024" />
              <ProgressBar value={65} showValue label="Overall completion" />
              <div className="grid grid-cols-3 gap-2 mt-3">
                {[['8/12', 'Submitted', '#F97316'], ['6/12', 'Approved', '#16A34A'], ['4', 'Pending', '#D97706']].map(([v,l,c]) => (
                  <div key={l} className="bg-[#F9FAFB] rounded-2xl p-2.5 text-center">
                    <p className="text-base font-bold text-[#111827]">{v}</p>
                    <p className="text-[10px] text-[#6B7280]">{l}</p>
                    <div className="w-full h-1 rounded-full mt-1" style={{ background: c + '30' }}><div className="h-1 rounded-full" style={{ background: c, width: '60%' }} /></div>
                  </div>
                ))}
              </div>
            </Card>

            {/* Deliverables */}
            <Card>
              <SectionHeader title="Deliverables" />
              <div className="space-y-2">
                {[
                  { type: 'Collab Reel', qty: 2, done: 1, icon: '🎬', note: 'Feature 2 creators together' },
                  { type: 'Solo Reel', qty: 1, done: 1, icon: '🎥', note: 'Individual creator reel' },
                  { type: 'Instagram Story', qty: 5, done: 3, icon: '📸', note: 'Product + CTA' },
                  { type: 'Instagram Post', qty: 1, done: 0, icon: '🖼️', note: 'Feed post with caption' },
                ].map((d, i) => (
                  <div key={i} className="flex items-center gap-3 bg-[#F9FAFB] rounded-2xl p-3">
                    <span className="text-xl flex-shrink-0">{d.icon}</span>
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-semibold text-[#111827]">{d.type}</span>
                        {d.type === 'Collab Reel' && <Badge variant="purple" size="sm">Collab</Badge>}
                      </div>
                      <p className="text-[10px] text-[#6B7280]">{d.note}</p>
                    </div>
                    <span className={`text-sm font-bold ${d.done === d.qty ? 'text-[#16A34A]' : 'text-[#F97316]'}`}>{d.done}/{d.qty}</span>
                  </div>
                ))}
              </div>
            </Card>

            <AICard title="AI Performance Prediction" subtitle="Campaign forecast">
              <div className="grid grid-cols-3 gap-2 mt-1">
                {[['Final Reach', '22.1M', '#F97316'], ['Final ROI', '5.2x', '#16A34A'], ['Eng. Rate', '7.4%', '#7C3AED']].map(([l,v,c]) => (
                  <div key={l as string} className="bg-white/80 rounded-xl p-2 text-center">
                    <p className="text-sm font-black" style={{ color: c as string }}>{v}</p>
                    <p className="text-[9px] text-[#6B7280]">{l}</p>
                  </div>
                ))}
              </div>
              <p className="text-xs text-[#374151] mt-2 bg-white/70 rounded-xl p-2">💡 Your Collab Reels are outperforming solo Reels by <strong>2.8×</strong> in reach.</p>
            </AICard>
          </div>
        )}

        {tab === 1 && (
          <div className="px-4 space-y-3">
            {[
              { name: 'Priya Sharma', status: 'Approved', reach: '4.2M', eng: '7.2%', type: 'Collab Reel', img: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=60&h=60&fit=crop&auto=format' },
              { name: 'Kavya Nair', status: 'Approved', reach: '3.8M', eng: '8.1%', type: 'Collab Reel', img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=60&h=60&fit=crop&auto=format' },
              { name: 'Ananya Gupta', status: 'Submitted', reach: '—', eng: '—', type: 'Solo Reel', img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=60&h=60&fit=crop&auto=format' },
              { name: 'Rohit Verma', status: 'Pending', reach: '—', eng: '—', type: 'Story', img: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=60&h=60&fit=crop&auto=format' },
            ].map((c, i) => (
              <Card key={i} className="p-3">
                <div className="flex items-center gap-3 mb-2">
                  <Avatar src={c.img} name={c.name} size="sm" verified />
                  <div className="flex-1">
                    <p className="text-sm font-semibold text-[#111827]">{c.name}</p>
                    <div className="flex items-center gap-1.5 mt-0.5">
                      <Badge variant={c.status === 'Approved' ? 'green' : c.status === 'Submitted' ? 'blue' : 'orange'} size="sm">{c.status}</Badge>
                      {c.type === 'Collab Reel' && <Badge variant="purple" size="sm">Collab</Badge>}
                    </div>
                  </div>
                  <button onClick={() => navigate('messages')} className="w-8 h-8 bg-[#F3F4F6] rounded-xl flex items-center justify-center"><Icon.Message /></button>
                </div>
                {c.reach !== '—' && (
                  <div className="flex gap-4 text-xs pt-2 border-t border-[#F9FAFB]">
                    <span className="text-[#6B7280]">Reach: <strong className="text-[#111827]">{c.reach}</strong></span>
                    <span className="text-[#6B7280]">Eng: <strong className="text-[#F97316]">{c.eng}</strong></span>
                  </div>
                )}
              </Card>
            ))}
            <Button variant="outline" fullWidth onClick={() => navigate('discover')}><Icon.Plus /> Invite More Creators</Button>
          </div>
        )}

        {tab === 2 && (
          <div className="px-4 space-y-4">
            <Card>
              <SectionHeader title="Daily Reach" subtitle="This week (M impressions)" />
              {loading ? <div className="skeleton h-28 rounded-2xl" /> : (
                <ResponsiveContainer width="100%" height={110}>
                  <BarChart data={perfData} margin={{ top: 4, right: 4, left: -28, bottom: 0 }}>
                    <XAxis dataKey="day" tick={{ fontSize: 10, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 10, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                    <Tooltip contentStyle={{ background: '#111827', border: 'none', borderRadius: 12, color: '#fff', fontSize: 11 }} formatter={(v) => [`${v}M`, 'Reach']} />
                    <Bar dataKey="reach" fill="#F97316" radius={[6,6,0,0]} />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </Card>
            <div className="grid grid-cols-2 gap-3">
              {[['18.4M','Total Reach','↑ +22%',true],['6.8M','Engagements','↑ +31%',true],['4.8x','ROI','↑ from 3.1x',true],['₹8L','Spent','On budget',true]].map(([v,l,c,p]) => (
                <div key={l as string} className="bg-white rounded-2xl border border-[#F1E6DD] p-3">
                  <p className="text-lg font-black text-[#111827]">{v}</p>
                  <p className="text-xs text-[#6B7280]">{l}</p>
                  <p className={`text-xs font-medium mt-0.5 ${p ? 'text-[#16A34A]' : 'text-[#DC2626]'}`}>{c}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      <div className="absolute bottom-20 right-4">
        <button onClick={() => toast('Campaign paused', 'info')} className="w-10 h-10 bg-white border border-[#F1E6DD] rounded-2xl flex items-center justify-center shadow-md">
          <Icon.MoreHorizontal />
        </button>
      </div>
    </div>
  )
}

// ─── CREATE CAMPAIGN ──────────────────────────────────────────────────────────
function CreateCampaign({ navigate }: { navigate: (s: string) => void }) {
  const [step, setStep] = useState(0)
  const [useAI, setUseAI] = useState(false)
  const [reelType, setReelType] = useState<'collab' | 'solo' | 'both'>('both')
  const [aiPrompt, setAiPrompt] = useState('')
  const [aiGenerating, setAiGenerating] = useState(false)
  const [aiGenerated, setAiGenerated] = useState(false)
  const toast = useToast()
  const steps = ['Info', 'Target', 'Deliverables', 'Review']

  const handleAIGenerate = () => {
    if (!aiPrompt.trim()) return
    setAiGenerating(true)
    setTimeout(() => { setAiGenerating(false); setAiGenerated(true); toast('Campaign brief generated by AI ✨', 'success') }, 2200)
  }

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4 border-b border-[#F1E6DD]">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => step > 0 ? setStep(s => s - 1) : navigate('campaigns')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Create Campaign</h1>
        </div>
        <div className="flex gap-1">
          {steps.map((s, i) => (
            <div key={s} className="flex-1 flex flex-col items-center gap-1">
              <div className={`w-full h-1.5 rounded-full transition-all ${i <= step ? 'bg-[#F97316]' : 'bg-[#F1E6DD]'}`} />
              <span className={`text-[9px] font-medium ${i <= step ? 'text-[#F97316]' : 'text-[#9CA3AF]'}`}>{s}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pt-4 pb-32 space-y-4">
        {/* AI Generator — always visible */}
        <AICard title="AI Campaign Generator">
          <div className="flex items-center justify-between mb-2">
            <p className="text-xs text-[#6B7280]">Let AI fill in the details</p>
            <Toggle checked={useAI} onChange={setUseAI} />
          </div>
          {useAI && (
            <div className="space-y-2">
              <textarea
                value={aiPrompt}
                onChange={e => setAiPrompt(e.target.value)}
                placeholder="e.g. Promote new matte lipstick to women 20–35 in Mumbai & Delhi with collab reels for max virality"
                className="w-full bg-white/80 border border-[#FDDCBE] rounded-2xl px-3 py-2.5 text-xs placeholder:text-[#C4A89A] focus:outline-none focus:border-[#F97316] resize-none h-20"
              />
              <Button size="sm" fullWidth loading={aiGenerating} onClick={handleAIGenerate}>
                <Icon.Sparkles /> {aiGenerating ? 'Generating…' : 'Generate Brief'}
              </Button>
              {aiGenerated && (
                <div className="bg-white/80 rounded-2xl p-3 border border-[#FDDCBE] space-y-1 animate-fade-in">
                  <p className="text-xs font-semibold text-[#111827]">✅ AI-generated campaign brief</p>
                  {[['Name','Nykaa Matte Lip Launch 2025'],['Goal','Product Launch + Virality'],['Budget','₹6,00,000'],['Target','Women 20–35 · Mumbai, Delhi'],['Reel Type','Collab Reel (recommended)']].map(([k,v]) => (
                    <div key={k} className="flex justify-between text-[10px]">
                      <span className="text-[#9CA3AF]">{k}</span>
                      <span className="font-medium text-[#374151]">{v}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </AICard>

        {step === 0 && <>
          <Input label="Campaign Name" placeholder="e.g. Nykaa Holiday Glow 2024" />
          <Select label="Campaign Goal" options={[
            { value: 'awareness', label: 'Brand Awareness' },
            { value: 'product', label: 'Product Launch' },
            { value: 'sales', label: 'Drive Sales' },
            { value: 'engagement', label: 'Boost Engagement' },
          ]} />
          <Input label="Total Budget (₹)" placeholder="5,00,000" icon={<Icon.DollarSign />} />
          <div className="grid grid-cols-2 gap-3">
            <Input label="Start Date" type="date" />
            <Input label="End Date" type="date" />
          </div>
        </>}

        {step === 1 && <>
          <div>
            <label className="text-sm font-medium text-[#374151] mb-2 block">Creator Categories</label>
            <div className="flex flex-wrap gap-2">
              {CATEGORIES.map(cat => <Chip key={cat} label={cat} onClick={() => {}} />)}
            </div>
          </div>
          <Select label="Target Location" options={[
            { value: 'all', label: '🇮🇳 All India' },
            { value: 'north', label: 'North India' },
            { value: 'south', label: 'South India' },
            { value: 'west', label: 'West India' },
            { value: 'metro', label: 'Metro Cities Only' },
          ]} />
          <div className="grid grid-cols-2 gap-3">
            <Input label="Min Followers" placeholder="10,000" />
            <Input label="Max Followers" placeholder="5,00,000" />
          </div>
          <Select label="Min Engagement Rate" options={[{ value: '2', label: '2%+' },{ value: '4', label: '4%+' },{ value: '6', label: '6%+' }]} />
        </>}

        {step === 2 && (
          <div className="space-y-4">
            {/* ─── COLLAB REEL OPTION ─────────────── */}
            <Card>
              <div className="flex items-center gap-2 mb-3">
                <h3 className="font-semibold text-[#111827] text-sm flex-1">Reel Type</h3>
                <AICard title="" subtitle="" className="px-2 py-1 !p-1.5">
                  <span className="text-[9px] text-[#F97316] font-semibold">AI recommends: Collab Reel</span>
                </AICard>
              </div>
              <div className="space-y-2">
                {([
                  { id: 'collab', title: 'Collab Reel', desc: '2 creators featured together — 3× more reach, higher trust', icon: '🤝', ai: true },
                  { id: 'solo', title: 'Non-Collab Reel', desc: 'Single creator solo Reel — full creative control', icon: '🎬', ai: false },
                  { id: 'both', title: 'Both Types', desc: 'Mix of Collab + Solo Reels for maximum coverage', icon: '⚡', ai: false },
                ] as const).map(opt => (
                  <button key={opt.id} onClick={() => setReelType(opt.id)}
                    className={`w-full flex items-start gap-3 p-3.5 rounded-2xl border-2 text-left transition-all ${reelType === opt.id ? 'border-[#F97316] bg-[#FFF1E8]' : 'border-[#F1E6DD] bg-white hover:border-[#FDDCBE]'}`}>
                    <span className="text-2xl flex-shrink-0">{opt.icon}</span>
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <span className={`text-sm font-bold ${reelType === opt.id ? 'text-[#C2410C]' : 'text-[#111827]'}`}>{opt.title}</span>
                        {opt.ai && <Badge variant="orange" size="sm">⭐ AI Pick</Badge>}
                        {opt.id === 'both' && <Badge variant="purple" size="sm">Popular</Badge>}
                      </div>
                      <p className="text-xs text-[#6B7280] mt-0.5 leading-relaxed">{opt.desc}</p>
                    </div>
                    <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 mt-0.5 ${reelType === opt.id ? 'border-[#F97316] bg-[#F97316]' : 'border-[#D1D5DB]'}`}>
                      {reelType === opt.id && <div className="w-2 h-2 bg-white rounded-full" />}
                    </div>
                  </button>
                ))}
                {reelType === 'collab' && (
                  <div className="bg-[#FFF1E8] rounded-2xl p-3 border border-[#FDDCBE] animate-fade-in">
                    <p className="text-xs font-semibold text-[#C2410C] mb-1">How Collab Reels work</p>
                    <p className="text-xs text-[#6B7280] leading-relaxed">Two creators co-create a single Reel that appears on both their profiles simultaneously — doubling your organic reach from one piece of content.</p>
                  </div>
                )}
              </div>
            </Card>

            {/* Other Deliverables */}
            <Card>
              <h3 className="font-semibold text-[#111827] mb-3 text-sm">Other Deliverables per Creator</h3>
              <div className="space-y-2">
                {[
                  { type: 'Instagram Story (set)', qty: 5, icon: '📸' },
                  { type: 'Instagram Post', qty: 1, icon: '🖼️' },
                ].map((d, i) => (
                  <div key={i} className="flex items-center gap-3 bg-[#F9FAFB] rounded-2xl p-3">
                    <span className="text-xl">{d.icon}</span>
                    <span className="flex-1 text-sm font-medium text-[#374151]">{d.type}</span>
                    <div className="flex items-center gap-2">
                      <button className="w-7 h-7 bg-white border border-[#F1E6DD] rounded-xl text-sm font-bold">-</button>
                      <span className="text-sm font-bold w-4 text-center">{d.qty}</span>
                      <button className="w-7 h-7 bg-[#F97316] rounded-xl text-sm font-bold text-white">+</button>
                    </div>
                  </div>
                ))}
              </div>
            </Card>

            <div>
              <label className="text-sm font-medium text-[#374151] mb-1.5 block">Campaign Brief</label>
              <textarea className="w-full bg-white border border-[#F1E6DD] rounded-2xl px-4 py-3 text-sm placeholder:text-[#9CA3AF] focus:outline-none focus:border-[#F97316] h-28 resize-none" placeholder="Brand guidelines, key messages, dos & don'ts..." />
            </div>
          </div>
        )}

        {step === 3 && <>
          <AICard title="AI Review" subtitle="Optimizations suggested">
            <div className="space-y-1.5 mt-1">
              {[
                '✅ Budget fits 12–18 quality creators',
                reelType !== 'solo' ? '✅ Collab Reel: expect 3× more organic reach' : '⚡ Consider adding Collab Reel for more reach',
                '⚠️ Add YouTube Shorts for 35% wider reach',
                '💡 Include Bengaluru for +18% reach boost',
                '✅ Timeline ideal for festive season',
              ].map((tip, i) => <p key={i} className="text-xs text-[#374151] bg-white/80 rounded-xl px-3 py-2">{tip}</p>)}
            </div>
          </AICard>
          <Card>
            <h3 className="font-semibold text-[#111827] mb-3">Summary</h3>
            <div className="space-y-2">
              {[
                ['Name', 'Nykaa Holiday Glow 2024'],
                ['Goal', 'Product Launch'],
                ['Budget', '₹5,00,000'],
                ['Timeline', 'Dec 15 – Dec 25'],
                ['Reel Type', reelType === 'collab' ? '🤝 Collab Reel' : reelType === 'solo' ? '🎬 Non-Collab Reel' : '⚡ Both Types'],
                ['Other', '5 Stories + 1 Post per creator'],
                ['Target', 'Fashion & Beauty · All India'],
              ].map(([k, v]) => (
                <div key={k} className="flex justify-between text-sm py-1 border-b border-[#F9FAFB] last:border-0">
                  <span className="text-[#6B7280]">{k}</span>
                  <span className="font-medium text-[#111827] text-right">{v}</span>
                </div>
              ))}
            </div>
          </Card>
        </>}
      </div>

      <div className="fixed bottom-0 left-0 right-0 bg-white/90 backdrop-blur-sm border-t border-[#F1E6DD] p-5 pb-8">
        <Button fullWidth size="lg" onClick={() => {
          if (step < 3) { setStep(s => s + 1) }
          else { toast('Campaign published! 🚀', 'success'); setTimeout(() => navigate('campaigns'), 700) }
        }}>
          {step < 3 ? 'Continue' : '🚀 Publish Campaign'}
        </Button>
      </div>
    </div>
  )
}

// ─── DISCOVER CREATORS ────────────────────────────────────────────────────────
function DiscoverCreators({ navigate }: { navigate: (s: string) => void }) {
  const [search, setSearch] = useState('')
  const [activeFilters, setActiveFilters] = useState<string[]>([])
  const loading = useLoading(1000)
  const toast = useToast()
  const creators = [
    { name: 'Priya Sharma', handle: '@priya.sharma.in', cat: 'Fashion & Beauty', followers: '248K', eng: '6.2%', score: 81, city: 'Mumbai', img: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80&h=80&fit=crop&auto=format', verified: true },
    { name: 'Kavya Nair', handle: '@kavya.beauty', cat: 'Beauty & Skincare', followers: '312K', eng: '7.4%', score: 88, city: 'Chennai', img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop&auto=format', verified: true },
    { name: 'Arjun Mehta', handle: '@arjuntech', cat: 'Technology', followers: '182K', eng: '4.8%', score: 76, city: 'Bengaluru', img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&auto=format', verified: true },
    { name: 'Ananya Gupta', handle: '@ananya.lifestyle', cat: 'Lifestyle', followers: '156K', eng: '5.6%', score: 79, city: 'Hyderabad', img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=80&h=80&fit=crop&auto=format', verified: true },
    { name: 'Rahul Singh', handle: '@rahulfoodlover', cat: 'Food & Travel', followers: '94K', eng: '8.1%', score: 74, city: 'Delhi', img: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop&auto=format', verified: false },
    { name: 'Karthik Raja', handle: '@karthikfitness', cat: 'Fitness', followers: '220K', eng: '5.9%', score: 83, city: 'Bengaluru', img: 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=80&h=80&fit=crop&auto=format', verified: false },
  ]
  const filters = ['Category', 'Followers', 'Engagement', 'Location', 'AI Score', 'Budget']

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-3">
        <div className="flex items-center gap-3 mb-3">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Discover Creators</h1>
        </div>
        <SearchBar placeholder="Search by name, niche, city..." value={search} onChange={setSearch} className="mb-3" />
        <div className="flex gap-2 overflow-x-auto pb-1">
          {filters.map(f => (
            <button key={f} onClick={() => setActiveFilters(p => p.includes(f) ? p.filter(x => x !== f) : [...p, f])}
              className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-medium border transition-all ${activeFilters.includes(f) ? 'bg-[#F97316] text-white border-[#F97316]' : 'bg-white text-[#6B7280] border-[#F1E6DD]'}`}>
              {f}
            </button>
          ))}
        </div>
      </div>
      <p className="text-xs text-[#6B7280] px-5 mb-2"><strong className="text-[#111827]">1,247 creators</strong> · Sorted by AI Match</p>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-3">
        {loading ? <><SkeletonCard /><SkeletonCard /><SkeletonCard /></> : creators.map(c => (
          <Card key={c.name} hover onClick={() => navigate('creator-profile')}>
            <div className="flex items-center gap-3 mb-3">
              <Avatar src={c.img} name={c.name} size="lg" verified={c.verified} />
              <div className="flex-1 min-w-0">
                <p className="font-bold text-[#111827] text-sm">{c.name}</p>
                <p className="text-xs text-[#6B7280]">{c.handle}</p>
                <p className="text-xs text-[#9CA3AF]">{c.city} · {c.cat}</p>
              </div>
              <div className="flex flex-col items-center flex-shrink-0">
                <div className="relative w-14 h-14">
                  <svg width="56" height="56" className="-rotate-90">
                    <circle cx="28" cy="28" r="22" fill="none" stroke="#F1E6DD" strokeWidth="4" />
                    <circle cx="28" cy="28" r="22" fill="none" stroke="#F97316" strokeWidth="4" strokeLinecap="round" strokeDasharray="138.2" strokeDashoffset={138.2 - (c.score / 100) * 138.2} />
                  </svg>
                  <div className="absolute inset-0 flex items-center justify-center"><span className="text-sm font-black text-[#111827]">{c.score}</span></div>
                </div>
                <span className="text-[9px] text-[#6B7280]">AI Score</span>
              </div>
            </div>
            <div className="grid grid-cols-3 gap-2 mb-3">
              {[['Followers', c.followers], ['Engagement', c.eng], ['City', c.city]].map(([lbl, val]) => (
                <div key={lbl as string} className="bg-[#F9FAFB] rounded-xl p-2 text-center">
                  <p className="text-xs font-bold text-[#111827]">{val}</p>
                  <p className="text-[9px] text-[#9CA3AF]">{lbl}</p>
                </div>
              ))}
            </div>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" fullWidth onClick={e => { e.stopPropagation(); toast(`${c.name} saved to collection`, 'success') }}><Icon.Bookmark /></Button>
              <Button variant="primary" size="sm" fullWidth onClick={e => { e.stopPropagation(); toast(`Invite sent to ${c.name} ✉️`) }}>Invite</Button>
            </div>
          </Card>
        ))}
      </div>
    </div>
  )
}

// ─── CREATOR PROFILE ─────────────────────────────────────────────────────────
function CreatorProfile({ navigate }: { navigate: (s: string) => void }) {
  const [invited, setInvited] = useState(false)
  const [saved, setSaved] = useState(false)
  const toast = useToast()
  const audienceData = [{ name: 'F', value: 72 }, { name: 'M', value: 28 }]
  const COLORS = ['#F97316', '#DBEAFE']

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="relative">
        <div className="h-32 w-full bg-gradient-to-br from-[#F97316] to-[#EA580C]" />
        <button onClick={() => navigate('discover')} className="absolute top-12 left-4 w-9 h-9 bg-white/80 backdrop-blur-sm rounded-xl flex items-center justify-center"><Icon.ChevronLeft /></button>
        <button onClick={() => { setSaved(!saved); toast(!saved ? 'Added to collection 📁' : 'Removed from collection', !saved ? 'success' : 'info') }}
          className={`absolute top-12 right-4 w-9 h-9 rounded-xl flex items-center justify-center ${saved ? 'bg-[#F97316]' : 'bg-white/80 backdrop-blur-sm'}`}>
          <span className={saved ? 'text-white' : 'text-[#6B7280]'}><Icon.Bookmark /></span>
        </button>
        <div className="absolute -bottom-6 left-5">
          <Avatar src="https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80&h=80&fit=crop&auto=format" name="Priya Sharma" size="xl" verified />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-32 pt-10 space-y-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <h2 className="text-xl font-bold text-[#111827]">Priya Sharma</h2>
            <Badge variant="green">Verified</Badge>
          </div>
          <p className="text-sm text-[#6B7280]">@priya.sharma.in · Fashion & Lifestyle · Mumbai</p>
          <div className="flex flex-wrap gap-1.5 mt-2">
            {['Fashion', 'Beauty', 'Lifestyle'].map(t => <Chip key={t} label={t} />)}
          </div>
        </div>

        <div className="grid grid-cols-4 gap-2">
          {[['248K','Followers'],['6.2%','Engagement'],['2.4M','Reach/Mo'],['4.8★','Rating']].map(([v,l]) => (
            <div key={l as string} className="bg-white border border-[#F1E6DD] rounded-2xl p-2.5 text-center">
              <p className="text-sm font-bold text-[#111827]">{v}</p>
              <p className="text-[10px] text-[#6B7280]">{l}</p>
            </div>
          ))}
        </div>

        <AICard title="AI Brand Match Analysis" subtitle="Match score for Nykaa">
          <div className="grid grid-cols-3 gap-2 mt-2">
            {[['Audience', 87, '#F97316'],['Content', 94, '#16A34A'],['Safety', 98, '#2563EB']].map(([lbl, val, clr]) => (
              <div key={lbl as string} className="bg-white/80 rounded-xl p-2.5 text-center">
                <p className="text-base font-bold text-[#111827]">{val}%</p>
                <ProgressBar value={val as number} color={clr as string} />
                <p className="text-[9px] text-[#6B7280] mt-1">{lbl}</p>
              </div>
            ))}
          </div>
          <p className="text-xs text-[#374151] mt-2 bg-white/70 rounded-xl p-2">💡 72% female Mumbai audience aligns perfectly with your target market.</p>
        </AICard>

        {/* Audience Pie */}
        <Card>
          <SectionHeader title="Audience Demographics" />
          <div className="flex items-center gap-4">
            <ResponsiveContainer width={100} height={100}>
              <PieChart>
                <Pie data={audienceData} cx="50%" cy="50%" innerRadius={28} outerRadius={45} dataKey="value" startAngle={90} endAngle={-270}>
                  {audienceData.map((_, i) => <Cell key={i} fill={COLORS[i]} />)}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
            <div className="flex-1 space-y-2">
              <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-[#F97316]" /><span className="text-xs text-[#374151]">Female <strong>72%</strong></span></div>
              <div className="flex items-center gap-2"><div className="w-3 h-3 rounded-full bg-[#DBEAFE]" /><span className="text-xs text-[#374151]">Male <strong>28%</strong></span></div>
              <div className="mt-2 space-y-1">
                {[['18–24', 38], ['25–34', 44], ['35–44', 12]].map(([age, pct]) => (
                  <div key={age as string} className="flex items-center gap-2">
                    <span className="text-[10px] text-[#6B7280] w-12">{age}</span>
                    <div className="flex-1 h-1.5 bg-[#F3F4F6] rounded-full"><div className="h-full bg-[#F97316] rounded-full" style={{ width: `${pct}%` }} /></div>
                    <span className="text-[10px] text-[#6B7280]">{pct}%</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </Card>

        <Card>
          <SectionHeader title="Rate Card" />
          <div className="space-y-2">
            {[
              ['Collab Reel (shared)', '₹28,000–42,000', true],
              ['Solo Reel', '₹42,000–58,000', false],
              ['Instagram Post', '₹18,000–32,000', false],
              ['Story (5)', '₹15,000–25,000', false],
            ].map(([t, r, collab]) => (
              <div key={t as string} className="flex items-center justify-between text-sm py-2 border-b border-[#F9FAFB] last:border-0">
                <div className="flex items-center gap-1.5">
                  <span className="text-[#6B7280]">{t}</span>
                  {collab && <Badge variant="purple" size="sm">Collab</Badge>}
                </div>
                <span className="font-semibold text-[#111827]">{r}</span>
              </div>
            ))}
          </div>
        </Card>
      </div>

      <div className="fixed bottom-0 left-0 right-0 bg-white/90 backdrop-blur-sm border-t border-[#F1E6DD] p-5 pb-8 flex gap-3">
        <Button variant="outline" onClick={() => navigate('messages')}><Icon.Message /></Button>
        <Button fullWidth size="lg" onClick={() => { setInvited(!invited); if (!invited) toast('Invite sent to Priya Sharma ✉️') }}>
          {invited ? <><Icon.Check /> Invited</> : <><Icon.Share /> Invite to Campaign</>}
        </Button>
      </div>
    </div>
  )
}

// ─── ANALYTICS ────────────────────────────────────────────────────────────────
const monthlyData = [
  { month: 'Jan', reach: 18, roi: 3.1 }, { month: 'Feb', reach: 14, roi: 2.8 },
  { month: 'Mar', reach: 22, roi: 3.6 }, { month: 'Apr', reach: 30, roi: 4.1 },
  { month: 'May', reach: 28, roi: 3.9 }, { month: 'Jun', reach: 35, roi: 4.4 },
  { month: 'Jul', reach: 38, roi: 4.6 }, { month: 'Aug', reach: 42, roi: 4.8 },
  { month: 'Sep', reach: 48, roi: 5.1 }, { month: 'Oct', reach: 55, roi: 5.8 },
  { month: 'Nov', reach: 48, roi: 4.9 }, { month: 'Dec', reach: 62, roi: 6.2 },
]
const stateData = [
  { state: 'MH', pct: 28 }, { state: 'KA', pct: 18 }, { state: 'DL', pct: 16 },
  { state: 'TN', pct: 12 }, { state: 'GJ', pct: 10 }, { state: 'TS', pct: 9 }, { state: 'RJ', pct: 7 },
]

function BrandAnalyticsScreen({ navigate }: { navigate: (s: string) => void }) {
  const [period, setPeriod] = useState(2)
  const loading = useLoading(800)

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Analytics & ROI</h1>
        </div>
        <TabBar tabs={['7D', '30D', '3M', '1Y']} active={period} onChange={setPeriod} />
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-4">
        {loading ? (
          <div className="grid grid-cols-2 gap-3"><SkeletonStat /><SkeletonStat /><SkeletonStat /><SkeletonStat /></div>
        ) : <>
          <div className="grid grid-cols-2 gap-3">
            <StatCard label="Total Reach" value="48.2M" change="+22%" positive icon={<Icon.Eye />} />
            <StatCard label="Avg ROI" value="4.2x" change="↑ from 3.1x" positive icon={<Icon.TrendUp />} color="#16A34A" />
            <StatCard label="Engagements" value="6.8M" change="+31%" positive icon={<Icon.Heart />} color="#7C3AED" />
            <StatCard label="Total Spend" value="₹18.4L" change="12 campaigns" icon={<Icon.DollarSign />} color="#2563EB" />
          </div>

          {/* Reach + ROI dual chart */}
          <Card>
            <SectionHeader title="Reach vs ROI" subtitle="12-month trend" />
            <ResponsiveContainer width="100%" height={140}>
              <AreaChart data={monthlyData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="reachG2" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#F97316" stopOpacity={0.2} />
                    <stop offset="95%" stopColor="#F97316" stopOpacity={0} />
                  </linearGradient>
                  <linearGradient id="roiG" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#16A34A" stopOpacity={0.2} />
                    <stop offset="95%" stopColor="#16A34A" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis dataKey="month" tick={{ fontSize: 9, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 9, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ background: '#111827', border: 'none', borderRadius: 12, color: '#fff', fontSize: 11 }} />
                <Area type="monotone" dataKey="reach" stroke="#F97316" strokeWidth={2} fill="url(#reachG2)" dot={false} name="Reach (M)" />
                <Area type="monotone" dataKey="roi" stroke="#16A34A" strokeWidth={2} fill="url(#roiG)" dot={false} name="ROI (x)" />
              </AreaChart>
            </ResponsiveContainer>
            <div className="flex gap-4 mt-1">
              <div className="flex items-center gap-1.5"><div className="w-3 h-1.5 bg-[#F97316] rounded" /><span className="text-[10px] text-[#6B7280]">Reach (M)</span></div>
              <div className="flex items-center gap-1.5"><div className="w-3 h-1.5 bg-[#16A34A] rounded" /><span className="text-[10px] text-[#6B7280]">ROI (x)</span></div>
            </div>
          </Card>

          {/* Reach by State bar */}
          <Card>
            <SectionHeader title="Reach by State" subtitle="Top 7 states" />
            <ResponsiveContainer width="100%" height={110}>
              <BarChart data={stateData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                <XAxis dataKey="state" tick={{ fontSize: 10, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 10, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ background: '#111827', border: 'none', borderRadius: 12, color: '#fff', fontSize: 11 }} formatter={(v) => [`${v}%`, 'Share']} />
                <Bar dataKey="pct" fill="#F97316" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Card>

          <AICard title="AI ROI Prediction" subtitle="Next campaign forecast">
            <div className="flex items-center gap-4 mt-1">
              <div className="text-center">
                <p className="text-3xl font-black text-[#F97316]">5.4x</p>
                <p className="text-xs text-[#6B7280]">Expected ROI</p>
                <p className="text-xs text-[#16A34A] mt-0.5">Top 13% of brands</p>
              </div>
              <div className="flex-1 space-y-1.5">
                <ProgressBar label="Confidence" value={84} showValue />
                <ProgressBar label="Reach potential" value={92} showValue color="#16A34A" />
              </div>
            </div>
          </AICard>

          <Card>
            <SectionHeader title="Creator Performance" />
            <div className="space-y-3">
              {[
                { name: 'Priya Sharma', roi: '5.1x', reach: '4.2M', eng: '7.2%', img: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=40&h=40&fit=crop&auto=format' },
                { name: 'Kavya Nair', roi: '4.8x', reach: '3.8M', eng: '8.1%', img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=40&h=40&fit=crop&auto=format' },
                { name: 'Arjun Mehta', roi: '3.4x', reach: '2.1M', eng: '5.2%', img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop&auto=format' },
              ].map(c => (
                <div key={c.name} className="flex items-center gap-3">
                  <Avatar src={c.img} name={c.name} size="sm" />
                  <div className="flex-1"><p className="text-sm font-semibold text-[#111827]">{c.name}</p><p className="text-xs text-[#6B7280]">{c.reach}</p></div>
                  <div className="text-right"><p className="text-sm font-bold text-[#16A34A]">{c.roi}</p><p className="text-xs text-[#F97316]">{c.eng}</p></div>
                </div>
              ))}
            </div>
          </Card>
        </>}
      </div>
    </div>
  )
}

// ─── COLLECTIONS ──────────────────────────────────────────────────────────────
function Collections({ navigate }: { navigate: (s: string) => void }) {
  const toast = useToast()
  const collections = [
    { name: 'Holiday Campaign Picks', count: 8, img: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=60&h=60&fit=crop&auto=format' },
    { name: 'Beauty Influencers', count: 14, img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=60&h=60&fit=crop&auto=format' },
    { name: 'Micro-creators 50K–200K', count: 22, img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=60&h=60&fit=crop&auto=format' },
    { name: 'Tech Reviewers', count: 6, img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop&auto=format' },
  ]
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Saved Collections</h1>
          <button onClick={() => toast('Collection created', 'success')} className="ml-auto w-9 h-9 bg-[#F97316] rounded-xl flex items-center justify-center text-white"><Icon.Plus /></button>
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-3">
        {collections.map(col => (
          <Card key={col.name} hover className="flex items-center gap-4 p-4">
            <div className="relative w-14 h-14 flex-shrink-0">
              <img src={col.img} alt="" className="w-14 h-14 rounded-2xl object-cover bg-[#F3F4F6]" />
              <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-[#F97316] rounded-full flex items-center justify-center text-[10px] font-bold text-white border border-white">{col.count}</div>
            </div>
            <div className="flex-1">
              <p className="font-bold text-[#111827] text-sm">{col.name}</p>
              <p className="text-xs text-[#6B7280] mt-0.5">{col.count} creators saved</p>
            </div>
            <Icon.ChevronRight />
          </Card>
        ))}
        <Button variant="outline" fullWidth onClick={() => navigate('discover')}><Icon.Search /> Discover More Creators</Button>
      </div>
    </div>
  )
}

// ─── MESSAGES ────────────────────────────────────────────────────────────────
function BrandMessages({ navigate }: { navigate: (s: string) => void }) {
  const [activeChat, setActiveChat] = useState<string | null>(null)
  const [msg, setMsg] = useState('')
  const toast = useToast()
  const chats = [
    { name: 'Priya Sharma', last: "I'll confirm the shoot date tomorrow", time: '2m', unread: 2, img: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=40&h=40&fit=crop&auto=format' },
    { name: 'Kavya Nair', last: 'The draft looks great! Posting tomorrow', time: '1h', unread: 0, img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=40&h=40&fit=crop&auto=format' },
    { name: 'Arjun Mehta', last: 'Can you share the product details?', time: '3h', unread: 1, img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop&auto=format' },
    { name: 'Rohit Verma', last: 'Payment received, thank you! 🙏', time: 'Yesterday', unread: 0, img: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=40&h=40&fit=crop&auto=format' },
  ]
  if (activeChat) {
    const chat = chats.find(c => c.name === activeChat)!
    return (
      <div className="flex flex-col h-full bg-[#FFFDFB]">
        <div className="flex items-center gap-3 px-5 pt-12 pb-4 border-b border-[#F1E6DD] bg-white">
          <button onClick={() => setActiveChat(null)}><Icon.ChevronLeft /></button>
          <Avatar src={chat.img} name={chat.name} size="sm" verified />
          <div className="flex-1"><p className="font-semibold text-[#111827] text-sm">{chat.name}</p><p className="text-xs text-[#16A34A]">Online</p></div>
          <button className="w-8 h-8 bg-[#F3F4F6] rounded-xl flex items-center justify-center"><Icon.Phone /></button>
        </div>
        <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3">
          {[
            { from: 'creator', text: "Hi! I've received the campaign brief. Looks great!", time: '10:30 AM' },
            { from: 'brand', text: "Wonderful! Any questions about deliverables?", time: '10:32 AM' },
            { from: 'creator', text: "For the Collab Reel — should I co-create with Kavya Nair?", time: '10:34 AM' },
            { from: 'brand', text: "Yes! Priya + Kavya is the perfect pairing. We'll connect you both. The Collab Reel should be 45–60 seconds.", time: '10:36 AM' },
            { from: 'creator', text: "Perfect! I'll confirm the shoot date tomorrow 📅", time: '10:38 AM' },
          ].map((m, i) => (
            <div key={i} className={`flex ${m.from === 'brand' ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-[75%] px-4 py-3 rounded-2xl text-sm ${m.from === 'brand' ? 'bg-[#F97316] text-white rounded-br-sm' : 'bg-white border border-[#F1E6DD] text-[#111827] rounded-bl-sm'}`}>
                <p>{m.text}</p>
                <p className={`text-[10px] mt-1 ${m.from === 'brand' ? 'text-white/70' : 'text-[#9CA3AF]'}`}>{m.time}</p>
              </div>
            </div>
          ))}
        </div>
        <div className="px-4 py-3 bg-white border-t border-[#F1E6DD] flex gap-2 items-center">
          <button className="w-9 h-9 bg-[#F3F4F6] rounded-xl flex items-center justify-center flex-shrink-0"><Icon.Upload /></button>
          <input value={msg} onChange={e => setMsg(e.target.value)} placeholder="Type a message..."
            className="flex-1 bg-[#F9FAFB] rounded-2xl px-4 py-2.5 text-sm border border-[#F1E6DD] focus:outline-none focus:border-[#F97316]" />
          <button onClick={() => { if (msg.trim()) { toast('Message sent'); setMsg('') } }}
            className="w-9 h-9 bg-[#F97316] rounded-xl flex items-center justify-center flex-shrink-0 text-white"><Icon.ArrowRight /></button>
        </div>
      </div>
    )
  }
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Messages</h1>
        </div>
        <SearchBar placeholder="Search creators..." />
      </div>
      <div className="flex-1 overflow-y-auto divide-y divide-[#F9FAFB]">
        {chats.map(chat => (
          <button key={chat.name} onClick={() => setActiveChat(chat.name)} className="w-full flex items-center gap-3 px-5 py-4 hover:bg-[#F9FAFB] text-left">
            <Avatar src={chat.img} name={chat.name} size="md" verified />
            <div className="flex-1 min-w-0">
              <div className="flex justify-between"><p className="text-sm font-semibold text-[#111827]">{chat.name}</p><p className="text-xs text-[#9CA3AF]">{chat.time}</p></div>
              <p className="text-xs text-[#6B7280] truncate mt-0.5">{chat.last}</p>
            </div>
            {chat.unread > 0 && <span className="w-5 h-5 bg-[#F97316] rounded-full text-[10px] text-white flex items-center justify-center flex-shrink-0 font-bold">{chat.unread}</span>}
          </button>
        ))}
      </div>
    </div>
  )
}

// ─── PAYMENTS ────────────────────────────────────────────────────────────────
function BrandPaymentsScreen({ navigate }: { navigate: (s: string) => void }) {
  const toast = useToast()
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Payments</h1>
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-4">
        <div className="rounded-3xl p-6 text-white relative overflow-hidden" style={{ background: 'linear-gradient(135deg, #111827 0%, #1f2937 100%)' }}>
          <div className="absolute top-0 right-0 w-32 h-32 opacity-10 rounded-full bg-[#F97316]" style={{ transform: 'translate(30%,-30%)' }} />
          <p className="text-white/60 text-sm mb-1">Total Spent</p>
          <p className="text-4xl font-black">₹34.2L</p>
          <p className="text-white/60 text-sm mt-1">FY 2024–25</p>
          <div className="flex gap-3 mt-4">
            {[['Pending', '₹8.5L'], ['This Month', '₹12.4L']].map(([l, v]) => (
              <div key={l} className="bg-white/10 rounded-2xl px-3 py-2">
                <p className="text-xs text-white/60">{l}</p>
                <p className="text-sm font-bold text-white">{v}</p>
              </div>
            ))}
          </div>
        </div>
        <SectionHeader title="Recent Payments" />
        {[
          { creator: 'Priya Sharma', campaign: 'Holiday Glow', amount: '₹58,000', date: 'Dec 10', status: 'paid', img: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=40&h=40&fit=crop&auto=format' },
          { creator: 'Kavya Nair', campaign: 'Holiday Glow', amount: '₹72,000', date: 'Dec 10', status: 'paid', img: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=40&h=40&fit=crop&auto=format' },
          { creator: 'Arjun Mehta', campaign: 'Tech Launch', amount: '₹45,000', date: 'Dec 8', status: 'pending', img: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop&auto=format' },
          { creator: 'Ananya Gupta', campaign: 'Holiday Glow', amount: '₹38,000', date: 'Dec 5', status: 'processing', img: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=40&h=40&fit=crop&auto=format' },
        ].map((t, i) => (
          <Card key={i} className="flex items-center gap-3 p-3">
            <Avatar src={t.img} name={t.creator} size="md" />
            <div className="flex-1">
              <p className="text-sm font-semibold text-[#111827]">{t.creator}</p>
              <p className="text-xs text-[#6B7280]">{t.campaign} · {t.date}</p>
            </div>
            <div className="text-right">
              <p className="text-sm font-bold text-[#111827]">{t.amount}</p>
              <Badge variant={t.status === 'paid' ? 'green' : t.status === 'pending' ? 'orange' : 'blue'} size="sm">{t.status}</Badge>
            </div>
          </Card>
        ))}
        <Button variant="outline" fullWidth onClick={() => toast('Invoice exported as PDF', 'info')}><Icon.Download /> Export Invoices</Button>
      </div>
    </div>
  )
}

// ─── SETTINGS ────────────────────────────────────────────────────────────────
function BrandSettingsModal({ title, onClose, children }: { title: string; onClose: () => void; children: React.ReactNode }) {
  return (
    <div className="absolute inset-0 z-50 flex flex-col justify-end bg-black/40" onClick={onClose}>
      <div className="bg-white rounded-t-3xl p-5 max-h-[80%] overflow-y-auto" onClick={e => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-5">
          <h2 className="text-lg font-bold text-[#111827]">{title}</h2>
          <button onClick={onClose} className="w-8 h-8 bg-[#F3F4F6] rounded-xl flex items-center justify-center text-[#6B7280]">✕</button>
        </div>
        {children}
      </div>
    </div>
  )
}

function BrandSettings({ navigate }: { navigate: (s: string) => void }) {
  const [notif, setNotif] = useState(true)
  const [emailRep, setEmailRep] = useState(true)
  const [shopify, setShopify] = useState(true)
  const [meta, setMeta] = useState(false)
  const [google, setGoogle] = useState(true)
  const [modal, setModal] = useState<string|null>(null)
  const [brandName, setBrandName] = useState('Nykaa Beauty')
  const [brandEmail, setBrandEmail] = useState('marketing@nykaa.com')
  const [website, setWebsite] = useState('www.nykaa.com')
  const [teamInvite, setTeamInvite] = useState('')
  const [members] = useState([
    { name: 'Rahul Mehta', email: 'rahul@nykaa.com', role: 'Admin' },
    { name: 'Sneha Patel', email: 'sneha@nykaa.com', role: 'Manager' },
  ])
  const toast = useToast()

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] relative">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-5">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Settings</h1>
        </div>
        <div className="flex items-center gap-3 bg-white rounded-3xl p-4 border border-[#F1E6DD] mb-5" style={{ boxShadow: '0 4px 16px rgba(0,0,0,0.06)' }}>
          <div className="w-14 h-14 bg-[#111827] rounded-2xl flex items-center justify-center text-2xl font-black text-[#F97316]">{brandName[0]}</div>
          <div className="flex-1">
            <p className="font-bold text-[#111827]">{brandName}</p>
            <p className="text-sm text-[#6B7280]">{brandEmail}</p>
            <Badge variant="orange">Pro Plan</Badge>
          </div>
          <button onClick={() => setModal('profile')} className="w-9 h-9 bg-[#F3F4F6] rounded-xl flex items-center justify-center"><Icon.ChevronRight /></button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-4">
        {[
          { section: 'Account', items: [
            { icon: <Icon.Briefcase />, label: 'Brand Profile', action: () => setModal('profile') },
            { icon: <Icon.Users />, label: 'Team Members', action: () => setModal('team'), sub: `${members.length} members` },
            { icon: <Icon.Globe />, label: 'Connected Integrations', action: () => setModal('integrations') },
          ]},
          { section: 'Notifications', items: [
            { icon: <Icon.Bell />, label: 'Push Notifications', toggle: true, value: notif, onToggle: setNotif },
            { icon: <Icon.Mail />, label: 'Email Reports', toggle: true, value: emailRep, onToggle: setEmailRep },
          ]},
          { section: 'Resources', items: [
            { icon: <Icon.Layers />, label: 'Download tokens.json', action: () => { window.open('/tokens.json', '_blank'); toast('tokens.json opened', 'info') } },
            { icon: <Icon.Info />, label: 'Help Center', action: () => setModal('help') },
          ]},
          { section: 'Account', items: [
            { icon: <Icon.LogOut />, label: 'Log Out', danger: true, action: () => navigate('splash') },
          ]},
        ].map((group, gi) => (
          <div key={gi}>
            <p className="text-xs font-semibold text-[#9CA3AF] uppercase tracking-wider mb-2 px-1">{group.section}</p>
            <Card className="p-0 divide-y divide-[#F9FAFB] overflow-hidden">
              {group.items.map((item: any, i) => (
                <button key={i} onClick={item.action} className="w-full flex items-center gap-3 px-4 py-3.5 hover:bg-[#F9FAFB] text-left">
                  <span className={`flex-shrink-0 ${item.danger ? 'text-[#DC2626]' : 'text-[#6B7280]'}`}>{item.icon}</span>
                  <span className={`flex-1 text-sm font-medium ${item.danger ? 'text-[#DC2626]' : 'text-[#374151]'}`}>{item.label}</span>
                  {item.sub && <span className="text-xs text-[#9CA3AF] mr-1">{item.sub}</span>}
                  {item.toggle ? <Toggle checked={item.value} onChange={item.onToggle} /> : <Icon.ChevronRight />}
                </button>
              ))}
            </Card>
          </div>
        ))}
      </div>

      {/* ── Modals ── */}
      {modal === 'profile' && (
        <BrandSettingsModal title="Brand Profile" onClose={() => setModal(null)}>
          <div className="space-y-3">
            <Input label="Brand Name" value={brandName} onChange={e => setBrandName(e.target.value)} />
            <Input label="Work Email" value={brandEmail} onChange={e => setBrandEmail(e.target.value)} />
            <Input label="Website" value={website} onChange={e => setWebsite(e.target.value)} />
            <Button fullWidth onClick={() => { toast('Brand profile updated!', 'success'); setModal(null) }}>Save Changes</Button>
          </div>
        </BrandSettingsModal>
      )}

      {modal === 'team' && (
        <BrandSettingsModal title="Team Members" onClose={() => setModal(null)}>
          <div className="space-y-3">
            {members.map(m => (
              <div key={m.email} className="flex items-center gap-3 p-3 bg-[#F9FAFB] rounded-2xl">
                <div className="w-9 h-9 bg-[#111827] rounded-xl flex items-center justify-center text-[#F97316] font-bold text-sm">{m.name[0]}</div>
                <div className="flex-1">
                  <p className="text-sm font-semibold text-[#111827]">{m.name}</p>
                  <p className="text-xs text-[#6B7280]">{m.email}</p>
                </div>
                <Badge variant="orange">{m.role}</Badge>
              </div>
            ))}
            <div className="flex gap-2 mt-2">
              <input value={teamInvite} onChange={e => setTeamInvite(e.target.value)} placeholder="colleague@brand.com"
                className="flex-1 border border-[#E5E7EB] rounded-2xl px-3 py-2.5 text-sm focus:outline-none focus:border-[#F97316]" />
              <button onClick={() => { if (teamInvite) { toast(`Invite sent to ${teamInvite}`, 'success'); setTeamInvite('') } }}
                className="bg-[#F97316] text-white px-4 rounded-2xl text-sm font-semibold">Invite</button>
            </div>
          </div>
        </BrandSettingsModal>
      )}

      {modal === 'integrations' && (
        <BrandSettingsModal title="Connected Integrations" onClose={() => setModal(null)}>
          <div className="space-y-3">
            {[
              { name: 'Shopify', desc: 'Sync product catalog & track sales', color: '#96BF48', state: shopify, set: setShopify },
              { name: 'Meta Ads', desc: 'Boost creator content as ads', color: '#1877F2', state: meta, set: setMeta },
              { name: 'Google Analytics', desc: 'Track campaign traffic & conversions', color: '#EA4335', state: google, set: setGoogle },
            ].map(int => (
              <div key={int.name} className="flex items-center gap-3 p-3 bg-[#F9FAFB] rounded-2xl">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold text-sm" style={{ background: int.color }}>{int.name[0]}</div>
                <div className="flex-1">
                  <p className="text-sm font-semibold text-[#111827]">{int.name}</p>
                  <p className="text-xs text-[#6B7280]">{int.desc}</p>
                </div>
                <Toggle checked={int.state} onChange={int.set} />
              </div>
            ))}
            <Button fullWidth variant="outline" onClick={() => toast('More integrations coming soon', 'info')}>+ Add Integration</Button>
          </div>
        </BrandSettingsModal>
      )}

      {modal === 'help' && (
        <BrandSettingsModal title="Help Center" onClose={() => setModal(null)}>
          <div className="space-y-3">
            {[['How do I create a campaign?','Go to Campaigns → tap + New → fill in the brief and set your budget.'],['How does AI creator matching work?','Our AI scores creators on niche relevance, engagement rate, past ROI, and audience match.'],['When are creators paid?','Payments are released automatically 7 days after content approval.'],['What is a Collab Reel?','Two creators co-create one reel — AI pairs them for maximum combined reach.']].map(([q, a]) => (
              <div key={q} className="p-3 bg-[#F9FAFB] rounded-2xl">
                <p className="text-sm font-semibold text-[#111827]">{q}</p>
                <p className="text-xs text-[#6B7280] mt-1">{a}</p>
              </div>
            ))}
            <Button fullWidth variant="outline" onClick={() => toast('Support chat coming soon', 'info')}>Chat with Support</Button>
          </div>
        </BrandSettingsModal>
      )}
    </div>
  )
}

function BrandNotifications({ navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Notifications</h1>
          <button className="ml-auto text-xs text-[#F97316] font-medium">Mark all read</button>
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-2">
        {[
          { icon: '🎯', title: 'AI found 3 new creator matches', desc: 'Priya Sharma (94%), Kavya Nair (91%), and 1 more match your campaign', time: '5 min ago', unread: true },
          { icon: '🤝', title: 'Collab Reel tip from AI', desc: 'Pair Priya + Kavya for a Collab Reel — projected 3.2× reach vs solo', time: '30 min ago', unread: true },
          { icon: '✅', title: 'Creator accepted invite', desc: 'Ananya Gupta accepted the Holiday Glow campaign', time: '1 hour ago', unread: true },
          { icon: '📊', title: 'Campaign report ready', desc: 'Holiday Glow 2024 — Reach: 18.4M, ROI: 4.8x', time: '3 hours ago', unread: false },
          { icon: '💰', title: 'Payment processed', desc: 'Kavya Nair received ₹72,000', time: 'Yesterday', unread: false },
        ].map((n, i) => (
          <div key={i} className={`rounded-3xl p-4 border ${n.unread ? 'bg-[#FFF7F0] border-[#FDDCBE]' : 'bg-white border-[#F1E6DD]'}`}>
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 bg-[#FFF1E8] rounded-2xl flex items-center justify-center flex-shrink-0 text-xl">{n.icon}</div>
              <div className="flex-1">
                <p className="text-sm font-semibold text-[#111827]">{n.title}</p>
                <p className="text-xs text-[#6B7280] mt-0.5 leading-relaxed">{n.desc}</p>
                <p className="text-[10px] text-[#9CA3AF] mt-1.5">{n.time}</p>
              </div>
              {n.unread && <div className="w-2 h-2 bg-[#F97316] rounded-full mt-1 flex-shrink-0" />}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────
function BrandBottomNav({ screen, navigate, frameless = false }: { screen: string; navigate: (s: string) => void; frameless?: boolean }) {
  if (['splash', 'login', 'brand-onboarding'].includes(screen)) return null
  const tabs = [
    { id: 'dashboard', label: 'Home', icon: <Icon.Home /> },
    { id: 'campaigns', label: 'Campaigns', icon: <Icon.Briefcase /> },
    { id: 'discover', label: 'Discover', icon: <Icon.Search /> },
    { id: 'analytics', label: 'Analytics', icon: <Icon.Chart /> },
    { id: 'settings', label: 'Account', icon: <Icon.User /> },
  ]
  const active = tabs.find(t => screen.startsWith(t.id))?.id || 'dashboard'
  const pos = frameless ? 'sticky bottom-0' : 'fixed bottom-0 left-0 right-0'
  return (
    <div className={`${pos} bg-white/90 backdrop-blur-sm border-t border-[#F1E6DD]`}>
      <div className="flex px-2 pt-2 pb-3">
        {tabs.map(tab => (
          <button key={tab.id} onClick={() => navigate(tab.id)} className={`flex-1 flex flex-col items-center gap-1 py-1 rounded-xl transition-all ${active === tab.id ? 'text-[#F97316]' : 'text-[#9CA3AF]'}`}>
            <span className={active === tab.id ? 'scale-110 transition-transform' : ''}>{tab.icon}</span>
            <span className={`text-[10px] font-medium ${active === tab.id ? 'text-[#F97316]' : 'text-[#9CA3AF]'}`}>{tab.label}</span>
            {active === tab.id && <div className="w-1 h-1 bg-[#F97316] rounded-full" />}
          </button>
        ))}
      </div>
    </div>
  )
}

// ─── PHONE FRAME (embeddable) ─────────────────────────────────────────────────
export function BrandPhoneFrame({ onExit: _onExit }: { onExit: () => void }) {
  const [screen, setScreen] = useState('splash')
  const navigate = (s: string) => setScreen(s)

  const renderScreen = () => {
    switch (screen) {
      case 'splash': return <BrandSplash onNext={() => navigate('login')} />
      case 'login': return <BrandLogin onNext={() => navigate('brand-onboarding')} onSignup={() => navigate('brand-onboarding')} onCreatorLogin={() => navigate('dashboard')} />
      case 'brand-onboarding': return <BrandOnboarding onNext={() => navigate('dashboard')} />
      case 'dashboard': return <BrandDashboard navigate={navigate} />
      case 'campaigns': return <BrandCampaigns navigate={navigate} />
      case 'campaign-detail': return <CampaignDetail navigate={navigate} />
      case 'create-campaign': return <CreateCampaign navigate={navigate} />
      case 'discover': return <DiscoverCreators navigate={navigate} />
      case 'creator-profile': return <CreatorProfile navigate={navigate} />
      case 'analytics': return <BrandAnalyticsScreen navigate={navigate} />
      case 'messages': return <BrandMessages navigate={navigate} />
      case 'payments': return <BrandPaymentsScreen navigate={navigate} />
      case 'settings': return <BrandSettings navigate={navigate} />
      case 'notifications': return <BrandNotifications navigate={navigate} />
      case 'collections': return <Collections navigate={navigate} />
      default: return <BrandDashboard navigate={navigate} />
    }
  }

  return (
    <div className="relative" style={{ width: 390, height: 760 }}>
      <div className="absolute inset-0 rounded-[48px] border-[10px] border-[#1e293b] shadow-2xl overflow-hidden bg-[#FFFDFB]">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-7 bg-[#1e293b] rounded-b-2xl z-50" />
        <div className="w-full h-full overflow-hidden">
          <div key={screen} className="w-full h-full animate-fade-in">{renderScreen()}</div>
        </div>
      </div>
      <BrandBottomNav screen={screen} navigate={navigate} />
    </div>
  )
}

// Frameless version used by the single-app layout
export function BrandContent({ initialScreen = 'dashboard' }: { initialScreen?: string }) {
  const [screen, setScreen] = useState(initialScreen)
  const navigate = (s: string) => setScreen(s)

  const renderScreen = () => {
    switch (screen) {
      case 'dashboard': return <BrandDashboard navigate={navigate} />
      case 'campaigns': return <BrandCampaigns navigate={navigate} />
      case 'campaign-detail': return <CampaignDetail navigate={navigate} />
      case 'create-campaign': return <CreateCampaign navigate={navigate} />
      case 'discover': return <DiscoverCreators navigate={navigate} />
      case 'creator-profile': return <CreatorProfile navigate={navigate} />
      case 'analytics': return <BrandAnalyticsScreen navigate={navigate} />
      case 'messages': return <BrandMessages navigate={navigate} />
      case 'payments': return <BrandPaymentsScreen navigate={navigate} />
      case 'settings': return <BrandSettings navigate={navigate} />
      case 'notifications': return <BrandNotifications navigate={navigate} />
      case 'collections': return <Collections navigate={navigate} />
      default: return <BrandDashboard navigate={navigate} />
    }
  }

  return (
    <div className="flex flex-col w-full h-full bg-[#FFFDFB]">
      <div key={screen} className="flex-1 overflow-y-auto animate-fade-in frameless-content">{renderScreen()}</div>
      <BrandBottomNav screen={screen} navigate={navigate} frameless />
    </div>
  )
}

// ─── STANDALONE PAGE ──────────────────────────────────────────────────────────
function BrandAppPage({ onExit }: { onExit: () => void }) {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-[#0f172a] p-4">
      <div className="mb-4 flex items-center gap-4">
        <button onClick={onExit} className="text-white/60 hover:text-white text-sm flex items-center gap-1"><Icon.ChevronLeft /> Back to Portal</button>
        <span className="text-white/30">|</span>
        <span className="text-white/60 text-sm">Brand / Agency App</span>
      </div>
      <BrandPhoneFrame onExit={onExit} />
    </div>
  )
}

export default function BrandApp({ onExit }: { onExit: () => void }) {
  return <ToastProvider><BrandAppPage onExit={onExit} /></ToastProvider>
}

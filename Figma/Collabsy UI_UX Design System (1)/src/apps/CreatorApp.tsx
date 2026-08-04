import { useState } from 'react'
import { Button, Badge, Card, AICard, Avatar, ProgressBar, SearchBar, StatCard, SectionHeader, TabBar, Input, Toggle, Icon, Select } from '../components/ui'
import { ToastProvider, useToast } from '../components/ui/Toast'
import SmartLogin from '../components/SmartLogin'

// ─── INDIAN STATES DATA ─────────────────────────────────────────────────────
const STATES = ['Andhra Pradesh','Arunachal Pradesh','Assam','Bihar','Chhattisgarh','Goa','Gujarat','Haryana','Himachal Pradesh','Jharkhand','Karnataka','Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Odisha','Punjab','Rajasthan','Sikkim','Tamil Nadu','Telangana','Tripura','Uttar Pradesh','Uttarakhand','West Bengal','Delhi','Jammu & Kashmir','Ladakh','Puducherry','Chandigarh']

const _CATEGORIES = ['Fashion & Style','Beauty & Skincare','Food & Cooking','Travel','Fitness & Health','Technology','Gaming','Education','Entertainment','Lifestyle','Parenting','Finance','Art & Design','Music','Photography','Comedy','Sports','Sustainability']
void _CATEGORIES

// ─── SCREEN COMPONENTS ──────────────────────────────────────────────────────

function Splash({ onNext }: { onNext: () => void }) {
  return (
    <div className="flex flex-col items-center justify-center h-full bg-[#F97316] relative overflow-hidden px-8" onClick={onNext}>
      <div className="absolute inset-0" style={{ background: 'radial-gradient(ellipse at 30% 20%, #FB923C 0%, #F97316 40%, #EA580C 100%)' }} />
      <div className="absolute bottom-0 left-0 right-0 h-48 opacity-10" style={{ background: 'radial-gradient(ellipse at 50% 100%, white, transparent)' }} />
      <div className="relative z-10 flex flex-col items-center gap-4">
        <div className="w-24 h-24 bg-white/20 rounded-3xl flex items-center justify-center backdrop-blur-sm border border-white/30">
          <span className="text-4xl font-black text-white">C</span>
        </div>
        <h1 className="text-4xl font-black text-white tracking-tight">Collabsy</h1>
        <p className="text-white/80 text-base font-medium text-center">India's Premier AI-Powered<br/>Influencer Marketing Platform</p>
        <div className="mt-8 flex flex-col items-center gap-2 animate-pulse">
          <div className="w-8 h-1 bg-white/40 rounded-full" />
          <p className="text-white/60 text-sm">Tap anywhere to continue</p>
        </div>
      </div>
    </div>
  )
}

function Onboarding({ onNext }: { onNext: () => void }) {
  const [slide, setSlide] = useState(0)
  const slides = [
    { emoji: '🤝', title: 'Connect with Top Brands', desc: 'Get discovered by 5,000+ brands and agencies across India looking for authentic creators like you.' },
    { emoji: '🤖', title: 'AI-Powered Matching', desc: "Our AI analyzes your content and audience to match you with campaigns that resonate with your followers." },
    { emoji: '💰', title: 'Earn What You Deserve', desc: 'Get fair pricing recommendations, transparent payments, and real-time earnings tracking in one place.' },
  ]
  const s = slides[slide]
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] px-6 pt-12 pb-6">
      <div className="flex justify-end">
        <button onClick={onNext} className="text-sm text-[#6B7280] font-medium">Skip</button>
      </div>
      <div className="flex-1 flex flex-col items-center justify-center gap-8">
        <div className="w-40 h-40 bg-[#FFF1E8] rounded-full flex items-center justify-center">
          <span className="text-7xl">{s.emoji}</span>
        </div>
        <div className="text-center">
          <h2 className="text-2xl font-bold text-[#111827] mb-3">{s.title}</h2>
          <p className="text-[#6B7280] leading-relaxed">{s.desc}</p>
        </div>
      </div>
      <div className="flex flex-col gap-4">
        <div className="flex justify-center gap-2">
          {slides.map((_, i) => <div key={i} className={`h-2 rounded-full transition-all ${i === slide ? 'w-8 bg-[#F97316]' : 'w-2 bg-[#F1E6DD]'}`} />)}
        </div>
        <Button fullWidth size="lg" onClick={() => slide < 2 ? setSlide(s => s + 1) : onNext()}>
          {slide < 2 ? 'Continue' : 'Get Started'}
          <Icon.ArrowRight />
        </Button>
      </div>
    </div>
  )
}

function Login({ onNext, onSignup, onBrandLogin }: { onNext: () => void; onSignup: () => void; onBrandLogin?: () => void }) {
  return (
    <SmartLogin
      defaultTab="creator"
      onCreatorLogin={onNext}
      onBrandLogin={onBrandLogin ?? onNext}
      onCreatorSignup={onSignup}
      onBrandSignup={onSignup}
    />
  )
}

function Signup({ onNext }: { onNext: () => void }) {
  const [step, setStep] = useState(0)
  const [form, setForm] = useState({ name: '', email: '', phone: '', pass: '', state: '', city: '' })
  const update = (k: string, v: string) => setForm(f => ({ ...f, [k]: v }))
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] px-6 pt-14 pb-6">
      <button className="mb-6 text-[#6B7280] self-start" onClick={() => step > 0 ? setStep(s => s - 1) : null}><Icon.ChevronLeft /></button>
      <div className="mb-6">
        <div className="flex gap-1 mb-4">{[0,1,2].map(i => <div key={i} className={`flex-1 h-1 rounded-full ${i <= step ? 'bg-[#F97316]' : 'bg-[#F1E6DD]'}`} />)}</div>
        <h1 className="text-2xl font-bold text-[#111827]">{['Create account', 'Your location', 'Almost done'][step]}</h1>
        <p className="text-[#6B7280] mt-1 text-sm">{['Tell us about yourself', 'Help brands find you', 'Set your password'][step]}</p>
      </div>
      <div className="flex flex-col gap-4 flex-1">
        {step === 0 && <>
          <Input label="Full Name" placeholder="Priya Sharma" icon={<Icon.User />} value={form.name} onChange={e => update('name', e.target.value)} />
          <Input label="Email" type="email" placeholder="priya@example.com" icon={<Icon.Mail />} value={form.email} onChange={e => update('email', e.target.value)} />
          <Input label="Phone Number" type="tel" placeholder="+91 98765 43210" icon={<Icon.Phone />} value={form.phone} onChange={e => update('phone', e.target.value)} />
        </>}
        {step === 1 && <>
          <Select label="Country" options={[{ value: 'in', label: '🇮🇳 India' }]} />
          <Select label="State" options={STATES.map(s => ({ value: s, label: s }))} onChange={e => update('state', e.target.value)} />
          <Input label="City" placeholder="Mumbai" icon={<Icon.Map />} value={form.city} onChange={e => update('city', e.target.value)} />
        </>}
        {step === 2 && <>
          <Input label="Password" type="password" placeholder="Min 8 characters" icon={<Icon.Lock />} value={form.pass} onChange={e => update('pass', e.target.value)} />
          <Input label="Confirm Password" type="password" placeholder="Re-enter password" icon={<Icon.Lock />} />
          <p className="text-xs text-[#6B7280]">By creating an account, you agree to our <span className="text-[#F97316]">Terms of Service</span> and <span className="text-[#F97316]">Privacy Policy</span></p>
        </>}
      </div>
      <Button fullWidth size="lg" className="mt-4" onClick={() => step < 2 ? setStep(s => s + 1) : onNext()}>
        {step < 2 ? 'Continue' : 'Create Account'}
      </Button>
    </div>
  )
}

function OTPVerification({ onNext }: { onNext: () => void }) {
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] px-6 pt-14 pb-6 items-center">
      <div className="w-20 h-20 bg-[#FFF1E8] rounded-3xl flex items-center justify-center mb-6">
        <span className="text-4xl">📱</span>
      </div>
      <h1 className="text-2xl font-bold text-[#111827] mb-2">Verify your number</h1>
      <p className="text-[#6B7280] text-sm text-center mb-8">We've sent a 6-digit OTP to<br/><span className="font-semibold text-[#111827]">+91 98765 43210</span></p>
      <div className="flex gap-3 mb-8">
        {otp.map((v, i) => (
          <input key={i} maxLength={1} value={v}
            onChange={e => { const n = [...otp]; n[i] = e.target.value; setOtp(n) }}
            className="w-12 h-14 text-center text-xl font-bold border-2 rounded-2xl border-[#F1E6DD] focus:border-[#F97316] focus:outline-none bg-white text-[#111827]"
          />
        ))}
      </div>
      <Button fullWidth size="lg" onClick={onNext}>Verify OTP</Button>
      <p className="text-sm text-[#6B7280] mt-4">Didn't receive? <button className="text-[#F97316] font-semibold">Resend in 28s</button></p>
    </div>
  )
}

function AIOnboarding({ onNext }: { onNext: () => void }) {
  const [step, setStep] = useState(0)
  const steps = [
    { title: 'Connect Instagram', desc: 'Allow Collabsy to analyze your profile', icon: '📸' },
    { title: 'AI Analysis in progress', desc: "We're crunching your data...", icon: '🤖' },
    { title: 'Your AI Creator Score', desc: 'Based on 50+ signals', icon: '⭐' },
  ]
  const s = steps[step]
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] px-6 pt-14 pb-6">
      <div className="flex-1 flex flex-col items-center justify-center gap-6">
        {step === 0 && <>
          <div className="w-32 h-32 bg-gradient-to-br from-[#833AB4] via-[#FD1D1D] to-[#FCAF45] rounded-3xl flex items-center justify-center">
            <Icon.Instagram />
          </div>
          <div className="text-center">
            <h2 className="text-2xl font-bold text-[#111827] mb-2">{s.title}</h2>
            <p className="text-[#6B7280]">{s.desc}</p>
          </div>
          <Card className="w-full">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 bg-gradient-to-br from-[#833AB4] to-[#FCAF45] rounded-2xl flex items-center justify-center text-white font-bold">PS</div>
              <div>
                <p className="font-semibold text-[#111827]">@priya.sharma.in</p>
                <p className="text-sm text-[#6B7280]">248K Followers · Fashion</p>
              </div>
              <Badge variant="green" size="sm">Connected</Badge>
            </div>
          </Card>
          <div className="w-full space-y-2">
            {['Analyze content themes', 'Check audience quality', 'Detect engagement patterns', 'Verify follower authenticity'].map(item => (
              <div key={item} className="flex items-center gap-3 bg-[#F9FAFB] rounded-2xl p-3">
                <div className="w-5 h-5 bg-[#DCFCE7] rounded-full flex items-center justify-center"><Icon.Check /></div>
                <span className="text-sm text-[#374151]">{item}</span>
              </div>
            ))}
          </div>
        </>}
        {step === 1 && <>
          <div className="relative">
            <div className="w-32 h-32 rounded-full border-4 border-[#F97316] flex items-center justify-center animate-spin" style={{ borderTopColor: 'transparent' }} />
            <span className="absolute inset-0 flex items-center justify-center text-4xl">🤖</span>
          </div>
          <div className="text-center">
            <h2 className="text-xl font-bold text-[#111827]">Analyzing your profile</h2>
            <p className="text-[#6B7280] text-sm mt-1">This usually takes 20-30 seconds</p>
          </div>
          {['Scanning 1,240 posts', 'Analyzing 248K followers', 'Computing engagement rate', 'Building audience personas', 'Generating AI insights'].map((t, i) => (
            <div key={t} className="flex items-center gap-3 w-full">
              <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 ${i < 3 ? 'bg-[#DCFCE7]' : 'bg-[#F3F4F6]'}`}>
                {i < 3 ? <Icon.Check /> : <div className="w-2 h-2 bg-[#9CA3AF] rounded-full" />}
              </div>
              <span className={`text-sm ${i < 3 ? 'text-[#16A34A] font-medium' : 'text-[#9CA3AF]'}`}>{t}</span>
              {i === 3 && <div className="ml-auto w-4 h-4 border-2 border-[#F97316] border-t-transparent rounded-full animate-spin" />}
            </div>
          ))}
        </>}
        {step === 2 && <>
          <div className="relative w-full">
            <AICard title="Your AI Creator Score" subtitle="Powered by Collabsy AI">
              <div className="flex items-center gap-6 mt-2">
                <div className="relative w-24 h-24">
                  <svg width="96" height="96" className="-rotate-90">
                    <circle cx="48" cy="48" r="38" fill="none" stroke="#F1E6DD" strokeWidth="8" />
                    <circle cx="48" cy="48" r="38" fill="none" stroke="#F97316" strokeWidth="8" strokeLinecap="round" strokeDasharray="238.8" strokeDashoffset="45" />
                  </svg>
                  <div className="absolute inset-0 flex flex-col items-center justify-center">
                    <span className="text-2xl font-black text-[#111827]">81</span>
                    <span className="text-xs text-[#6B7280]">/100</span>
                  </div>
                </div>
                <div className="flex-1 space-y-2">
                  <ProgressBar label="Content Quality" value={88} showValue />
                  <ProgressBar label="Audience Auth." value={92} showValue color="#16A34A" />
                  <ProgressBar label="Engagement Rate" value={74} showValue color="#2563EB" />
                  <ProgressBar label="Brand Safety" value={96} showValue color="#7C3AED" />
                </div>
              </div>
            </AICard>
          </div>
          <div className="grid grid-cols-2 gap-3 w-full">
            <Card className="text-center"><p className="text-2xl font-bold text-[#F97316]">248K</p><p className="text-xs text-[#6B7280]">Followers</p></Card>
            <Card className="text-center"><p className="text-2xl font-bold text-[#16A34A]">6.2%</p><p className="text-xs text-[#6B7280]">Avg Engagement</p></Card>
            <Card className="text-center"><p className="text-2xl font-bold text-[#2563EB]">72%</p><p className="text-xs text-[#6B7280]">Female Audience</p></Card>
            <Card className="text-center"><p className="text-2xl font-bold text-[#7C3AED]">₹45K</p><p className="text-xs text-[#6B7280]">Suggested Rate</p></Card>
          </div>
        </>}
      </div>
      <Button fullWidth size="lg" onClick={() => step < 2 ? setStep(s => s + 1) : onNext()}>
        {step === 0 ? 'Analyze My Profile' : step === 1 ? 'View Results' : 'Start Creating'}
      </Button>
    </div>
  )
}

// ─── MAIN APP SCREENS ─────────────────────────────────────────────────────────

function Dashboard({ navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      {/* Header */}
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <Avatar src="https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80&h=80&fit=crop&auto=format" name="Priya Sharma" size="md" verified />
            <div>
              <p className="text-xs text-[#6B7280]">Good morning 👋</p>
              <p className="text-base font-bold text-[#111827]">Priya Sharma</p>
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={() => navigate('notifications')} className="w-10 h-10 bg-white rounded-2xl border border-[#F1E6DD] flex items-center justify-center relative">
              <Icon.Bell />
              <span className="absolute -top-1 -right-1 w-4 h-4 bg-[#F97316] rounded-full text-[9px] text-white flex items-center justify-center font-bold">3</span>
            </button>
            <button className="w-10 h-10 bg-white rounded-2xl border border-[#F1E6DD] flex items-center justify-center">
              <Icon.Message />
            </button>
          </div>
        </div>

        {/* AI Score Banner */}
        <AICard title="Your AI Creator Score" subtitle="Updated 2 hours ago">
          <div className="flex items-center gap-4">
            <div className="relative w-20 h-20 flex-shrink-0">
              <svg width="80" height="80" className="-rotate-90">
                <circle cx="40" cy="40" r="32" fill="none" stroke="#F1E6DD" strokeWidth="6" />
                <circle cx="40" cy="40" r="32" fill="none" stroke="#F97316" strokeWidth="6" strokeLinecap="round" strokeDasharray="201.1" strokeDashoffset="38" />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-xl font-black text-[#111827]">81</span>
                <span className="text-[9px] text-[#6B7280]">/100</span>
              </div>
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-1">
                <Badge variant="orange">Elite Creator</Badge>
                <Badge variant="green">Verified</Badge>
              </div>
              <p className="text-xs text-[#6B7280] mb-2">You're in top 8% of creators</p>
              <ProgressBar label="Profile completion" value={76} showValue />
            </div>
          </div>
        </AICard>
      </div>

      {/* Scrollable Content */}
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-5">
        {/* Quick Stats */}
        <div>
          <SectionHeader title="This Month" subtitle="Performance overview" />
          <div className="grid grid-cols-2 gap-3">
            <StatCard label="Earnings" value="₹1.2L" change="18% vs last month" positive icon={<Icon.DollarSign />} />
            <StatCard label="Campaigns" value="4 Active" change="2 new" positive icon={<Icon.Briefcase />} />
            <StatCard label="Reach" value="2.4M" change="12% growth" positive icon={<Icon.Eye />} color="#2563EB" />
            <StatCard label="Engagement" value="6.2%" change="0.3% drop" icon={<Icon.Heart />} color="#7C3AED" />
          </div>
        </div>

        {/* AI Recommendation */}
        <AICard title="AI Campaign Match" subtitle="3 new matches today">
          <p className="text-xs text-[#6B7280] mb-3">Based on your fashion & beauty niche and Mumbai audience</p>
          <div className="space-y-2">
            {[
              { brand: 'Nykaa', category: 'Beauty', budget: '₹50K', score: 94 },
              { brand: 'Myntra', category: 'Fashion', budget: '₹75K', score: 91 },
            ].map(c => (
              <div key={c.brand} className="flex items-center justify-between bg-white/80 rounded-2xl p-3">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 bg-[#F97316] rounded-xl flex items-center justify-center text-white font-bold text-sm">{c.brand[0]}</div>
                  <div>
                    <p className="text-sm font-semibold text-[#111827]">{c.brand}</p>
                    <p className="text-xs text-[#6B7280]">{c.category} · {c.budget}</p>
                  </div>
                </div>
                <div className="flex items-center gap-1">
                  <Badge variant="orange">{c.score}% match</Badge>
                </div>
              </div>
            ))}
          </div>
          <Button variant="secondary" fullWidth className="mt-3" size="sm" onClick={() => navigate('campaigns')}>View All Campaigns</Button>
        </AICard>

        {/* Active Campaigns */}
        <div>
          <SectionHeader title="Active Campaigns" action={<button onClick={() => navigate('campaigns')} className="text-xs text-[#F97316] font-semibold">See all</button>} />
          <div className="space-y-3">
            {[
              { brand: 'Boat Lifestyle', type: 'Instagram Reel', deadline: 'Due in 3 days', payment: '₹35,000', progress: 60, img: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=60&h=60&fit=crop&auto=format' },
              { brand: 'Sugar Cosmetics', type: 'Story + Post', deadline: 'Due in 7 days', payment: '₹22,000', progress: 30, img: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=60&h=60&fit=crop&auto=format' },
            ].map(c => (
              <Card key={c.brand} hover onClick={() => navigate('campaign-detail')}>
                <div className="flex gap-3">
                  <img src={c.img} alt={c.brand} className="w-12 h-12 rounded-2xl object-cover bg-[#F3F4F6]" />
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-1">
                      <p className="text-sm font-bold text-[#111827]">{c.brand}</p>
                      <Badge variant="green">{c.payment}</Badge>
                    </div>
                    <p className="text-xs text-[#6B7280] mb-2">{c.type} · {c.deadline}</p>
                    <ProgressBar value={c.progress} />
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div>
          <SectionHeader title="Quick Actions" />
          <div className="grid grid-cols-4 gap-3">
            {[
              { label: 'Apply', icon: <Icon.Briefcase />, color: '#F97316', screen: 'campaigns' },
              { label: 'Portfolio', icon: <Icon.Camera />, color: '#7C3AED', screen: 'portfolio' },
              { label: 'Analytics', icon: <Icon.Chart />, color: '#2563EB', screen: 'analytics' },
              { label: 'AI Tips', icon: <Icon.Sparkles />, color: '#16A34A', screen: 'ai-assistant' },
            ].map(a => (
              <button key={a.label} onClick={() => navigate(a.screen)} className="flex flex-col items-center gap-2 p-3 bg-white rounded-2xl border border-[#F1E6DD]">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: a.color + '15', color: a.color }}>{a.icon}</div>
                <span className="text-xs font-medium text-[#374151]">{a.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* AI Content Tips */}
        <AICard title="AI Growth Tips" subtitle="Personalized for you">
          <div className="space-y-2 mt-1">
            {[
              { tip: 'Post Reels between 7-9 PM for 40% more reach', tag: 'Timing' },
              { tip: 'Add trending audio to boost discovery by 60%', tag: 'Content' },
              { tip: 'Reply to comments in first hour for better ranking', tag: 'Engagement' },
            ].map((t, i) => (
              <div key={i} className="flex items-start gap-3 bg-white/70 rounded-2xl p-3">
                <div className="w-6 h-6 bg-[#F97316]/15 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Icon.Sparkles />
                </div>
                <div>
                  <Badge variant="orange" size="sm">{t.tag}</Badge>
                  <p className="text-xs text-[#374151] mt-1">{t.tip}</p>
                </div>
              </div>
            ))}
          </div>
        </AICard>
      </div>
    </div>
  )
}

function Campaigns({ navigate }: { navigate: (s: string) => void }) {
  const [tab, setTab] = useState(0)
  const [search, setSearch] = useState('')
  const campaigns = [
    { brand: 'Mamaearth', category: 'Skincare', budget: '₹40,000', type: 'Instagram Reel', deadline: 'Dec 20', match: 92, img: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=60&h=60&fit=crop&auto=format', status: 'open' },
    { brand: 'Zomato', category: 'Food & Lifestyle', budget: '₹60,000', type: 'Story Series', deadline: 'Dec 25', match: 88, img: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=60&h=60&fit=crop&auto=format', status: 'open' },
    { brand: 'Boat Lifestyle', category: 'Tech', budget: '₹35,000', type: 'YouTube Review', deadline: 'Dec 18', match: 79, img: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=60&h=60&fit=crop&auto=format', status: 'active' },
    { brand: 'Nykaa', category: 'Beauty', budget: '₹55,000', type: 'IG Post + Stories', deadline: 'Dec 28', match: 95, img: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=60&h=60&fit=crop&auto=format', status: 'applied' },
    { brand: 'Mivi Audio', category: 'Tech', budget: '₹28,000', type: 'Instagram Reel', deadline: 'Jan 5', match: 83, img: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=60&h=60&fit=crop&auto=format', status: 'open' },
    { brand: 'Fabindia', category: 'Fashion', budget: '₹45,000', type: 'Instagram Post', deadline: 'Jan 10', match: 91, img: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=60&h=60&fit=crop&auto=format', status: 'saved' },
  ]
  const tabs = ['Recommended', 'Active', 'Applied', 'Saved']
  const statusMap: Record<string, string> = { 'Recommended': 'open', 'Active': 'active', 'Applied': 'applied', 'Saved': 'saved' }
  const filtered = campaigns.filter(c => c.status === statusMap[tabs[tab]] || tabs[tab] === 'Recommended')

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Campaigns</h1>
          <button className="ml-auto w-9 h-9 bg-white rounded-xl border border-[#F1E6DD] flex items-center justify-center"><Icon.Filter /></button>
        </div>
        <SearchBar placeholder="Search campaigns..." value={search} onChange={setSearch} className="mb-4" />
        <TabBar tabs={tabs} active={tab} onChange={setTab} />
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-3">
        {filtered.map(c => (
          <Card key={c.brand} hover onClick={() => navigate('campaign-detail')}>
            <div className="flex gap-3">
              <img src={c.img} alt={c.brand} className="w-14 h-14 rounded-2xl object-cover bg-[#F3F4F6] flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between mb-1">
                  <p className="text-sm font-bold text-[#111827]">{c.brand}</p>
                  <Badge variant="orange">{c.match}% match</Badge>
                </div>
                <p className="text-xs text-[#6B7280] mb-1">{c.category} · {c.type}</p>
                <div className="flex items-center gap-3">
                  <span className="text-sm font-semibold text-[#F97316]">{c.budget}</span>
                  <span className="text-xs text-[#9CA3AF]">· Due {c.deadline}</span>
                </div>
              </div>
            </div>
            <div className="flex gap-2 mt-3 pt-3 border-t border-[#F9FAFB]">
              <Button variant="outline" size="sm" fullWidth><Icon.Bookmark /> Save</Button>
              <Button variant="primary" size="sm" fullWidth onClick={() => navigate('campaign-detail')}>View Details</Button>
            </div>
          </Card>
        ))}
      </div>
    </div>
  )
}

function CampaignDetail({ navigate }: { navigate: (s: string) => void }) {
  const [applied, setApplied] = useState(false)
  const [saved, setSaved] = useState(false)
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="relative">
        <img src="https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400&h=200&fit=crop&auto=format" alt="Campaign" className="w-full h-48 object-cover bg-[#F3F4F6]" />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent to-black/40" />
        <button onClick={() => navigate('campaigns')} className="absolute top-12 left-5 w-9 h-9 bg-white/80 backdrop-blur-sm rounded-xl flex items-center justify-center">
          <Icon.ChevronLeft />
        </button>
        <button onClick={() => setSaved(!saved)} className={`absolute top-12 right-5 w-9 h-9 rounded-xl flex items-center justify-center ${saved ? 'bg-[#F97316]' : 'bg-white/80 backdrop-blur-sm'}`}>
          <span className={saved ? 'text-white' : 'text-[#6B7280]'}><Icon.Bookmark /></span>
        </button>
      </div>
      <div className="flex-1 overflow-y-auto px-5 pt-4 pb-24 space-y-4">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="text-xl font-bold text-[#111827]">Mamaearth Holiday Campaign</h1>
            <p className="text-sm text-[#6B7280]">Mamaearth · Skincare</p>
          </div>
          <Badge variant="green">Open</Badge>
        </div>
        <div className="grid grid-cols-3 gap-2">
          <Card className="text-center p-3">
            <p className="text-lg font-bold text-[#F97316]">₹40K</p>
            <p className="text-[10px] text-[#6B7280]">Budget</p>
          </Card>
          <Card className="text-center p-3">
            <p className="text-lg font-bold text-[#111827]">Dec 20</p>
            <p className="text-[10px] text-[#6B7280]">Deadline</p>
          </Card>
          <Card className="text-center p-3">
            <p className="text-lg font-bold text-[#7C3AED]">92%</p>
            <p className="text-[10px] text-[#6B7280]">AI Match</p>
          </Card>
        </div>

        <AICard title="AI Brand Match Analysis" subtitle="Why this is a great fit">
          <div className="space-y-2 mt-1">
            <ProgressBar label="Audience overlap" value={87} showValue />
            <ProgressBar label="Content alignment" value={94} showValue color="#16A34A" />
            <ProgressBar label="Brand safety score" value={98} showValue color="#2563EB" />
          </div>
          <p className="text-xs text-[#6B7280] mt-3">💡 Your female audience (72%) matches Mamaearth's target demographic perfectly</p>
        </AICard>

        <Card>
          <h3 className="font-semibold text-[#111827] mb-3">Campaign Details</h3>
          <div className="space-y-3">
            {[
              { label: 'Deliverables', value: '2 Instagram Reels + 3 Stories' },
              { label: 'Duration', value: 'Dec 15 – Dec 20, 2024' },
              { label: 'Usage Rights', value: '6 months, non-exclusive' },
              { label: 'Payment Terms', value: '50% advance, 50% on delivery' },
              { label: 'Revisions', value: 'Up to 2 rounds' },
            ].map(d => (
              <div key={d.label} className="flex justify-between text-sm">
                <span className="text-[#6B7280]">{d.label}</span>
                <span className="font-medium text-[#111827] text-right max-w-[55%]">{d.value}</span>
              </div>
            ))}
          </div>
        </Card>

        <Card>
          <h3 className="font-semibold text-[#111827] mb-2">About the Brand</h3>
          <div className="flex items-center gap-3 mb-3">
            <div className="w-12 h-12 bg-[#FFF1E8] rounded-2xl flex items-center justify-center font-bold text-[#F97316]">M</div>
            <div>
              <p className="font-medium text-[#111827]">Mamaearth</p>
              <p className="text-xs text-[#6B7280]">4.8 ★ · 134 campaigns done</p>
            </div>
            <Badge variant="green">Verified Brand</Badge>
          </div>
          <p className="text-sm text-[#6B7280] leading-relaxed">India's leading toxin-free personal care brand. Known for fair, transparent creator partnerships and timely payments.</p>
        </Card>
      </div>
      <div className="fixed bottom-0 left-0 right-0 bg-white/90 backdrop-blur-sm border-t border-[#F1E6DD] p-5 pb-8">
        <Button fullWidth size="lg" onClick={() => setApplied(true)} className={applied ? 'opacity-60' : ''}>
          {applied ? <><Icon.Check /> Applied Successfully</> : 'Apply for Campaign'}
        </Button>
      </div>
    </div>
  )
}

function Portfolio({ navigate }: { navigate: (s: string) => void }) {
  const [tab, setTab] = useState(0)
  const photos = [
    'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=200&h=200&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1529139574466-a303027614b2?w=200&h=200&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=200&h=200&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=200&h=200&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=200&h=200&fit=crop&auto=format',
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=200&h=200&fit=crop&auto=format',
  ]
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">My Portfolio</h1>
          <button className="ml-auto"><Icon.Upload /></button>
        </div>
        <div className="flex items-center gap-4 mb-5">
          <Avatar src="https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80&h=80&fit=crop&auto=format" name="Priya Sharma" size="xl" verified />
          <div>
            <h2 className="text-lg font-bold text-[#111827]">Priya Sharma</h2>
            <p className="text-sm text-[#6B7280]">Fashion & Lifestyle Creator</p>
            <div className="flex gap-2 mt-1">
              <Badge variant="orange">Fashion</Badge>
              <Badge variant="purple">Beauty</Badge>
            </div>
          </div>
        </div>
        <div className="grid grid-cols-3 gap-0.5 mb-4 bg-[#F3F4F6] rounded-2xl p-0.5">
          {[['248K', 'Followers'], ['6.2%', 'Engagement'], ['2.4M', 'Reach/Mo']].map(([val, lbl]) => (
            <div key={lbl} className="text-center py-3 bg-white first:rounded-l-xl last:rounded-r-xl">
              <p className="text-lg font-bold text-[#111827]">{val}</p>
              <p className="text-xs text-[#6B7280]">{lbl}</p>
            </div>
          ))}
        </div>
        <TabBar tabs={['Photos', 'Videos', 'Collabs', 'Media Kit']} active={tab} onChange={setTab} />
      </div>
      <div className="flex-1 overflow-y-auto pb-24">
        {tab === 0 && (
          <div className="grid grid-cols-3 gap-0.5 px-0.5">
            {photos.map((p, i) => (
              <div key={i} className="aspect-square bg-[#F3F4F6]">
                <img src={p} alt="Post" className="w-full h-full object-cover" />
              </div>
            ))}
          </div>
        )}
        {tab === 2 && (
          <div className="px-5 space-y-3 pt-2">
            {[
              { brand: 'Nykaa', type: 'Skincare Campaign', date: 'Nov 2024', earnings: '₹55,000' },
              { brand: 'Myntra', type: 'Fashion Week', date: 'Oct 2024', earnings: '₹75,000' },
              { brand: 'Sugar Cosmetics', type: 'Launch Campaign', date: 'Sep 2024', earnings: '₹30,000' },
            ].map(c => (
              <Card key={c.brand} className="flex items-center gap-3">
                <div className="w-12 h-12 bg-[#FFF1E8] rounded-2xl flex items-center justify-center font-bold text-[#F97316]">{c.brand[0]}</div>
                <div className="flex-1">
                  <p className="font-semibold text-[#111827]">{c.brand}</p>
                  <p className="text-xs text-[#6B7280]">{c.type} · {c.date}</p>
                </div>
                <span className="text-sm font-bold text-[#16A34A]">{c.earnings}</span>
              </Card>
            ))}
          </div>
        )}
        {tab === 3 && (
          <div className="px-5 pt-2">
            <AICard title="AI Media Kit" subtitle="Auto-generated from your data" className="mb-4">
              <p className="text-xs text-[#6B7280] mb-3">Share this with brands to get direct collaboration requests</p>
              <Button variant="primary" fullWidth size="sm"><Icon.Download /> Download PDF</Button>
            </AICard>
            <Card>
              <h3 className="font-semibold text-[#111827] mb-3">Rate Card</h3>
              <div className="space-y-3">
                {[
                  { type: 'Instagram Reel', rate: '₹45,000–60,000' },
                  { type: 'Instagram Post', rate: '₹20,000–35,000' },
                  { type: 'Instagram Story (5)', rate: '₹15,000–25,000' },
                  { type: 'YouTube Video', rate: '₹80,000–1,20,000' },
                  { type: 'YouTube Short', rate: '₹30,000–45,000' },
                ].map(r => (
                  <div key={r.type} className="flex justify-between text-sm border-b border-[#F9FAFB] pb-2 last:border-0">
                    <span className="text-[#6B7280]">{r.type}</span>
                    <span className="font-semibold text-[#111827]">{r.rate}</span>
                  </div>
                ))}
              </div>
            </Card>
          </div>
        )}
      </div>
    </div>
  )
}

function Analytics({ navigate }: { navigate: (s: string) => void }) {
  const [period, setPeriod] = useState(0)
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Analytics</h1>
        </div>
        <TabBar tabs={['7D', '30D', '3M', '1Y']} active={period} onChange={setPeriod} />
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-4">
        {/* Chart Placeholder */}
        <Card>
          <SectionHeader title="Follower Growth" subtitle="+12,400 this month" />
          <div className="h-40 flex items-end gap-1.5">
            {[40,55,45,70,65,80,75,90,85,95,88,100].map((h, i) => (
              <div key={i} className="flex-1 rounded-t-lg transition-all" style={{ height: `${h}%`, background: i === 11 ? '#F97316' : '#FFF1E8' }} />
            ))}
          </div>
          <div className="flex justify-between text-xs text-[#9CA3AF] mt-2">
            <span>Jun</span><span>Jul</span><span>Aug</span><span>Sep</span><span>Oct</span><span>Nov</span>
          </div>
        </Card>

        <div className="grid grid-cols-2 gap-3">
          <StatCard label="Followers" value="248K" change="+4.2% this month" positive icon={<Icon.Users />} />
          <StatCard label="Avg Reach" value="2.4M" change="+12% growth" positive icon={<Icon.Eye />} color="#2563EB" />
          <StatCard label="Engagement" value="6.2%" change="-0.3%" icon={<Icon.Heart />} color="#7C3AED" />
          <StatCard label="Saves" value="18.4K" change="+22%" positive icon={<Icon.Bookmark />} color="#16A34A" />
        </div>

        {/* Audience Demographics */}
        <Card>
          <SectionHeader title="Audience Demographics" />
          <div className="space-y-3">
            <div>
              <p className="text-xs font-medium text-[#6B7280] mb-2">Gender Split</p>
              <div className="flex rounded-full overflow-hidden h-4">
                <div className="bg-[#F97316] h-full transition-all" style={{ width: '72%' }} />
                <div className="bg-[#DBEAFE] h-full flex-1" />
              </div>
              <div className="flex justify-between text-xs mt-1">
                <span className="text-[#F97316] font-medium">Female 72%</span>
                <span className="text-[#2563EB] font-medium">Male 28%</span>
              </div>
            </div>
            <div>
              <p className="text-xs font-medium text-[#6B7280] mb-2">Age Groups</p>
              {[['18–24', 38], ['25–34', 44], ['35–44', 12], ['45+', 6]].map(([age, pct]) => (
                <div key={age as string} className="flex items-center gap-3 mb-1.5">
                  <span className="text-xs w-12 text-[#6B7280]">{age}</span>
                  <div className="flex-1 h-2 bg-[#F3F4F6] rounded-full overflow-hidden">
                    <div className="h-full bg-[#F97316] rounded-full" style={{ width: `${pct}%` }} />
                  </div>
                  <span className="text-xs font-medium text-[#374151] w-8 text-right">{pct}%</span>
                </div>
              ))}
            </div>
          </div>
        </Card>

        {/* Top Cities */}
        <Card>
          <SectionHeader title="Top Cities" />
          <div className="space-y-2">
            {[['Mumbai', 28], ['Delhi', 22], ['Bengaluru', 18], ['Pune', 11], ['Hyderabad', 9]].map(([city, pct], i) => (
              <div key={city as string} className="flex items-center gap-3">
                <span className="text-xs font-bold text-[#9CA3AF] w-4">{i + 1}</span>
                <span className="text-sm text-[#374151] flex-1">{city}</span>
                <div className="w-24 h-1.5 bg-[#F3F4F6] rounded-full overflow-hidden">
                  <div className="h-full bg-[#F97316] rounded-full" style={{ width: `${pct as number * 3.5}%` }} />
                </div>
                <span className="text-xs font-medium text-[#374151] w-8 text-right">{pct}%</span>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  )
}

function Wallet({ navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-5">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Wallet</h1>
        </div>
        <div className="rounded-3xl p-6 text-white mb-4 relative overflow-hidden" style={{ background: 'linear-gradient(135deg, #F97316 0%, #EA580C 100%)' }}>
          <div className="absolute top-0 right-0 w-32 h-32 opacity-10 rounded-full" style={{ background: 'white', transform: 'translate(30%, -30%)' }} />
          <p className="text-white/80 text-sm mb-1">Total Earnings</p>
          <p className="text-4xl font-black mb-1">₹1,24,500</p>
          <p className="text-white/70 text-sm">Available: <span className="text-white font-semibold">₹84,500</span></p>
          <div className="flex gap-3 mt-4">
            <Button variant="secondary" size="sm" className="bg-white/20 text-white border-white/20 hover:bg-white/30">
              <Icon.Download /> Withdraw
            </Button>
            <Button variant="secondary" size="sm" className="bg-white/20 text-white border-white/20 hover:bg-white/30">
              <Icon.FileText /> Invoice
            </Button>
          </div>
        </div>
        <div className="grid grid-cols-3 gap-3">
          {[['Pending', '₹25,000', 'orange'], ['This Month', '₹42,000', 'green'], ['Total Paid', '₹57,500', 'blue']].map(([lbl, val, color]) => (
            <Card key={lbl as string} className="text-center p-3">
              <p className={`text-sm font-bold text-[${color === 'orange' ? '#F97316' : color === 'green' ? '#16A34A' : '#2563EB'}]`}>{val}</p>
              <p className="text-[10px] text-[#6B7280] mt-0.5">{lbl}</p>
            </Card>
          ))}
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-3">
        <SectionHeader title="Recent Transactions" />
        {[
          { brand: 'Mamaearth', amount: '+₹20,000', type: 'Advance Payment', date: 'Dec 10', status: 'credit' },
          { brand: 'Boat Lifestyle', amount: '+₹35,000', type: 'Campaign Payout', date: 'Dec 5', status: 'credit' },
          { brand: 'Withdrawal', amount: '-₹40,000', type: 'Bank Transfer', date: 'Dec 1', status: 'debit' },
          { brand: 'Sugar Cosmetics', amount: '+₹22,000', type: 'Final Payment', date: 'Nov 28', status: 'credit' },
          { brand: 'TDS Deduction', amount: '-₹2,200', type: 'Tax (10%)', date: 'Nov 28', status: 'debit' },
        ].map((t, i) => (
          <Card key={i} className="flex items-center gap-3 p-4">
            <div className={`w-10 h-10 rounded-2xl flex items-center justify-center ${t.status === 'credit' ? 'bg-[#DCFCE7]' : 'bg-[#FEE2E2]'}`}>
              {t.status === 'credit' ? <Icon.TrendUp /> : <Icon.Download />}
            </div>
            <div className="flex-1">
              <p className="text-sm font-semibold text-[#111827]">{t.brand}</p>
              <p className="text-xs text-[#6B7280]">{t.type} · {t.date}</p>
            </div>
            <span className={`text-sm font-bold ${t.status === 'credit' ? 'text-[#16A34A]' : 'text-[#DC2626]'}`}>{t.amount}</span>
          </Card>
        ))}
      </div>
    </div>
  )
}

function AIAssistant({ navigate }: { navigate: (s: string) => void }) {
  const [tab, setTab] = useState(0)
  const [prompt, setPrompt] = useState('')
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">AI Assistant</h1>
          <div className="ml-auto w-8 h-8 bg-[#F97316] rounded-xl flex items-center justify-center">
            <Icon.Sparkles />
          </div>
        </div>
        <TabBar tabs={['Insights', 'Captions', 'Growth']} active={tab} onChange={setTab} />
      </div>
      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-4">
        {tab === 0 && <>
          <AICard title="Performance Prediction" subtitle="Next 30 days forecast">
            <div className="grid grid-cols-3 gap-2 mt-2">
              {[['Reach', '2.8M', '+17%'], ['Followers', '+8,200', '+3.4%'], ['Engagement', '6.8%', '+0.6%']].map(([lbl, val, chg]) => (
                <div key={lbl} className="bg-white/70 rounded-2xl p-2.5 text-center">
                  <p className="text-sm font-bold text-[#111827]">{val}</p>
                  <p className="text-[10px] text-[#16A34A] font-medium">{chg}</p>
                  <p className="text-[10px] text-[#6B7280]">{lbl}</p>
                </div>
              ))}
            </div>
          </AICard>

          <AICard title="Best Posting Times" subtitle="Optimized for your audience">
            <div className="space-y-2 mt-1">
              {[{ day: 'Weekdays', times: ['7 AM', '12 PM', '7 PM'], best: '7 PM' }, { day: 'Weekends', times: ['10 AM', '2 PM', '8 PM'], best: '10 AM' }].map(d => (
                <div key={d.day} className="bg-white/70 rounded-2xl p-3">
                  <p className="text-xs font-semibold text-[#374151] mb-2">{d.day}</p>
                  <div className="flex gap-2">
                    {d.times.map(t => (
                      <span key={t} className={`px-2.5 py-1 rounded-xl text-xs font-medium ${t === d.best ? 'bg-[#F97316] text-white' : 'bg-[#F3F4F6] text-[#6B7280]'}`}>{t}</span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </AICard>

          <AICard title="Pricing Recommendation" subtitle="Based on your metrics">
            <div className="space-y-2 mt-1">
              {[
                { type: 'Instagram Reel', min: '₹42K', max: '₹58K', current: '₹45K' },
                { type: 'Instagram Post', min: '₹18K', max: '₹32K', current: '₹20K' },
              ].map(p => (
                <div key={p.type} className="bg-white/70 rounded-2xl p-3">
                  <div className="flex justify-between mb-1">
                    <span className="text-xs font-medium text-[#374151]">{p.type}</span>
                    <span className="text-xs text-[#16A34A] font-semibold">Your rate: {p.current}</span>
                  </div>
                  <p className="text-xs text-[#6B7280]">Market range: {p.min} – {p.max}</p>
                </div>
              ))}
            </div>
          </AICard>
        </>}

        {tab === 1 && <>
          <Card>
            <h3 className="font-semibold text-[#111827] mb-3">Caption Generator</h3>
            <div className="flex flex-col gap-3">
              <Input placeholder="Describe your post (e.g. outfit at Bandra)" value={prompt} onChange={e => setPrompt(e.target.value)} />
              <Select label="Tone" options={[{ value: 'fun', label: 'Fun & Playful' }, { value: 'professional', label: 'Professional' }, { value: 'aesthetic', label: 'Aesthetic' }]} />
              <Button fullWidth><Icon.Sparkles /> Generate Caption</Button>
            </div>
          </Card>
          {['✨ Sunsets hit different in a good outfit. Wearing this stunning coord set from @fabindia – pure cotton, gorgeous prints, and so comfy! Tag me if you recreate this look 🧡 #FashionBlogger #IndianFashion #OOTD',
            '🌅 Magic hour in Mumbai with my favourite fit! This beautiful kurta from @fabindia has my whole heart. Sustainable, stylish, and so versatile! Shop the link in bio 💫',
          ].map((caption, i) => (
            <Card key={i}>
              <div className="flex justify-between items-start mb-2">
                <Badge variant={i === 0 ? 'orange' : 'gray'} size="sm">{i === 0 ? '⭐ Best Match' : 'Alternative'}</Badge>
                <button className="text-xs text-[#F97316] font-medium">Copy</button>
              </div>
              <p className="text-sm text-[#374151] leading-relaxed">{caption}</p>
            </Card>
          ))}
        </>}

        {tab === 2 && <>
          <AICard title="Growth Strategy" subtitle="AI-generated for your profile">
            <div className="space-y-3 mt-1">
              {[
                { title: 'Collaborate with micro-creators', impact: 'High', action: 'Find 3 creators in your niche with 50K–100K followers for collab Reels' },
                { title: 'Increase Reel frequency', impact: 'High', action: 'Post 5 Reels/week instead of 3 for 2x reach growth' },
                { title: 'Start a series', impact: 'Medium', action: '"Get ready with me" series drives 40% more saves & follows' },
              ].map((tip, i) => (
                <div key={i} className="bg-white/80 rounded-2xl p-3">
                  <div className="flex items-center justify-between mb-1">
                    <p className="text-sm font-semibold text-[#111827]">{tip.title}</p>
                    <Badge variant={tip.impact === 'High' ? 'orange' : 'blue'} size="sm">{tip.impact}</Badge>
                  </div>
                  <p className="text-xs text-[#6B7280] leading-relaxed">{tip.action}</p>
                </div>
              ))}
            </div>
          </AICard>
        </>}
      </div>
    </div>
  )
}

function Messages({ navigate }: { navigate: (s: string) => void }) {
  const [activeChat, setActiveChat] = useState<string | null>(null)
  const [message, setMessage] = useState('')
  const chats = [
    { brand: 'Mamaearth', last: "Can you confirm the shoot date?", time: '2m ago', unread: 2, img: '' },
    { brand: 'Sugar Cosmetics', last: 'Great work on the reel! 🎉', time: '1h ago', unread: 0, img: '' },
    { brand: 'Zomato Brand', last: 'Please review the brief we sent', time: '3h ago', unread: 1, img: '' },
    { brand: 'Myntra', last: 'Payment processed ✅', time: 'Yesterday', unread: 0, img: '' },
  ]
  if (activeChat) return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="flex items-center gap-3 px-5 pt-12 pb-4 border-b border-[#F1E6DD]">
        <button onClick={() => setActiveChat(null)}><Icon.ChevronLeft /></button>
        <div className="w-10 h-10 bg-[#FFF1E8] rounded-2xl flex items-center justify-center font-bold text-[#F97316]">{activeChat[0]}</div>
        <div>
          <p className="font-semibold text-[#111827] text-sm">{activeChat}</p>
          <p className="text-xs text-[#16A34A]">Online</p>
        </div>
        <div className="ml-auto flex gap-2">
          <button className="w-8 h-8 bg-[#F3F4F6] rounded-xl flex items-center justify-center"><Icon.Phone /></button>
          <button className="w-8 h-8 bg-[#F3F4F6] rounded-xl flex items-center justify-center"><Icon.MoreHorizontal /></button>
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3">
        {[
          { from: 'brand', text: "Hi Priya! We'd love to collaborate with you for our holiday campaign.", time: '10:30 AM' },
          { from: 'me', text: "Hi! Thank you so much. I'd love to know more about the campaign details.", time: '10:32 AM' },
          { from: 'brand', text: 'We need 2 Reels featuring our new skincare range. Budget is ₹40,000. Does that work?', time: '10:35 AM' },
          { from: 'me', text: "That sounds great! Could we discuss the timeline? I'm available from Dec 15–18.", time: '10:38 AM' },
          { from: 'brand', text: 'Perfect! Can you confirm the shoot date?', time: '10:40 AM' },
        ].map((msg, i) => (
          <div key={i} className={`flex ${msg.from === 'me' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-[75%] px-4 py-3 rounded-2xl text-sm ${msg.from === 'me' ? 'bg-[#F97316] text-white rounded-br-sm' : 'bg-white border border-[#F1E6DD] text-[#111827] rounded-bl-sm'}`}>
              <p>{msg.text}</p>
              <p className={`text-[10px] mt-1 ${msg.from === 'me' ? 'text-white/70' : 'text-[#9CA3AF]'}`}>{msg.time}</p>
            </div>
          </div>
        ))}
      </div>
      <div className="px-4 py-3 bg-white border-t border-[#F1E6DD] flex gap-2 items-center">
        <button className="w-9 h-9 bg-[#F3F4F6] rounded-xl flex items-center justify-center flex-shrink-0"><Icon.Upload /></button>
        <input value={message} onChange={e => setMessage(e.target.value)} placeholder="Type a message..." className="flex-1 bg-[#F9FAFB] rounded-2xl px-4 py-2.5 text-sm border border-[#F1E6DD] focus:outline-none focus:border-[#F97316]" />
        <button className="w-9 h-9 bg-[#F97316] rounded-xl flex items-center justify-center flex-shrink-0 text-white"><Icon.ArrowRight /></button>
      </div>
    </div>
  )
  return (
    <div className="flex flex-col h-full bg-[#FFFDFB]">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-4">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Messages</h1>
        </div>
        <SearchBar placeholder="Search conversations..." />
      </div>
      <div className="flex-1 overflow-y-auto divide-y divide-[#F9FAFB]">
        {chats.map(chat => (
          <button key={chat.brand} onClick={() => setActiveChat(chat.brand)} className="w-full flex items-center gap-3 px-5 py-4 hover:bg-[#F9FAFB] text-left">
            <div className="w-12 h-12 bg-[#FFF1E8] rounded-2xl flex items-center justify-center font-bold text-[#F97316] flex-shrink-0">{chat.brand[0]}</div>
            <div className="flex-1 min-w-0">
              <div className="flex justify-between">
                <p className="font-semibold text-[#111827] text-sm">{chat.brand}</p>
                <p className="text-xs text-[#9CA3AF]">{chat.time}</p>
              </div>
              <p className="text-xs text-[#6B7280] truncate mt-0.5">{chat.last}</p>
            </div>
            {chat.unread > 0 && <span className="w-5 h-5 bg-[#F97316] rounded-full text-[10px] text-white flex items-center justify-center font-bold flex-shrink-0">{chat.unread}</span>}
          </button>
        ))}
      </div>
    </div>
  )
}

function Notifications({ navigate }: { navigate: (s: string) => void }) {
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
          { icon: '🎉', title: 'Campaign Approved!', desc: 'Your application for Mamaearth campaign was approved', time: '2 min ago', unread: true, type: 'success' },
          { icon: '💰', title: 'Payment Received', desc: 'Boat Lifestyle sent ₹35,000 to your wallet', time: '1 hour ago', unread: true, type: 'payment' },
          { icon: '🤖', title: 'AI Insight Ready', desc: 'Your weekly performance analysis is ready to view', time: '3 hours ago', unread: true, type: 'ai' },
          { icon: '📩', title: 'New Campaign Invite', desc: 'Zomato invited you to their Food Festival campaign', time: '5 hours ago', unread: false, type: 'campaign' },
          { icon: '⭐', title: 'Score Updated', desc: 'Your AI Creator Score improved from 79 to 81', time: 'Yesterday', unread: false, type: 'score' },
          { icon: '💬', title: 'New Message', desc: 'Sugar Cosmetics sent you a message', time: 'Yesterday', unread: false, type: 'message' },
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

function SettingsModal({ title, onClose, children }: { title: string; onClose: () => void; children: React.ReactNode }) {
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

function Settings({ navigate }: { navigate: (s: string) => void }) {
  const [notifications, setNotifications] = useState(true)
  const [emailAlerts, setEmailAlerts] = useState(true)
  const [twoFA, setTwoFA] = useState(false)
  const [igConnected, setIgConnected] = useState(true)
  const [ytConnected, setYtConnected] = useState(false)
  const [modal, setModal] = useState<string|null>(null)
  const [name, setName] = useState('Priya Sharma')
  const [handle, setHandle] = useState('@priya.sharma.in')
  const [bio, setBio] = useState('Lifestyle & beauty creator 🌸 Mumbai')
  const [curPwd, setCurPwd] = useState('')
  const [newPwd, setNewPwd] = useState('')
  const [confPwd, setConfPwd] = useState('')
  const toast = useToast()

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] relative">
      <div className="px-5 pt-12 pb-4">
        <div className="flex items-center gap-3 mb-5">
          <button onClick={() => navigate('dashboard')}><Icon.ChevronLeft /></button>
          <h1 className="text-xl font-bold text-[#111827]">Settings</h1>
        </div>
        <div className="flex items-center gap-3 bg-white rounded-3xl p-4 border border-[#F1E6DD] mb-5" style={{ boxShadow: '0 4px 16px rgba(0,0,0,0.06)' }}>
          <Avatar src="https://images.unsplash.com/photo-1494790108755-2616b612b786?w=80&h=80&fit=crop&auto=format" name="Priya Sharma" size="lg" verified />
          <div className="flex-1">
            <p className="font-bold text-[#111827]">{name}</p>
            <p className="text-sm text-[#6B7280]">{handle}</p>
            <Badge variant="orange">Elite Creator</Badge>
          </div>
          <button onClick={() => setModal('profile')} className="w-9 h-9 bg-[#F3F4F6] rounded-xl flex items-center justify-center"><Icon.ChevronRight /></button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-24 space-y-4">
        {[
          { section: 'Account', items: [
            { icon: <Icon.User />, label: 'Edit Profile', action: () => setModal('profile') },
            { icon: <Icon.Instagram />, label: 'Connected Accounts', action: () => setModal('accounts') },
          ]},
          { section: 'Notifications', items: [
            { icon: <Icon.Bell />, label: 'Push Notifications', toggle: true, value: notifications, onToggle: setNotifications },
            { icon: <Icon.Mail />, label: 'Email Alerts', toggle: true, value: emailAlerts, onToggle: setEmailAlerts },
          ]},
          { section: 'Privacy & Security', items: [
            { icon: <Icon.Shield />, label: 'Two-Factor Auth', toggle: true, value: twoFA, onToggle: setTwoFA },
            { icon: <Icon.Lock />, label: 'Change Password', action: () => setModal('password') },
          ]},
          { section: 'Support', items: [
            { icon: <Icon.Info />, label: 'Help Center', action: () => setModal('help') },
            { icon: <Icon.FileText />, label: 'Terms & Privacy', action: () => setModal('terms') },
            { icon: <Icon.LogOut />, label: 'Log Out', danger: true, action: () => navigate('splash') },
          ]},
        ].map(group => (
          <div key={group.section}>
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
        <SettingsModal title="Edit Profile" onClose={() => setModal(null)}>
          <div className="space-y-3">
            <Input label="Full Name" value={name} onChange={e => setName(e.target.value)} />
            <Input label="Username / Handle" value={handle} onChange={e => setHandle(e.target.value)} />
            <div>
              <label className="text-xs font-semibold text-[#374151] mb-1 block">Bio</label>
              <textarea value={bio} onChange={e => setBio(e.target.value)} rows={3}
                className="w-full border border-[#E5E7EB] rounded-2xl px-4 py-3 text-sm text-[#374151] focus:outline-none focus:border-[#F97316] resize-none" />
            </div>
            <Button fullWidth onClick={() => { toast('Profile updated!', 'success'); setModal(null) }}>Save Changes</Button>
          </div>
        </SettingsModal>
      )}

      {modal === 'accounts' && (
        <SettingsModal title="Connected Accounts" onClose={() => setModal(null)}>
          <div className="space-y-3">
            {[
              { name: 'Instagram', handle: '@priya.sharma.in', color: '#E1306C', state: igConnected, set: setIgConnected },
              { name: 'YouTube', handle: 'Priya Sharma', color: '#FF0000', state: ytConnected, set: setYtConnected },
            ].map(acc => (
              <div key={acc.name} className="flex items-center gap-3 p-3 bg-[#F9FAFB] rounded-2xl">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center text-white font-bold text-sm" style={{ background: acc.color }}>{acc.name[0]}</div>
                <div className="flex-1">
                  <p className="text-sm font-semibold text-[#111827]">{acc.name}</p>
                  <p className="text-xs text-[#6B7280]">{acc.state ? acc.handle : 'Not connected'}</p>
                </div>
                <Toggle checked={acc.state} onChange={acc.set} />
              </div>
            ))}
            <Button fullWidth variant="outline" onClick={() => { toast('Connect more accounts coming soon', 'info'); setModal(null) }}>+ Add Account</Button>
          </div>
        </SettingsModal>
      )}

      {modal === 'password' && (
        <SettingsModal title="Change Password" onClose={() => setModal(null)}>
          <div className="space-y-3">
            <Input label="Current Password" type="password" value={curPwd} onChange={e => setCurPwd(e.target.value)} placeholder="Enter current password" />
            <Input label="New Password" type="password" value={newPwd} onChange={e => setNewPwd(e.target.value)} placeholder="Min 8 characters" />
            <Input label="Confirm New Password" type="password" value={confPwd} onChange={e => setConfPwd(e.target.value)} placeholder="Re-enter new password" />
            <Button fullWidth onClick={() => {
              if (newPwd.length < 8) { toast('Password must be at least 8 characters', 'error'); return }
              if (newPwd !== confPwd) { toast("Passwords don't match", 'error'); return }
              toast('Password changed successfully!', 'success'); setModal(null)
              setCurPwd(''); setNewPwd(''); setConfPwd('')
            }}>Update Password</Button>
          </div>
        </SettingsModal>
      )}


      {modal === 'help' && (
        <SettingsModal title="Help Center" onClose={() => setModal(null)}>
          <div className="space-y-3">
            {[['How do I get brand deals?','Browse Campaigns tab and apply directly, or brands find you through Discover.'],['When do I get paid?','Payments are released within 7 days of content approval.'],['How is my rate calculated?','Based on followers, engagement rate, niche, and past campaign performance.'],['Can I decline a campaign?','Yes, you can decline any campaign offer with no penalty.']].map(([q, a]) => (
              <div key={q} className="p-3 bg-[#F9FAFB] rounded-2xl">
                <p className="text-sm font-semibold text-[#111827]">{q}</p>
                <p className="text-xs text-[#6B7280] mt-1">{a}</p>
              </div>
            ))}
            <Button fullWidth variant="outline" onClick={() => { toast('Support chat coming soon', 'info') }}>Chat with Support</Button>
          </div>
        </SettingsModal>
      )}

      {modal === 'terms' && (
        <SettingsModal title="Terms & Privacy" onClose={() => setModal(null)}>
          <div className="space-y-3 text-xs text-[#6B7280] leading-relaxed">
            <p className="font-semibold text-[#374151]">Terms of Service</p>
            <p>By using Collabsy, you agree to our terms. You are responsible for the content you publish and must ensure all brand guidelines are followed during campaigns.</p>
            <p className="font-semibold text-[#374151]">Privacy Policy</p>
            <p>We collect usage data to improve platform experience. Your personal data is never sold to third parties. You can request data deletion at any time from this settings page.</p>
            <p className="font-semibold text-[#374151]">Creator Agreement</p>
            <p>Campaign fees are subject to 10% platform commission. Payments are processed via direct bank transfer within 7 business days of content approval.</p>
            <Button fullWidth variant="outline" onClick={() => toast('Full policy sent to your email', 'info')}>Email Full Policy</Button>
          </div>
        </SettingsModal>
      )}
    </div>
  )
}

// ─── BOTTOM NAVIGATION ────────────────────────────────────────────────────────
function BottomNav({ screen, navigate, frameless = false }: { screen: string; navigate: (s: string) => void; frameless?: boolean }) {
  const authScreens = ['splash', 'onboarding', 'login', 'signup', 'otp', 'ai-onboarding']
  if (authScreens.includes(screen)) return null
  const tabs = [
    { id: 'dashboard', label: 'Home', icon: <Icon.Home /> },
    { id: 'campaigns', label: 'Campaigns', icon: <Icon.Briefcase /> },
    { id: 'analytics', label: 'Analytics', icon: <Icon.Chart /> },
    { id: 'messages', label: 'Messages', icon: <Icon.Message /> },
    { id: 'settings', label: 'Profile', icon: <Icon.User /> },
  ]
  const active = tabs.find(t => screen.startsWith(t.id))?.id || 'dashboard'
  const pos = frameless ? 'sticky bottom-0' : 'fixed bottom-0 left-0 right-0'
  return (
    <div className={`${pos} bg-white/90 backdrop-blur-sm border-t border-[#F1E6DD]`}>
      <div className="flex px-2 pt-2 pb-3">
        {tabs.map(tab => (
          <button key={tab.id} onClick={() => navigate(tab.id)} className={`flex-1 flex flex-col items-center gap-1 py-1 rounded-xl transition-all ${active === tab.id ? 'text-[#F97316]' : 'text-[#9CA3AF]'}`}>
            <span className={active === tab.id ? 'scale-110' : ''}>{tab.icon}</span>
            <span className={`text-[10px] font-medium ${active === tab.id ? 'text-[#F97316]' : 'text-[#9CA3AF]'}`}>{tab.label}</span>
            {active === tab.id && <div className="w-1 h-1 bg-[#F97316] rounded-full" />}
          </button>
        ))}
      </div>
    </div>
  )
}

// ─── PHONE FRAME (embeddable) ─────────────────────────────────────────────────
export function CreatorPhoneFrame({ onExit: _onExit }: { onExit: () => void }) {
  const [screen, setScreen] = useState('splash')
  const navigate = (s: string) => setScreen(s)

  const renderScreen = () => {
    switch (screen) {
      case 'splash': return <Splash onNext={() => navigate('onboarding')} />
      case 'onboarding': return <Onboarding onNext={() => navigate('login')} />
      case 'login': return <Login onNext={() => navigate('dashboard')} onSignup={() => navigate('signup')} onBrandLogin={() => navigate('dashboard')} />
      case 'signup': return <Signup onNext={() => navigate('otp')} />
      case 'otp': return <OTPVerification onNext={() => navigate('ai-onboarding')} />
      case 'ai-onboarding': return <AIOnboarding onNext={() => navigate('dashboard')} />
      case 'dashboard': return <Dashboard navigate={navigate} />
      case 'campaigns': return <Campaigns navigate={navigate} />
      case 'campaign-detail': return <CampaignDetail navigate={navigate} />
      case 'portfolio': return <Portfolio navigate={navigate} />
      case 'analytics': return <Analytics navigate={navigate} />
      case 'wallet': return <Wallet navigate={navigate} />
      case 'ai-assistant': return <AIAssistant navigate={navigate} />
      case 'messages': return <Messages navigate={navigate} />
      case 'notifications': return <Notifications navigate={navigate} />
      case 'settings': return <Settings navigate={navigate} />
      default: return <Dashboard navigate={navigate} />
    }
  }

  return (
    <div className="relative" style={{ width: 390, height: 760 }}>
      <div className="absolute inset-0 rounded-[48px] border-[10px] border-[#2a2a3e] shadow-2xl overflow-hidden bg-[#FFFDFB]">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-7 bg-[#2a2a3e] rounded-b-2xl z-50" />
        <div className="w-full h-full overflow-hidden">
          <div key={screen} className="w-full h-full animate-fade-in">
            {renderScreen()}
          </div>
        </div>
      </div>
      <BottomNav screen={screen} navigate={navigate} />
    </div>
  )
}

// Frameless version used by the single-app layout
export function CreatorContent({ initialScreen = 'dashboard' }: { initialScreen?: string }) {
  const [screen, setScreen] = useState(initialScreen)
  const navigate = (s: string) => setScreen(s)

  const renderScreen = () => {
    switch (screen) {
      case 'dashboard': return <Dashboard navigate={navigate} />
      case 'campaigns': return <Campaigns navigate={navigate} />
      case 'campaign-detail': return <CampaignDetail navigate={navigate} />
      case 'portfolio': return <Portfolio navigate={navigate} />
      case 'analytics': return <Analytics navigate={navigate} />
      case 'wallet': return <Wallet navigate={navigate} />
      case 'ai-assistant': return <AIAssistant navigate={navigate} />
      case 'messages': return <Messages navigate={navigate} />
      case 'notifications': return <Notifications navigate={navigate} />
      case 'settings': return <Settings navigate={navigate} />
      default: return <Dashboard navigate={navigate} />
    }
  }

  return (
    <div className="flex flex-col w-full h-full bg-[#FFFDFB]">
      <div key={screen} className="flex-1 overflow-y-auto animate-fade-in frameless-content">{renderScreen()}</div>
      <BottomNav screen={screen} navigate={navigate} frameless />
    </div>
  )
}

// ─── STANDALONE PAGE ──────────────────────────────────────────────────────────
function CreatorAppPage({ onExit }: { onExit: () => void }) {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-[#1a1a2e] p-4">
      <div className="mb-4 flex items-center gap-4">
        <button onClick={onExit} className="text-white/60 hover:text-white text-sm flex items-center gap-1">
          <Icon.ChevronLeft /> Back to Portal
        </button>
        <span className="text-white/30">|</span>
        <span className="text-white/60 text-sm">Creator App</span>
      </div>
      <CreatorPhoneFrame onExit={onExit} />
    </div>
  )
}

export default function CreatorApp({ onExit }: { onExit: () => void }) {
  return <ToastProvider><CreatorAppPage onExit={onExit} /></ToastProvider>
}

import { useState } from 'react'
import { Button, Badge, Card, AICard, Avatar, ProgressBar, SearchBar, StatCard, SectionHeader, TabBar, Input, Select, Icon, Toggle } from '../components/ui'

// ─── ADMIN SIDEBAR ───────────────────────────────────────────────────────────
function AdminSidebar({ screen, navigate }: { screen: string; navigate: (s: string) => void }) {
  const groups = [
    {
      label: 'Overview', items: [
        { id: 'dashboard', label: 'Dashboard', icon: <Icon.Home /> },
        { id: 'analytics', label: 'Platform Analytics', icon: <Icon.Chart /> },
        { id: 'revenue', label: 'Revenue', icon: <Icon.DollarSign /> },
      ]
    },
    {
      label: 'User Management', items: [
        { id: 'creators', label: 'Creators', icon: <Icon.Camera />, count: 24812 },
        { id: 'brands', label: 'Brands & Agencies', icon: <Icon.Briefcase />, count: 3204 },
        { id: 'verification', label: 'Verification Queue', icon: <Icon.Shield />, count: 48 },
      ]
    },
    {
      label: 'Campaigns', items: [
        { id: 'campaigns', label: 'All Campaigns', icon: <Icon.Package /> },
        { id: 'moderation', label: 'Content Moderation', icon: <Icon.AlertTriangle />, count: 12 },
        { id: 'fraud', label: 'Fraud Detection', icon: <Icon.Shield /> },
      ]
    },
    {
      label: 'Finance', items: [
        { id: 'payments', label: 'Payments', icon: <Icon.Wallet /> },
        { id: 'refunds', label: 'Refund Requests', icon: <Icon.ArrowRight />, count: 7 },
        { id: 'invoices', label: 'Invoices', icon: <Icon.FileText /> },
      ]
    },
    {
      label: 'System', items: [
        { id: 'support', label: 'Support Tickets', icon: <Icon.Message />, count: 23 },
        { id: 'roles', label: 'Role Management', icon: <Icon.Lock /> },
        { id: 'audit', label: 'Audit Logs', icon: <Icon.Clipboard /> },
        { id: 'settings', label: 'System Settings', icon: <Icon.Settings /> },
      ]
    },
  ]
  return (
    <div className="w-64 flex-shrink-0 h-full bg-[#111827] flex flex-col">
      <div className="p-5 border-b border-white/10">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 bg-[#F97316] rounded-xl flex items-center justify-center">
            <span className="text-white font-black text-sm">C</span>
          </div>
          <div>
            <span className="font-black text-white text-base">Collabsy</span>
            <p className="text-[10px] text-white/40">Admin Console</p>
          </div>
        </div>
      </div>
      <nav className="flex-1 p-3 overflow-y-auto space-y-4">
        {groups.map(group => (
          <div key={group.label}>
            <p className="text-[10px] font-semibold text-white/30 uppercase tracking-widest px-3 mb-1">{group.label}</p>
            <div className="space-y-0.5">
              {group.items.map(item => (
                <button key={item.id} onClick={() => navigate(item.id)}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all ${screen === item.id ? 'bg-[#F97316] text-white' : 'text-white/60 hover:bg-white/5 hover:text-white'}`}>
                  <span>{item.icon}</span>
                  <span className="flex-1 text-left">{item.label}</span>
                  {(item as any).count && (
                    <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-bold ${screen === item.id ? 'bg-white/20 text-white' : 'bg-white/10 text-white/60'}`}>{(item as any).count.toLocaleString()}</span>
                  )}
                </button>
              ))}
            </div>
          </div>
        ))}
      </nav>
      <div className="p-4 border-t border-white/10">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 bg-[#F97316]/20 rounded-xl flex items-center justify-center text-[#F97316] font-bold text-sm">SA</div>
          <div>
            <p className="text-sm font-semibold text-white">Super Admin</p>
            <p className="text-xs text-white/40">admin@collabsy.in</p>
          </div>
          <button className="text-white/40 hover:text-white ml-auto"><Icon.LogOut /></button>
        </div>
      </div>
    </div>
  )
}

function AdminTopBar({ title, subtitle, action }: { title: string; subtitle?: string; action?: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between px-8 py-4 border-b border-[#F1E6DD] bg-white flex-shrink-0">
      <div>
        <h1 className="text-xl font-bold text-[#111827]">{title}</h1>
        {subtitle && <p className="text-sm text-[#6B7280]">{subtitle}</p>}
      </div>
      <div className="flex items-center gap-3">
        {action}
        <button className="w-9 h-9 bg-[#F3F4F6] rounded-xl flex items-center justify-center relative">
          <Icon.Bell />
          <span className="absolute -top-1 -right-1 w-4 h-4 bg-[#DC2626] rounded-full text-[9px] text-white flex items-center justify-center font-bold">9</span>
        </button>
      </div>
    </div>
  )
}

// ─── ADMIN DASHBOARD ─────────────────────────────────────────────────────────
function AdminDashboard({ navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="Platform Overview" subtitle="Real-time platform statistics" action={
        <Button variant="outline" size="sm"><Icon.Download /> Export Report</Button>
      } />
      <div className="flex-1 overflow-y-auto p-8 bg-[#FFFDFB] space-y-6">
        {/* KPI Row */}
        <div className="grid grid-cols-5 gap-4">
          <StatCard label="Total Creators" value="24,812" change="+312 this week" positive icon={<Icon.Camera />} />
          <StatCard label="Total Brands" value="3,204" change="+48 this week" positive icon={<Icon.Briefcase />} color="#2563EB" />
          <StatCard label="Active Campaigns" value="1,847" change="+124 today" positive icon={<Icon.Package />} color="#7C3AED" />
          <StatCard label="GMV This Month" value="₹4.8Cr" change="+34% MoM" positive icon={<Icon.DollarSign />} color="#16A34A" />
          <StatCard label="Platform Revenue" value="₹48.2L" change="+28% MoM" positive icon={<Icon.TrendUp />} color="#F97316" />
        </div>

        <div className="grid grid-cols-3 gap-6">
          {/* Platform Growth Chart */}
          <div className="col-span-2">
            <Card>
              <SectionHeader title="Platform Growth" subtitle="Users, campaigns, GMV trends" action={
                <TabBar tabs={['Users', 'Campaigns', 'GMV']} active={0} onChange={() => {}} className="text-xs" />
              } />
              <div className="h-52 flex items-end gap-2">
                {[{m:'Jan',c:8200,b:820},{m:'Feb',c:9400,b:940},{m:'Mar',c:11000,b:1100},{m:'Apr',c:13200,b:1320},{m:'May',c:15800,b:1580},{m:'Jun',c:17200,b:1720},{m:'Jul',c:18900,b:1890},{m:'Aug',c:20100,b:2010},{m:'Sep',c:21400,b:2140},{m:'Oct',c:22800,b:2280},{m:'Nov',c:23900,b:2390},{m:'Dec',c:24812,b:3204}].map((d, i) => {
                  const maxC = 24812
                  return (
                    <div key={i} className="flex-1 flex flex-col items-center gap-0.5">
                      <div className="w-full flex items-end gap-0.5 h-44">
                        <div className="flex-1 rounded-t-lg bg-[#FFF1E8]" style={{ height: `${(d.c / maxC) * 100}%` }} />
                        <div className="flex-1 rounded-t-lg bg-[#F97316]" style={{ height: `${(d.b / maxC) * 60}%` }} />
                      </div>
                      <span className="text-[9px] text-[#9CA3AF]">{d.m}</span>
                    </div>
                  )
                })}
              </div>
              <div className="flex gap-4 mt-2">
                <div className="flex items-center gap-1.5"><div className="w-3 h-3 bg-[#FFF1E8] border border-[#F97316] rounded" /><span className="text-xs text-[#6B7280]">Creators</span></div>
                <div className="flex items-center gap-1.5"><div className="w-3 h-3 bg-[#F97316] rounded" /><span className="text-xs text-[#6B7280]">Brands</span></div>
              </div>
            </Card>
          </div>

          {/* Alerts & Actions */}
          <div className="space-y-4">
            <Card>
              <SectionHeader title="Pending Actions" />
              <div className="space-y-2">
                {[
                  { label: 'Verification Queue', count: 48, color: 'orange', action: 'verification' },
                  { label: 'Support Tickets', count: 23, color: 'blue', action: 'support' },
                  { label: 'Refund Requests', count: 7, color: 'red', action: 'refunds' },
                  { label: 'Flagged Content', count: 12, color: 'red', action: 'moderation' },
                  { label: 'Fraud Alerts', count: 3, color: 'red', action: 'fraud' },
                ].map(a => (
                  <button key={a.label} onClick={() => navigate(a.action)} className="w-full flex items-center gap-3 p-3 rounded-2xl bg-[#F9FAFB] hover:bg-[#FFF1E8] transition-all text-left group">
                    <div className={`w-2 h-2 rounded-full ${a.color === 'orange' ? 'bg-[#F97316]' : a.color === 'blue' ? 'bg-[#2563EB]' : 'bg-[#DC2626]'}`} />
                    <span className="text-sm text-[#374151] flex-1">{a.label}</span>
                    <Badge variant={a.color === 'orange' ? 'orange' : a.color === 'blue' ? 'blue' : 'red'}>{a.count}</Badge>
                  </button>
                ))}
              </div>
            </Card>

            <AICard title="AI Fraud Alerts" subtitle="3 new suspicious activities">
              <div className="space-y-2 mt-1">
                {[
                  { user: 'Creator #4821', issue: 'Fake follower spike (+45K in 2h)', severity: 'high' },
                  { user: 'Brand #2044', issue: 'Payment fraud pattern detected', severity: 'critical' },
                  { user: 'Creator #8912', issue: 'Engagement pod activity', severity: 'medium' },
                ].map((alert, i) => (
                  <div key={i} className="flex items-start gap-2 bg-white/70 rounded-xl p-2.5">
                    <div className={`w-2 h-2 rounded-full mt-1 flex-shrink-0 ${alert.severity === 'critical' ? 'bg-[#DC2626]' : alert.severity === 'high' ? 'bg-[#D97706]' : 'bg-[#F97316]'}`} />
                    <div>
                      <p className="text-xs font-semibold text-[#111827]">{alert.user}</p>
                      <p className="text-[10px] text-[#6B7280]">{alert.issue}</p>
                    </div>
                    <Badge variant={alert.severity === 'critical' ? 'red' : 'orange'} size="sm">{alert.severity}</Badge>
                  </div>
                ))}
              </div>
              <Button variant="secondary" fullWidth size="sm" className="mt-2" onClick={() => navigate('fraud')}>View All Alerts</Button>
            </AICard>
          </div>
        </div>

        {/* Recent Activity Table */}
        <Card>
          <SectionHeader title="Recent Platform Activity" action={<Button variant="outline" size="sm">View All</Button>} />
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#F1E6DD]">
                {['Event', 'User', 'Type', 'Time', 'Status', 'Action'].map(h => (
                  <th key={h} className="text-left text-xs font-semibold text-[#6B7280] pb-3 pr-4 uppercase tracking-wide">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-[#F9FAFB]">
              {[
                { event: 'Campaign Published', user: 'Nykaa', type: 'Campaign', time: '2 min ago', status: 'active' },
                { event: 'Creator Signup', user: 'Meera Iyer', type: 'Creator', time: '5 min ago', status: 'pending_verify' },
                { event: 'Payment Processed', user: 'Myntra', type: 'Payment', time: '12 min ago', status: 'completed' },
                { event: 'Fraud Alert', user: 'Creator #4821', type: 'Security', time: '18 min ago', status: 'flagged' },
                { event: 'Support Ticket', user: 'Priya Sharma', type: 'Support', time: '24 min ago', status: 'open' },
                { event: 'Campaign Applied', user: 'Rohit Verma', type: 'Campaign', time: '31 min ago', status: 'under_review' },
              ].map((a, i) => (
                <tr key={i} className="hover:bg-[#FFFDFB]">
                  <td className="py-3.5 pr-4 text-sm font-semibold text-[#111827]">{a.event}</td>
                  <td className="py-3.5 pr-4 text-sm text-[#374151]">{a.user}</td>
                  <td className="py-3.5 pr-4"><Badge variant={a.type === 'Security' ? 'red' : a.type === 'Payment' ? 'green' : a.type === 'Support' ? 'blue' : 'gray'}>{a.type}</Badge></td>
                  <td className="py-3.5 pr-4 text-sm text-[#9CA3AF]">{a.time}</td>
                  <td className="py-3.5 pr-4"><Badge variant={a.status === 'active' || a.status === 'completed' ? 'green' : a.status === 'flagged' ? 'red' : a.status === 'open' ? 'blue' : 'orange'}>{a.status.replace('_', ' ')}</Badge></td>
                  <td className="py-3.5"><button className="text-xs text-[#F97316] font-medium hover:underline">Review</button></td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      </div>
    </div>
  )
}

// ─── CREATOR MANAGEMENT ──────────────────────────────────────────────────────
function AdminCreators({ navigate: _navigate }: { navigate: (s: string) => void }) {
  const [search, setSearch] = useState('')
  const [tab, setTab] = useState(0)
  const creators = [
    { name: 'Priya Sharma', handle: '@priya.sharma.in', city: 'Mumbai', cat: 'Fashion', followers: '248K', score: 81, status: 'verified', joined: 'Jan 2024', earnings: '₹4.2L' },
    { name: 'Kavya Nair', handle: '@kavya.beauty', city: 'Chennai', cat: 'Beauty', followers: '312K', score: 88, status: 'verified', joined: 'Feb 2024', earnings: '₹5.8L' },
    { name: 'Arjun Mehta', handle: '@arjuntech', city: 'Bengaluru', cat: 'Tech', followers: '182K', score: 76, status: 'verified', joined: 'Mar 2024', earnings: '₹2.9L' },
    { name: 'Meera Iyer', handle: '@meera.lifestyle', city: 'Hyderabad', cat: 'Lifestyle', followers: '94K', score: 0, status: 'pending', joined: 'Dec 2024', earnings: '—' },
    { name: 'Rahul Singh', handle: '@rahulfoodie', city: 'Delhi', cat: 'Food', followers: '134K', score: 71, status: 'suspended', joined: 'Apr 2024', earnings: '₹1.2L' },
  ]
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="Creator Management" subtitle={`${24812..toLocaleString()} total creators`} action={
        <div className="flex gap-2">
          <Button variant="outline" size="sm"><Icon.Download /> Export</Button>
          <Button size="sm"><Icon.Plus /> Add Creator</Button>
        </div>
      } />
      <div className="flex-1 overflow-y-auto bg-[#FFFDFB]">
        <div className="px-8 py-4 border-b border-[#F1E6DD] bg-white flex gap-3 items-center">
          <SearchBar placeholder="Search by name, handle, city..." value={search} onChange={setSearch} className="w-72" />
          <TabBar tabs={['All', 'Verified', 'Pending', 'Suspended']} active={tab} onChange={setTab} className="max-w-xs" />
          <Select options={[{ value: 'all', label: 'All Categories' }, { value: 'fashion', label: 'Fashion' }, { value: 'beauty', label: 'Beauty' }]} className="w-40" />
          <Select options={[{ value: 'all', label: 'All States' }, ...['Maharashtra', 'Karnataka', 'Tamil Nadu', 'Delhi'].map(s => ({ value: s.toLowerCase(), label: s }))]} className="w-40" />
        </div>
        <div className="p-8">
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm text-[#6B7280]">Showing <strong className="text-[#111827]">24,812 creators</strong></p>
            <div className="flex gap-2 text-xs text-[#6B7280]">
              Sort by: <button className="font-medium text-[#F97316]">AI Score ↓</button>
            </div>
          </div>
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#F1E6DD]">
                {['Creator', 'Category', 'Followers', 'AI Score', 'Earnings', 'Status', 'Joined', 'Actions'].map(h => (
                  <th key={h} className="text-left text-xs font-semibold text-[#6B7280] pb-3 pr-4 uppercase tracking-wide">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-[#F9FAFB]">
              {creators.map((c, i) => (
                <tr key={i} className="hover:bg-[#FFFDFB] group">
                  <td className="py-3.5 pr-4">
                    <div className="flex items-center gap-3">
                      <Avatar name={c.name} size="sm" verified={c.status === 'verified'} />
                      <div>
                        <p className="text-sm font-semibold text-[#111827] group-hover:text-[#F97316] transition-colors">{c.name}</p>
                        <p className="text-xs text-[#6B7280]">{c.handle}</p>
                      </div>
                    </div>
                  </td>
                  <td className="py-3.5 pr-4"><Badge variant="gray">{c.cat}</Badge></td>
                  <td className="py-3.5 pr-4 text-sm font-medium text-[#374151]">{c.followers}</td>
                  <td className="py-3.5 pr-4">
                    <div className="flex items-center gap-2">
                      <div className="w-16 h-1.5 bg-[#F3F4F6] rounded-full overflow-hidden"><div className="h-full bg-[#F97316] rounded-full" style={{ width: `${c.score}%` }} /></div>
                      <span className="text-xs font-bold text-[#F97316]">{c.score || '—'}</span>
                    </div>
                  </td>
                  <td className="py-3.5 pr-4 text-sm font-medium text-[#16A34A]">{c.earnings}</td>
                  <td className="py-3.5 pr-4">
                    <Badge variant={c.status === 'verified' ? 'green' : c.status === 'pending' ? 'orange' : 'red'}>{c.status}</Badge>
                  </td>
                  <td className="py-3.5 pr-4 text-sm text-[#9CA3AF]">{c.joined}</td>
                  <td className="py-3.5">
                    <div className="flex gap-1">
                      <button className="w-7 h-7 bg-[#F3F4F6] rounded-lg flex items-center justify-center hover:bg-[#FFF1E8] hover:text-[#F97316]"><Icon.Eye /></button>
                      <button className="w-7 h-7 bg-[#F3F4F6] rounded-lg flex items-center justify-center hover:bg-[#FFF1E8] hover:text-[#F97316]"><Icon.Settings /></button>
                      {c.status === 'pending' && <button className="w-7 h-7 bg-[#DCFCE7] rounded-lg flex items-center justify-center hover:bg-[#BBF7D0] text-[#16A34A]"><Icon.Check /></button>}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

// ─── VERIFICATION QUEUE ──────────────────────────────────────────────────────
function VerificationQueue({ navigate: _navigate }: { navigate: (s: string) => void }) {
  const [selected, setSelected] = useState(0)
  const queue = [
    { name: 'Meera Iyer', handle: '@meera.lifestyle', city: 'Hyderabad', cat: 'Lifestyle', followers: '94K', submitted: '2 hours ago', score: 72 },
    { name: 'Aditya Kumar', handle: '@aditya.travel', city: 'Jaipur', cat: 'Travel', followers: '156K', submitted: '4 hours ago', score: 68 },
    { name: 'Sneha Rao', handle: '@sneha.beauty', city: 'Pune', cat: 'Beauty', followers: '208K', submitted: '6 hours ago', score: 80 },
    { name: 'Vikram Nair', handle: '@vikram.fitness', city: 'Kochi', cat: 'Fitness', followers: '82K', submitted: '8 hours ago', score: 64 },
  ]
  const c = queue[selected]
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="Verification Queue" subtitle="48 creators awaiting verification" />
      <div className="flex-1 overflow-hidden flex bg-[#FFFDFB]">
        {/* Queue List */}
        <div className="w-80 border-r border-[#F1E6DD] flex flex-col bg-white">
          <div className="p-4 border-b border-[#F1E6DD]">
            <SearchBar placeholder="Search queue..." />
          </div>
          <div className="flex-1 overflow-y-auto divide-y divide-[#F9FAFB]">
            {queue.map((item, i) => (
              <button key={i} onClick={() => setSelected(i)} className={`w-full flex items-center gap-3 px-4 py-4 text-left hover:bg-[#F9FAFB] ${selected === i ? 'bg-[#FFF7F0]' : ''}`}>
                <Avatar name={item.name} size="md" />
                <div className="flex-1 min-w-0">
                  <p className={`text-sm font-semibold ${selected === i ? 'text-[#F97316]' : 'text-[#111827]'}`}>{item.name}</p>
                  <p className="text-xs text-[#6B7280]">{item.handle} · {item.city}</p>
                  <p className="text-[10px] text-[#9CA3AF] mt-0.5">{item.submitted}</p>
                </div>
                <div className="text-right">
                  <span className="text-sm font-bold text-[#F97316]">{item.score}</span>
                  <p className="text-[10px] text-[#9CA3AF]">AI Score</p>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Verification Detail */}
        <div className="flex-1 overflow-y-auto p-8 space-y-5">
          <Card className="flex items-start gap-5">
            <Avatar name={c.name} size="xl" />
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-1">
                <h2 className="text-xl font-bold text-[#111827]">{c.name}</h2>
                <Badge variant="orange">Pending Review</Badge>
              </div>
              <p className="text-[#6B7280] mb-3">{c.handle} · {c.cat} · {c.city}</p>
              <div className="grid grid-cols-4 gap-3">
                {[['Followers', c.followers], ['AI Score', c.score.toString()], ['Submitted', c.submitted], ['Category', c.cat]].map(([l, v]) => (
                  <div key={l as string} className="bg-[#F9FAFB] rounded-2xl p-3 text-center">
                    <p className="text-sm font-bold text-[#111827]">{v}</p>
                    <p className="text-xs text-[#6B7280]">{l}</p>
                  </div>
                ))}
              </div>
            </div>
          </Card>

          <AICard title="AI Verification Analysis" subtitle="Automated quality checks">
            <div className="grid grid-cols-2 gap-3 mt-2">
              {[
                { label: 'Follower authenticity', value: 89, status: 'pass' },
                { label: 'Engagement authenticity', value: 76, status: 'pass' },
                { label: 'Content quality', value: 82, status: 'pass' },
                { label: 'Brand safety', value: 94, status: 'pass' },
                { label: 'Identity verified', value: 100, status: 'pass' },
                { label: 'Bot activity', value: 4, status: 'pass', invert: true },
              ].map((check, i) => (
                <div key={i} className="bg-white/80 rounded-xl p-3">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs text-[#374151]">{check.label}</span>
                    <span className={`text-[10px] font-bold ${check.status === 'pass' ? 'text-[#16A34A]' : 'text-[#DC2626]'}`}>
                      {check.status === 'pass' ? '✅ Pass' : '❌ Fail'}
                    </span>
                  </div>
                  <ProgressBar value={check.invert ? 100 - check.value : check.value} color={check.status === 'pass' ? '#16A34A' : '#DC2626'} />
                </div>
              ))}
            </div>
          </AICard>

          <div className="grid grid-cols-2 gap-4">
            <Card>
              <h3 className="font-semibold text-[#111827] mb-3">Documents Submitted</h3>
              <div className="space-y-2">
                {[
                  { doc: 'Aadhaar Card', status: 'verified' },
                  { doc: 'PAN Card', status: 'verified' },
                  { doc: 'Bank Account', status: 'pending' },
                  { doc: 'Instagram Auth', status: 'verified' },
                ].map(d => (
                  <div key={d.doc} className="flex items-center gap-3 py-2 border-b border-[#F9FAFB] last:border-0">
                    <Icon.FileText />
                    <span className="flex-1 text-sm text-[#374151]">{d.doc}</span>
                    <Badge variant={d.status === 'verified' ? 'green' : 'orange'}>{d.status}</Badge>
                  </div>
                ))}
              </div>
            </Card>
            <Card>
              <h3 className="font-semibold text-[#111827] mb-3">Review Notes</h3>
              <textarea className="w-full h-24 bg-[#F9FAFB] rounded-2xl p-3 text-sm text-[#374151] border border-[#F1E6DD] focus:outline-none focus:border-[#F97316] resize-none" placeholder="Add notes for this verification..." />
            </Card>
          </div>

          <div className="flex gap-3">
            <Button variant="danger" fullWidth size="lg"><Icon.X /> Reject</Button>
            <Button variant="outline" fullWidth size="lg"><Icon.AlertTriangle /> Request More Info</Button>
            <Button variant="primary" fullWidth size="lg"><Icon.Check /> Approve & Verify</Button>
          </div>
        </div>
      </div>
    </div>
  )
}

// ─── FRAUD DETECTION ─────────────────────────────────────────────────────────
function FraudDetection({ navigate: _navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="AI Fraud Detection" subtitle="Real-time monitoring and alerts" />
      <div className="flex-1 overflow-y-auto p-8 bg-[#FFFDFB] space-y-6">
        <div className="grid grid-cols-4 gap-4">
          <StatCard label="Alerts Today" value="14" change="+3 in last hour" icon={<Icon.AlertTriangle />} color="#DC2626" />
          <StatCard label="Accounts Flagged" value="48" change="Under review" icon={<Icon.Shield />} color="#D97706" />
          <StatCard label="Resolved (30D)" value="312" change="96% accuracy" positive icon={<Icon.Check />} color="#16A34A" />
          <StatCard label="GMV Protected" value="₹12.4L" change="Fraud prevented" positive icon={<Icon.DollarSign />} />
        </div>

        <div className="grid grid-cols-3 gap-6">
          <div className="col-span-2">
            <Card>
              <SectionHeader title="Active Fraud Alerts" action={<Badge variant="red">3 Critical</Badge>} />
              <div className="space-y-3">
                {[
                  { user: 'Creator #4821 — Rahul Singh', issue: 'Abnormal follower spike: +45K followers in 2 hours from Bangladesh IPs', severity: 'critical', time: '18 min ago', action: 'Suspend' },
                  { user: 'Brand #2044 — TechX India', issue: 'Multiple failed payment attempts with different cards from same IP', severity: 'critical', time: '35 min ago', action: 'Block' },
                  { user: 'Creator #9201 — Preeti Jha', issue: 'Engagement pod activity detected: coordinated likes/comments from 200 accounts', severity: 'high', time: '1 hour ago', action: 'Review' },
                  { user: 'Creator #3318 — Manish Bhatia', issue: 'Duplicate account detected — same phone number as Creator #3302', severity: 'medium', time: '2 hours ago', action: 'Merge' },
                  { user: 'Brand #1840 — FashionX', issue: 'API key sharing detected — single key used from 4 different IPs', severity: 'medium', time: '3 hours ago', action: 'Revoke Key' },
                ].map((alert, i) => (
                  <div key={i} className={`border rounded-2xl p-4 ${alert.severity === 'critical' ? 'border-[#FECACA] bg-[#FFF5F5]' : alert.severity === 'high' ? 'border-[#FED7AA] bg-[#FFFBF5]' : 'border-[#F1E6DD] bg-[#FFFDFB]'}`}>
                    <div className="flex items-start gap-3">
                      <div className={`w-2 h-2 rounded-full mt-1.5 flex-shrink-0 ${alert.severity === 'critical' ? 'bg-[#DC2626]' : alert.severity === 'high' ? 'bg-[#D97706]' : 'bg-[#F97316]'}`} />
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <p className="text-sm font-semibold text-[#111827]">{alert.user}</p>
                          <Badge variant={alert.severity === 'critical' ? 'red' : alert.severity === 'high' ? 'orange' : 'gray'} size="sm">{alert.severity}</Badge>
                          <span className="text-xs text-[#9CA3AF] ml-auto">{alert.time}</span>
                        </div>
                        <p className="text-xs text-[#6B7280]">{alert.issue}</p>
                      </div>
                    </div>
                    <div className="flex gap-2 mt-3 pt-3 border-t border-white/50">
                      <Button variant="outline" size="sm">Dismiss</Button>
                      <Button variant="outline" size="sm">Investigate</Button>
                      <Button variant={alert.severity === 'critical' ? 'danger' : 'primary'} size="sm">{alert.action}</Button>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          <div className="space-y-4">
            <AICard title="AI Fraud Score" subtitle="Platform risk assessment">
              <div className="text-center py-3">
                <div className="relative w-24 h-24 mx-auto">
                  <svg width="96" height="96" className="-rotate-90">
                    <circle cx="48" cy="48" r="38" fill="none" stroke="#F1E6DD" strokeWidth="7" />
                    <circle cx="48" cy="48" r="38" fill="none" stroke="#16A34A" strokeWidth="7" strokeLinecap="round" strokeDasharray="238.8" strokeDashoffset="48" />
                  </svg>
                  <div className="absolute inset-0 flex flex-col items-center justify-center">
                    <span className="text-2xl font-black text-[#111827]">80</span>
                    <span className="text-xs text-[#6B7280]">Safe</span>
                  </div>
                </div>
                <p className="text-xs text-[#6B7280] mt-2">Platform fraud risk score</p>
              </div>
              <div className="space-y-1.5">
                <ProgressBar label="Creator authenticity" value={84} showValue color="#16A34A" />
                <ProgressBar label="Payment safety" value={92} showValue color="#2563EB" />
                <ProgressBar label="Content compliance" value={78} showValue color="#F97316" />
              </div>
            </AICard>

            <Card>
              <h3 className="font-semibold text-[#111827] mb-3 text-sm">Fraud Patterns</h3>
              <div className="space-y-2">
                {[
                  { type: 'Fake followers', count: 28, trend: 'up' },
                  { type: 'Engagement pods', count: 12, trend: 'down' },
                  { type: 'Payment fraud', count: 5, trend: 'stable' },
                  { type: 'Duplicate accounts', count: 3, trend: 'down' },
                ].map((p, i) => (
                  <div key={i} className="flex items-center justify-between py-1.5 border-b border-[#F9FAFB] last:border-0">
                    <span className="text-xs text-[#374151]">{p.type}</span>
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-bold text-[#111827]">{p.count}</span>
                      <span className={`text-xs ${p.trend === 'up' ? 'text-[#DC2626]' : p.trend === 'down' ? 'text-[#16A34A]' : 'text-[#6B7280]'}`}>
                        {p.trend === 'up' ? '↑' : p.trend === 'down' ? '↓' : '→'}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}

// ─── PLATFORM ANALYTICS ──────────────────────────────────────────────────────
function AdminAnalytics({ navigate: _navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="Platform Analytics" subtitle="Comprehensive platform performance" action={
        <div className="flex gap-2">
          <Select options={[{ value: '30d', label: 'Last 30 days' }, { value: '90d', label: 'Last 90 days' }, { value: '1y', label: 'Last year' }]} />
          <Button variant="outline" size="sm"><Icon.Download /> Export</Button>
        </div>
      } />
      <div className="flex-1 overflow-y-auto p-8 bg-[#FFFDFB] space-y-6">
        <div className="grid grid-cols-4 gap-4">
          <StatCard label="Total GMV" value="₹48.2Cr" change="+38% YoY" positive icon={<Icon.DollarSign />} />
          <StatCard label="Campaigns Run" value="18,420" change="+124% YoY" positive icon={<Icon.Package />} color="#7C3AED" />
          <StatCard label="Avg Campaign ROI" value="4.2x" change="Industry avg: 2.8x" positive icon={<Icon.TrendUp />} color="#16A34A" />
          <StatCard label="Creator Earnings" value="₹38.6Cr" change="Paid out total" icon={<Icon.Users />} color="#2563EB" />
        </div>

        <div className="grid grid-cols-2 gap-6">
          <Card>
            <SectionHeader title="GMV by State" subtitle="Top performing states" />
            <div className="space-y-2">
              {[
                ['Maharashtra', 28, '₹13.5Cr'],
                ['Karnataka', 18, '₹8.7Cr'],
                ['Delhi', 16, '₹7.7Cr'],
                ['Tamil Nadu', 12, '₹5.8Cr'],
                ['Gujarat', 10, '₹4.8Cr'],
                ['Telangana', 9, '₹4.3Cr'],
                ['Rajasthan', 7, '₹3.4Cr'],
              ].map(([state, pct, gmv], i) => (
                <div key={state as string} className="flex items-center gap-3">
                  <span className="text-xs font-bold text-[#9CA3AF] w-4">{i + 1}</span>
                  <span className="text-sm text-[#374151] w-28">{state}</span>
                  <div className="flex-1 h-2 bg-[#F3F4F6] rounded-full overflow-hidden">
                    <div className="h-full bg-[#F97316] rounded-full" style={{ width: `${pct as number * 3}%` }} />
                  </div>
                  <span className="text-xs font-medium text-[#374151] w-14 text-right">{gmv}</span>
                  <span className="text-xs text-[#9CA3AF] w-8">{pct}%</span>
                </div>
              ))}
            </div>
          </Card>

          <Card>
            <SectionHeader title="Category Performance" />
            <div className="space-y-3">
              {[
                { cat: 'Fashion & Style', campaigns: 4821, roi: '4.8x', color: '#F97316' },
                { cat: 'Beauty & Skincare', campaigns: 3940, roi: '5.2x', color: '#EC4899' },
                { cat: 'Food & Cooking', campaigns: 2841, roi: '3.9x', color: '#EF4444' },
                { cat: 'Technology', campaigns: 2312, roi: '3.4x', color: '#2563EB' },
                { cat: 'Fitness & Health', campaigns: 1820, roi: '4.1x', color: '#16A34A' },
                { cat: 'Travel', campaigns: 1240, roi: '3.8x', color: '#7C3AED' },
              ].map((c, i) => (
                <div key={i} className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full flex-shrink-0" style={{ background: c.color }} />
                  <span className="text-sm text-[#374151] flex-1">{c.cat}</span>
                  <span className="text-xs text-[#6B7280] w-12 text-right">{c.campaigns.toLocaleString()}</span>
                  <Badge variant="green">{c.roi}</Badge>
                </div>
              ))}
            </div>
          </Card>
        </div>

        <div className="grid grid-cols-3 gap-4">
          {[
            { label: 'New Creators (MoM)', value: '+1,240', change: '+12% growth', positive: true },
            { label: 'New Brands (MoM)', value: '+284', change: '+22% growth', positive: true },
            { label: 'Churn Rate (Creators)', value: '2.1%', change: '-0.4% improved', positive: true },
            { label: 'Churn Rate (Brands)', value: '4.8%', change: '+0.2% worse', positive: false },
            { label: 'Avg Session Duration', value: '18.4 min', change: '+2.1 min', positive: true },
            { label: 'Support Resolution', value: '94.2%', change: '+1.8%', positive: true },
          ].map((s, i) => (
            <StatCard key={i} label={s.label} value={s.value} change={s.change} positive={s.positive} />
          ))}
        </div>
      </div>
    </div>
  )
}

// ─── REVENUE DASHBOARD ───────────────────────────────────────────────────────
function RevenueDashboard({ navigate: _navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="Revenue Dashboard" subtitle="Platform monetization overview" />
      <div className="flex-1 overflow-y-auto p-8 bg-[#FFFDFB] space-y-6">
        <div className="grid grid-cols-4 gap-4">
          <StatCard label="MRR" value="₹48.2L" change="+28% MoM" positive icon={<Icon.TrendUp />} />
          <StatCard label="ARR" value="₹5.78Cr" change="Projected" positive icon={<Icon.DollarSign />} color="#16A34A" />
          <StatCard label="Take Rate" value="8.5%" change="+0.5% vs Q3" positive icon={<Icon.Target />} color="#7C3AED" />
          <StatCard label="Active Subs" value="3,204" change="+284 this month" positive icon={<Icon.Users />} color="#2563EB" />
        </div>

        <div className="grid grid-cols-3 gap-6">
          <div className="col-span-2">
            <Card>
              <SectionHeader title="Revenue Breakdown" subtitle="By source (this month)" />
              <div className="h-52 flex items-end gap-3">
                {['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'].map((m, i) => {
                  const vals = [18,22,28,32,35,38,42,40,44,48,52,48]
                  const h = vals[i]
                  return (
                    <div key={m} className="flex-1 flex flex-col items-center gap-1">
                      <div className="w-full rounded-t-xl" style={{ height: `${h * 3}px`, background: i === 11 ? 'linear-gradient(180deg, #F97316, #EA580C)' : '#FFF1E8' }} />
                      <span className="text-[9px] text-[#9CA3AF]">{m}</span>
                    </div>
                  )
                })}
              </div>
            </Card>
          </div>

          <Card>
            <SectionHeader title="Revenue Sources" />
            <div className="space-y-3">
              {[
                { source: 'Platform Commission (8.5%)', amount: '₹28.4L', pct: 59 },
                { source: 'Brand Subscriptions', amount: '₹12.8L', pct: 27 },
                { source: 'Creator Premium', amount: '₹4.2L', pct: 9 },
                { source: 'API & Enterprise', amount: '₹2.8L', pct: 5 },
              ].map((r, i) => (
                <div key={i}>
                  <div className="flex justify-between text-xs mb-1">
                    <span className="text-[#374151]">{r.source}</span>
                    <span className="font-bold text-[#111827]">{r.amount}</span>
                  </div>
                  <ProgressBar value={r.pct} color={['#F97316', '#2563EB', '#7C3AED', '#16A34A'][i]} />
                </div>
              ))}
            </div>
          </Card>
        </div>
      </div>
    </div>
  )
}

// ─── SUPPORT TICKETS ─────────────────────────────────────────────────────────
function SupportTickets({ navigate: _navigate }: { navigate: (s: string) => void }) {
  const [tab, setTab] = useState(0)
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="Support Tickets" subtitle="23 open tickets" action={
        <Button variant="outline" size="sm"><Icon.Download /> Export</Button>
      } />
      <div className="flex-1 overflow-y-auto bg-[#FFFDFB]">
        <div className="px-8 py-4 border-b border-[#F1E6DD] bg-white">
          <TabBar tabs={['All', 'Open', 'In Progress', 'Resolved']} active={tab} onChange={setTab} className="max-w-sm" />
        </div>
        <div className="p-8">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#F1E6DD]">
                {['Ticket ID', 'User', 'Issue', 'Priority', 'Status', 'Created', 'Assigned To', 'Actions'].map(h => (
                  <th key={h} className="text-left text-xs font-semibold text-[#6B7280] pb-3 pr-4 uppercase tracking-wide">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-[#F9FAFB]">
              {[
                { id: '#TKT-2401', user: 'Priya Sharma', issue: 'Payment not received for Mamaearth campaign', priority: 'high', status: 'open', created: 'Dec 10', assigned: 'Ravi Kumar' },
                { id: '#TKT-2400', user: 'Nykaa Brand', issue: 'Creator application process not working', priority: 'medium', status: 'in_progress', created: 'Dec 10', assigned: 'Sneha Roy' },
                { id: '#TKT-2398', user: 'Arjun Mehta', issue: 'Cannot connect YouTube account', priority: 'medium', status: 'open', created: 'Dec 9', assigned: 'Unassigned' },
                { id: '#TKT-2396', user: 'Zomato Brand', issue: 'Invoice download not working', priority: 'low', status: 'resolved', created: 'Dec 8', assigned: 'Ravi Kumar' },
                { id: '#TKT-2394', user: 'Kavya Nair', issue: 'AI score dropped suddenly without reason', priority: 'high', status: 'in_progress', created: 'Dec 8', assigned: 'Sneha Roy' },
              ].map((t, i) => (
                <tr key={i} className="hover:bg-[#FFFDFB]">
                  <td className="py-3.5 pr-4 text-sm font-mono text-[#6B7280]">{t.id}</td>
                  <td className="py-3.5 pr-4">
                    <div className="flex items-center gap-2">
                      <Avatar name={t.user} size="sm" />
                      <span className="text-sm font-semibold text-[#111827]">{t.user}</span>
                    </div>
                  </td>
                  <td className="py-3.5 pr-4 text-sm text-[#374151] max-w-xs line-clamp-1">{t.issue}</td>
                  <td className="py-3.5 pr-4"><Badge variant={t.priority === 'high' ? 'red' : t.priority === 'medium' ? 'orange' : 'gray'}>{t.priority}</Badge></td>
                  <td className="py-3.5 pr-4"><Badge variant={t.status === 'resolved' ? 'green' : t.status === 'in_progress' ? 'blue' : 'orange'}>{t.status.replace('_', ' ')}</Badge></td>
                  <td className="py-3.5 pr-4 text-sm text-[#9CA3AF]">{t.created}</td>
                  <td className="py-3.5 pr-4 text-sm text-[#374151]">{t.assigned}</td>
                  <td className="py-3.5">
                    <div className="flex gap-1">
                      <button className="w-7 h-7 bg-[#F3F4F6] rounded-lg flex items-center justify-center hover:bg-[#FFF1E8] hover:text-[#F97316]"><Icon.Eye /></button>
                      <button className="w-7 h-7 bg-[#F3F4F6] rounded-lg flex items-center justify-center hover:bg-[#FFF1E8] hover:text-[#F97316]"><Icon.Message /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

function AdminPayments({ navigate: _navigate }: { navigate: (s: string) => void }) {
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="Payments Management" subtitle="Monitor all platform transactions" action={
        <Button variant="outline" size="sm"><Icon.Download /> Export CSV</Button>
      } />
      <div className="flex-1 overflow-y-auto p-8 bg-[#FFFDFB] space-y-6">
        <div className="grid grid-cols-4 gap-4">
          <StatCard label="Total Volume (Mo)" value="₹4.8Cr" change="+34% MoM" positive icon={<Icon.DollarSign />} />
          <StatCard label="Successful" value="98.4%" change="+0.2%" positive icon={<Icon.Check />} color="#16A34A" />
          <StatCard label="Pending" value="₹48.2L" change="142 transactions" icon={<Icon.AlertTriangle />} color="#D97706" />
          <StatCard label="Disputes" value="7" change="-3 from last month" positive icon={<Icon.AlertTriangle />} color="#DC2626" />
        </div>
        <Card>
          <SectionHeader title="Transaction Log" action={<div className="flex gap-2"><Select options={[{ value: 'all', label: 'All Types' }, { value: 'payment', label: 'Payments' }, { value: 'refund', label: 'Refunds' }]} className="w-36" /><Button variant="outline" size="sm">Filter</Button></div>} />
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#F1E6DD]">
                {['TXN ID', 'From', 'To', 'Amount', 'Type', 'Date', 'Status'].map(h => (
                  <th key={h} className="text-left text-xs font-semibold text-[#6B7280] pb-3 pr-4 uppercase tracking-wide">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-[#F9FAFB]">
              {[
                { id: 'TXN-482901', from: 'Nykaa', to: 'Priya Sharma', amount: '₹58,000', type: 'Campaign Payment', date: 'Dec 10', status: 'completed' },
                { id: 'TXN-482900', from: 'Myntra', to: 'Kavya Nair', amount: '₹72,000', type: 'Campaign Payment', date: 'Dec 10', status: 'completed' },
                { id: 'TXN-482899', from: 'Boat', to: 'Arjun Mehta', amount: '₹35,000', type: 'Campaign Payment', date: 'Dec 9', status: 'pending' },
                { id: 'TXN-482897', from: 'Priya Sharma', to: 'Bank', amount: '₹40,000', type: 'Withdrawal', date: 'Dec 8', status: 'completed' },
                { id: 'TXN-482895', from: 'Zomato', to: 'Rahul Singh', amount: '₹28,000', type: 'Campaign Payment', date: 'Dec 8', status: 'failed' },
              ].map((t, i) => (
                <tr key={i} className="hover:bg-[#FFFDFB]">
                  <td className="py-3.5 pr-4 text-xs font-mono text-[#6B7280]">{t.id}</td>
                  <td className="py-3.5 pr-4 text-sm font-medium text-[#374151]">{t.from}</td>
                  <td className="py-3.5 pr-4 text-sm font-medium text-[#374151]">{t.to}</td>
                  <td className="py-3.5 pr-4 text-sm font-bold text-[#111827]">{t.amount}</td>
                  <td className="py-3.5 pr-4"><Badge variant="gray">{t.type}</Badge></td>
                  <td className="py-3.5 pr-4 text-sm text-[#9CA3AF]">{t.date}</td>
                  <td className="py-3.5"><Badge variant={t.status === 'completed' ? 'green' : t.status === 'pending' ? 'orange' : 'red'}>{t.status}</Badge></td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      </div>
    </div>
  )
}

function SystemSettings({ navigate: _navigate }: { navigate: (s: string) => void }) {
  const [aiMod, setAiMod] = useState(true)
  const [fraudDetect, setFraudDetect] = useState(true)
  const [autoVerify, setAutoVerify] = useState(false)
  return (
    <div className="flex flex-col h-full overflow-hidden">
      <AdminTopBar title="System Settings" subtitle="Configure platform behavior" />
      <div className="flex-1 overflow-y-auto p-8 bg-[#FFFDFB]">
        <div className="max-w-2xl space-y-5">
          <Card>
            <h3 className="font-semibold text-[#111827] mb-4">AI Configuration</h3>
            <div className="space-y-4">
              <div className="flex items-center justify-between py-2 border-b border-[#F9FAFB]">
                <div><p className="text-sm font-medium text-[#374151]">AI Content Moderation</p><p className="text-xs text-[#6B7280]">Auto-flag inappropriate content</p></div>
                <Toggle checked={aiMod} onChange={setAiMod} />
              </div>
              <div className="flex items-center justify-between py-2 border-b border-[#F9FAFB]">
                <div><p className="text-sm font-medium text-[#374151]">AI Fraud Detection</p><p className="text-xs text-[#6B7280]">Real-time fraud pattern analysis</p></div>
                <Toggle checked={fraudDetect} onChange={setFraudDetect} />
              </div>
              <div className="flex items-center justify-between py-2">
                <div><p className="text-sm font-medium text-[#374151]">Auto-Verify Low-risk Creators</p><p className="text-xs text-[#6B7280]">Auto-approve if AI Score &gt; 85</p></div>
                <Toggle checked={autoVerify} onChange={setAutoVerify} />
              </div>
            </div>
          </Card>
          <Card>
            <h3 className="font-semibold text-[#111827] mb-4">Platform Fees</h3>
            <div className="space-y-4">
              <Input label="Platform Commission (%)" defaultValue="8.5" type="number" hint="Applied on each campaign transaction" />
              <Input label="Creator Premium (₹/month)" defaultValue="999" type="number" />
              <Input label="Brand Pro Plan (₹/month)" defaultValue="29999" type="number" />
            </div>
          </Card>
          <Card>
            <h3 className="font-semibold text-[#111827] mb-4">Verification Requirements</h3>
            <div className="space-y-3">
              {['Aadhaar Card Required', 'PAN Card Required', 'Bank Account Required', 'Social Media OAuth Required'].map((r, i) => (
                <div key={i} className="flex items-center justify-between">
                  <span className="text-sm text-[#374151]">{r}</span>
                  <Toggle checked={true} onChange={() => {}} />
                </div>
              ))}
            </div>
          </Card>
          <Button fullWidth size="lg">Save Settings</Button>
        </div>
      </div>
    </div>
  )
}

// ─── ADMIN APP ROOT ───────────────────────────────────────────────────────────
export default function AdminApp({ onExit }: { onExit: () => void }) {
  const [screen, setScreen] = useState('dashboard')
  const navigate = (s: string) => setScreen(s)

  const renderScreen = () => {
    switch (screen) {
      case 'dashboard': return <AdminDashboard navigate={navigate} />
      case 'creators': return <AdminCreators navigate={navigate} />
      case 'brands': return <AdminCreators navigate={navigate} />
      case 'verification': return <VerificationQueue navigate={navigate} />
      case 'fraud': return <FraudDetection navigate={navigate} />
      case 'analytics': return <AdminAnalytics navigate={navigate} />
      case 'revenue': return <RevenueDashboard navigate={navigate} />
      case 'payments': return <AdminPayments navigate={navigate} />
      case 'support': return <SupportTickets navigate={navigate} />
      case 'settings': return <SystemSettings navigate={navigate} />
      default: return <AdminDashboard navigate={navigate} />
    }
  }

  return (
    <div className="flex flex-col h-screen">
      <div className="bg-[#0a0a1a] px-6 py-2 flex items-center gap-4 flex-shrink-0">
        <button onClick={onExit} className="text-white/60 hover:text-white text-sm flex items-center gap-1">
          <Icon.ChevronLeft /> Back to Portal
        </button>
        <span className="text-white/30">|</span>
        <span className="text-white/60 text-sm">Admin Console</span>
        <div className="ml-auto flex gap-2">
          {['dashboard','analytics','creators','verification','fraud','payments','support'].map(s => (
            <button key={s} onClick={() => navigate(s)} className={`text-xs px-3 py-1 rounded-lg capitalize ${screen === s ? 'bg-[#F97316] text-white' : 'text-white/50 hover:text-white'}`}>{s}</button>
          ))}
        </div>
      </div>
      <div className="flex flex-1 overflow-hidden">
        <AdminSidebar screen={screen} navigate={navigate} />
        <div className="flex-1 overflow-hidden">
          <div key={screen} className="w-full h-full animate-fade-in">
            {renderScreen()}
          </div>
        </div>
      </div>
    </div>
  )
}

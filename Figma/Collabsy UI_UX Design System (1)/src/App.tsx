import { useState } from 'react'
import AdminApp from './apps/AdminApp'
import { CreatorContent } from './apps/CreatorApp'
import { BrandContent } from './apps/BrandApp'
import { ToastProvider } from './components/ui/Toast'
import SmartLogin from './components/SmartLogin'
import { Icon } from './components/ui'

type Portal = 'login' | 'creator' | 'brand'

export default function App() {
  const [portal, setPortal] = useState<Portal>('login')

  const isAdminRoute = new URLSearchParams(window.location.search).has('admin')
  if (isAdminRoute) return <AdminApp onExit={() => window.close()} />

  const openAdmin = () => {
    const url = `${window.location.origin}${window.location.pathname}?admin`
    window.open(url, '_blank', 'noopener')
  }

  // ── Login screen ──────────────────────────────────────────────────────────
  if (portal === 'login') {
    return (
      <ToastProvider>
        <div className="min-h-screen flex flex-col items-center justify-center bg-[#F8F5F2] px-4 py-8">
          {/* Top bar */}
          <div className="w-full max-w-sm mb-6 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-[#F97316] rounded-xl flex items-center justify-center">
                <span className="text-white font-black text-sm">C</span>
              </div>
              <span className="text-[#111827] font-black text-lg tracking-tight">Collabsy</span>
            </div>
            <button
              onClick={openAdmin}
              className="flex items-center gap-1 text-[#9CA3AF] hover:text-[#374151] text-xs transition-colors"
            >
              <Icon.Shield />
              <span>Admin</span>
              <Icon.ArrowRight />
            </button>
          </div>

          {/* Login card */}
          <div className="w-full max-w-sm bg-white rounded-3xl shadow-xl overflow-hidden">
            <SmartLogin
              onCreatorLogin={() => setPortal('creator')}
              onCreatorSignup={() => setPortal('creator')}
              onBrandLogin={() => setPortal('brand')}
              onBrandSignup={() => setPortal('brand')}
            />
          </div>

          <p className="text-[#9CA3AF] text-xs mt-6">© 2025 Collabsy · Made for India 🇮🇳</p>
        </div>
      </ToastProvider>
    )
  }

  // ── Authenticated: Creator or Brand ───────────────────────────────────────
  return (
    <ToastProvider>
      <div className="min-h-screen flex flex-col bg-[#FFFDFB]">
        {/* Thin top bar with logout */}
        <div className="flex items-center justify-between px-4 py-2 border-b border-[#F1E6DD] bg-white/80 backdrop-blur-sm z-50">
          <div className="flex items-center gap-2">
            <div className="w-6 h-6 bg-[#F97316] rounded-lg flex items-center justify-center">
              <span className="text-white font-black text-xs">C</span>
            </div>
            <span className="text-[#111827] font-black text-sm tracking-tight">Collabsy</span>
            <span className="text-xs text-[#9CA3AF] font-medium">
              {portal === 'creator' ? '· Creator' : '· Brand / Agency'}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={openAdmin}
              className="text-[#9CA3AF] hover:text-[#374151] text-xs flex items-center gap-1 transition-colors"
            >
              <Icon.Shield /><span className="hidden sm:inline">Admin</span>
            </button>
            <button
              onClick={() => setPortal('login')}
              className="flex items-center gap-1 text-xs text-[#9CA3AF] hover:text-[#F97316] transition-colors"
            >
              <Icon.LogOut /><span>Sign out</span>
            </button>
          </div>
        </div>

        {/* App content — full height, no phone frame */}
        <div className="flex-1 overflow-hidden">
          {portal === 'creator'
            ? <CreatorContent />
            : <BrandContent />
          }
        </div>
      </div>
    </ToastProvider>
  )
}

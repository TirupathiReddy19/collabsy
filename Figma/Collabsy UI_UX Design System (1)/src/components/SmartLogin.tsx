import { useState, useRef, useEffect } from 'react'
import { Button, Divider, Icon } from './ui'
import { useToast } from './ui/Toast'

type Tab = 'creator' | 'brand'

const PERSONAL_DOMAINS = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'rediffmail.com', 'ymail.com', 'icloud.com', 'live.com']

function isPersonalEmail(email: string) {
  const domain = email.split('@')[1]?.toLowerCase()
  return domain ? PERSONAL_DOMAINS.includes(domain) : false
}

function detectInputType(value: string): 'phone' | 'email' | 'unknown' {
  const v = value.trim().replace(/\s+/g, '').replace(/^(\+91|0)/, '')
  if (/^\d+$/.test(v) && v.length <= 10) return 'phone'
  if (value.includes('@')) return 'email'
  return 'unknown'
}

// ─── OTP Input ────────────────────────────────────────────────────────────────
function OTPInput({ onComplete }: { onComplete: (code: string) => void }) {
  const [digits, setDigits] = useState(['', '', '', '', '', ''])
  const refs = useRef<(HTMLInputElement | null)[]>([])

  const handleKey = (i: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !digits[i] && i > 0) {
      refs.current[i - 1]?.focus()
    }
  }

  const handleChange = (i: number, v: string) => {
    const char = v.replace(/\D/g, '').slice(-1)
    const next = [...digits]
    next[i] = char
    setDigits(next)
    if (char && i < 5) refs.current[i + 1]?.focus()
    if (next.every(d => d)) onComplete(next.join(''))
  }

  const handlePaste = (e: React.ClipboardEvent) => {
    const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    if (text.length === 6) {
      setDigits(text.split(''))
      refs.current[5]?.focus()
      onComplete(text)
    }
  }

  return (
    <div className="flex gap-2 justify-between" onPaste={handlePaste}>
      {digits.map((d, i) => (
        <input
          key={i}
          ref={el => { refs.current[i] = el }}
          value={d}
          onChange={e => handleChange(i, e.target.value)}
          onKeyDown={e => handleKey(i, e)}
          maxLength={1}
          inputMode="numeric"
          className={`w-12 h-14 text-center text-xl font-bold rounded-2xl border-2 transition-all focus:outline-none ${
            d ? 'border-[#F97316] bg-[#FFF1E8] text-[#C2410C]' : 'border-[#F1E6DD] bg-white text-[#111827]'
          } focus:border-[#F97316] focus:ring-2 focus:ring-[#F97316]/10`}
        />
      ))}
    </div>
  )
}

// ─── Smart Login ──────────────────────────────────────────────────────────────
interface SmartLoginProps {
  defaultTab?: Tab
  onCreatorLogin: () => void
  onBrandLogin: () => void
  onCreatorSignup: () => void
  onBrandSignup: () => void
}

export default function SmartLogin({ defaultTab = 'creator', onCreatorLogin, onBrandLogin, onCreatorSignup, onBrandSignup }: SmartLoginProps) {
  const [tab, setTab] = useState<Tab>(defaultTab)
  const [identifier, setIdentifier] = useState('')
  const [password, setPassword] = useState('')
  const [showPass, setShowPass] = useState(false)
  const [otpSent, setOtpSent] = useState(false)
  const [otpVerified, setOtpVerified] = useState(false)
  const [otpLoading, setOtpLoading] = useState(false)
  const [resendTimer, setResendTimer] = useState(0)
  const [loading, setLoading] = useState(false)
  const toast = useToast()

  const inputType = detectInputType(identifier)
  const isPhone = inputType === 'phone'
  const isEmail = inputType === 'email'
  const isWorkEmail = isEmail && !isPersonalEmail(identifier)
  const isPersonal = isEmail && isPersonalEmail(identifier)
  const canSendOTP = isPhone && identifier.replace(/\D/g, '').replace(/^(91|0)/, '').length === 10

  // countdown timer after OTP send
  useEffect(() => {
    if (resendTimer <= 0) return
    const t = setTimeout(() => setResendTimer(n => n - 1), 1000)
    return () => clearTimeout(t)
  }, [resendTimer])

  const handleSendOTP = () => {
    setOtpLoading(true)
    setTimeout(() => {
      setOtpSent(true)
      setOtpLoading(false)
      setResendTimer(30)
      toast('OTP sent to your mobile number 📱')
    }, 1200)
  }

  const handleResendOTP = () => {
    setOtpSent(false)
    setOtpVerified(false)
    setTimeout(() => {
      setOtpSent(true)
      setResendTimer(30)
      toast('New OTP sent!')
    }, 800)
  }

  const handleOTPComplete = (code: string) => {
    if (code === '123456' || code.length === 6) {
      setOtpVerified(true)
      toast('OTP verified! ✅', 'success')
    }
  }

  const handleSignIn = () => {
    if (tab === 'brand' && isPersonal) return
    setLoading(true)
    setTimeout(() => {
      setLoading(false)
      if (tab === 'creator') onCreatorLogin()
      else onBrandLogin()
    }, 900)
  }

  const handleTabChange = (t: Tab) => {
    setTab(t)
    setIdentifier('')
    setPassword('')
    setOtpSent(false)
    setOtpVerified(false)
  }

  const canSubmit = isPhone
    ? otpVerified
    : isEmail
      ? tab === 'brand' ? isWorkEmail && password.length >= 6 : password.length >= 6
      : false

  const maskedPhone = identifier.replace(/\D/g, '').slice(-10).replace(/(\d{2})(\d{4})(\d{4})/, '+91 $1•••• $3')

  return (
    <div className="flex flex-col h-full bg-[#FFFDFB] px-6 pt-12 pb-6">
      {/* Logo */}
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 bg-[#F97316] rounded-2xl flex items-center justify-center">
          <span className="text-lg font-black text-white">C</span>
        </div>
        <span className="text-xl font-black text-[#111827]">Collabsy</span>
      </div>

      {/* Tab switcher — from sketch */}
      <div className="flex bg-[#F3F4F6] rounded-2xl p-1 mb-6">
        {([['creator', 'Creator'], ['brand', 'Brand / Agency']] as const).map(([id, label]) => (
          <button
            key={id}
            onClick={() => handleTabChange(id)}
            className={`flex-1 py-2.5 px-3 rounded-xl text-sm font-semibold transition-all ${
              tab === id
                ? 'bg-white text-[#111827] shadow-sm'
                : 'text-[#6B7280] hover:text-[#374151]'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      <h1 className="text-2xl font-bold text-[#111827] mb-1">
        {tab === 'creator' ? 'Creator sign in' : 'Brand sign in'}
      </h1>
      <p className="text-[#6B7280] text-sm mb-6">
        {tab === 'creator'
          ? 'Use your email or mobile number'
          : 'Work email required for brand accounts'}
      </p>

      <div className="flex flex-col gap-4 flex-1">
        {/* ── Identifier field ── */}
        {!otpSent ? (
          <div>
            <label className="text-sm font-medium text-[#374151] mb-1.5 block">
              {tab === 'creator' ? 'Email or Mobile Number' : 'Work Email'}
            </label>
            <div className="relative">
              <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#9CA3AF]">
                {isPhone ? <Icon.Phone /> : <Icon.Mail />}
              </span>
              <input
                value={identifier}
                onChange={e => {
                  setIdentifier(e.target.value)
                  setOtpSent(false)
                  setOtpVerified(false)
                }}
                placeholder={tab === 'creator' ? 'Email or +91 mobile' : 'you@company.com'}
                inputMode={identifier.length < 3 || isPhone ? 'tel' : 'email'}
                className={`w-full bg-white border-2 rounded-2xl px-4 py-3 text-sm pl-10 focus:outline-none transition-all ${
                  isPersonal && tab === 'brand'
                    ? 'border-[#FCA5A5] focus:border-[#DC2626]'
                    : isEmail || isPhone
                      ? 'border-[#F97316] focus:border-[#F97316]'
                      : 'border-[#F1E6DD] focus:border-[#F97316]'
                } focus:ring-2 focus:ring-[#F97316]/10`}
              />
              {/* type badge */}
              {(isPhone || isEmail) && (
                <span className={`absolute right-3.5 top-1/2 -translate-y-1/2 text-xs font-semibold px-2 py-0.5 rounded-full ${
                  isPhone ? 'bg-[#DBEAFE] text-[#1D4ED8]'
                  : isWorkEmail ? 'bg-[#DCFCE7] text-[#15803D]'
                  : 'bg-[#FEE2E2] text-[#DC2626]'
                }`}>
                  {isPhone ? 'Mobile' : isWorkEmail ? 'Work ✓' : 'Personal'}
                </span>
              )}
            </div>
            {/* Brand personal email warning */}
            {tab === 'brand' && isPersonal && (
              <p className="text-xs text-[#DC2626] mt-1.5 flex items-center gap-1">
                <Icon.AlertTriangle /> Work email required (not Gmail/Yahoo/Hotmail)
              </p>
            )}
            {/* Brand work email tip */}
            {tab === 'brand' && identifier.length === 0 && (
              <p className="text-xs text-[#9CA3AF] mt-1.5">e.g. marketing@nykaa.com</p>
            )}
          </div>
        ) : (
          /* OTP sent state — show masked phone + OTP boxes */
          <div className="space-y-4">
            <div className="bg-[#FFF1E8] rounded-2xl p-4 border border-[#FDDCBE]">
              <p className="text-sm font-semibold text-[#111827] mb-0.5">OTP sent to</p>
              <p className="text-base font-bold text-[#F97316]">{maskedPhone}</p>
              <button onClick={() => { setOtpSent(false); setOtpVerified(false) }} className="text-xs text-[#6B7280] underline mt-1">Change number</button>
            </div>
            <div>
              <label className="text-sm font-medium text-[#374151] mb-3 block">Enter 6-digit OTP</label>
              <OTPInput onComplete={handleOTPComplete} />
              {otpVerified && (
                <p className="text-xs text-[#16A34A] mt-2 flex items-center gap-1 animate-fade-in">
                  <Icon.Check /> OTP verified successfully
                </p>
              )}
            </div>
            <div className="flex items-center justify-between text-xs">
              <span className="text-[#6B7280]">Didn't receive OTP?</span>
              {resendTimer > 0 ? (
                <span className="text-[#9CA3AF]">Resend in {resendTimer}s</span>
              ) : (
                <button onClick={handleResendOTP} className="text-[#F97316] font-semibold">Resend OTP</button>
              )}
            </div>
          </div>
        )}

        {/* ── OTP Send button (phone flow, before OTP sent) ── */}
        {isPhone && !otpSent && (
          <Button
            fullWidth
            size="lg"
            loading={otpLoading}
            disabled={!canSendOTP}
            onClick={handleSendOTP}
          >
            <Icon.Phone /> Send OTP
          </Button>
        )}

        {/* ── Password field (email flow) ── */}
        {isEmail && !(tab === 'brand' && isPersonal) && (
          <div>
            <label className="text-sm font-medium text-[#374151] mb-1.5 block">Password</label>
            <div className="relative">
              <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#9CA3AF]"><Icon.Lock /></span>
              <input
                type={showPass ? 'text' : 'password'}
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full bg-white border-2 border-[#F1E6DD] rounded-2xl px-4 py-3 text-sm pl-10 pr-10 focus:outline-none focus:border-[#F97316] focus:ring-2 focus:ring-[#F97316]/10 transition-all"
              />
              <button
                type="button"
                onClick={() => setShowPass(v => !v)}
                className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[#9CA3AF] hover:text-[#6B7280]"
              >
                <Icon.Eye />
              </button>
            </div>
            <div className="flex justify-between mt-2">
              <span className="text-xs text-[#9CA3AF]">Min. 8 characters</span>
              <button className="text-xs text-[#F97316] font-medium">Forgot password?</button>
            </div>
          </div>
        )}

        {/* ── Sign In button (phone: after OTP verified / email: after password) ── */}
        {(isEmail || otpVerified) && !(isPhone && !otpVerified) && !(tab === 'brand' && isPersonal) && (
          <Button
            fullWidth
            size="lg"
            loading={loading}
            disabled={!canSubmit}
            onClick={handleSignIn}
          >
            Sign In
          </Button>
        )}

        {/* Social logins — Creator only */}
        {tab === 'creator' && !otpSent && (
          <>
            <Divider label="or" />
            <button className="w-full flex items-center justify-center gap-3 py-3 px-5 rounded-2xl border border-[#F1E6DD] bg-white text-sm font-medium text-[#374151] hover:bg-[#F9FAFB] transition-colors">
              <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
              Continue with Google
            </button>
            <button className="w-full flex items-center justify-center gap-3 py-3 px-5 rounded-2xl border border-[#F1E6DD] bg-white text-sm font-medium text-[#374151] hover:bg-[#F9FAFB] transition-colors">
              <Icon.Instagram /> Continue with Instagram
            </button>
          </>
        )}

        {/* Brand — Google Workspace */}
        {tab === 'brand' && !otpSent && (
          <>
            <Divider label="or" />
            <button className="w-full flex items-center justify-center gap-3 py-3 px-5 rounded-2xl border border-[#F1E6DD] bg-white text-sm font-medium text-[#374151] hover:bg-[#F9FAFB] transition-colors">
              <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
              Continue with Google Workspace
            </button>
          </>
        )}
      </div>

      {/* Sign up link */}
      <p className="text-center text-sm text-[#6B7280] mt-4">
        {tab === 'creator'
          ? <>Don't have an account? <button onClick={onCreatorSignup} className="text-[#F97316] font-semibold">Sign up free</button></>
          : <>New brand? <button onClick={onBrandSignup} className="text-[#F97316] font-semibold">Create account</button></>
        }
      </p>
    </div>
  )
}

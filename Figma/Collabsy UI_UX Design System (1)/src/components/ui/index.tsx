import React from 'react'

// ─── Icons (inline SVG) ──────────────────────────────────────────────────────
export const Icon = {
  Home: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>,
  Search: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>,
  Bell: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>,
  User: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>,
  Settings: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4M4.22 19.78l2.83-2.83M16.95 7.05l2.83-2.83"/></svg>,
  Chart: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>,
  Wallet: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><path d="M1 10h22"/></svg>,
  Message: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>,
  Star: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>,
  Zap: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>,
  TrendUp: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>,
  Camera: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>,
  Check: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>,
  X: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>,
  ChevronRight: () => <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"/></svg>,
  ChevronLeft: () => <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="15 18 9 12 15 6"/></svg>,
  ChevronDown: () => <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9"/></svg>,
  Plus: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>,
  Eye: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>,
  Heart: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>,
  Instagram: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>,
  YouTube: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22.54 6.42a2.78 2.78 0 0 0-1.95-1.96C18.88 4 12 4 12 4s-6.88 0-8.59.46a2.78 2.78 0 0 0-1.95 1.96A29 29 0 0 0 1 12a29 29 0 0 0 .46 5.58A2.78 2.78 0 0 0 3.41 19.6C5.12 20 12 20 12 20s6.88 0 8.59-.46a2.78 2.78 0 0 0 1.95-1.95A29 29 0 0 0 23 12a29 29 0 0 0-.46-5.58z"/><polygon points="9.75 15.02 15.5 12 9.75 8.98 9.75 15.02"/></svg>,
  Filter: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>,
  Download: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>,
  Upload: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>,
  Shield: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>,
  Brain: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96-.46 2.5 2.5 0 0 1-1.04-4.79A2.5 2.5 0 0 1 5 12a2.5 2.5 0 0 1 1.96-2.44 2.5 2.5 0 0 1 1.54-4.81V4.5A2.5 2.5 0 0 1 9.5 2z"/><path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96-.46 2.5 2.5 0 0 0 1.04-4.79A2.5 2.5 0 0 0 19 12a2.5 2.5 0 0 0-1.96-2.44 2.5 2.5 0 0 0-1.54-4.81V4.5A2.5 2.5 0 0 0 14.5 2z"/></svg>,
  Briefcase: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>,
  Globe: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>,
  Map: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" y1="2" x2="8" y2="18"/><line x1="16" y1="6" x2="16" y2="22"/></svg>,
  Users: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>,
  DollarSign: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>,
  Target: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/></svg>,
  Lock: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>,
  Mail: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>,
  Phone: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>,
  Info: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>,
  AlertTriangle: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>,
  Bookmark: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>,
  Share: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg>,
  Sparkles: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/><path d="M5 3v4"/><path d="M19 17v4"/><path d="M3 5h4"/><path d="M17 19h4"/></svg>,
  MoreHorizontal: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg>,
  ArrowRight: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>,
  Play: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>,
  Package: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="16.5" y1="9.4" x2="7.5" y2="4.21"/><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>,
  FileText: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>,
  LogOut: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>,
  Layers: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>,
  Activity: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>,
  Clipboard: () => <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1" ry="1"/></svg>,
}

// ─── Button ──────────────────────────────────────────────────────────────────
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  icon?: React.ReactNode
  iconRight?: React.ReactNode
  fullWidth?: boolean
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary', size = 'md', loading, icon, iconRight, fullWidth, children, className = '', disabled, ...props
}) => {
  const base = 'inline-flex items-center justify-center gap-2 font-semibold rounded-2xl transition-all duration-150 cursor-pointer select-none border border-transparent'
  const sizes = { sm: 'px-4 py-2 text-sm', md: 'px-5 py-3 text-sm', lg: 'px-7 py-4 text-base' }
  const variants = {
    primary: 'bg-[#F97316] text-white hover:bg-[#EA580C] active:bg-[#C2410C] shadow-orange disabled:opacity-50',
    secondary: 'bg-[#FFF1E8] text-[#C2410C] hover:bg-[#FDDCBE] active:bg-[#FBBF99]',
    outline: 'border-[#F1E6DD] text-[#374151] hover:bg-[#FFF1E8] hover:border-[#F97316] hover:text-[#F97316]',
    ghost: 'text-[#6B7280] hover:bg-[#F3F4F6] hover:text-[#111827]',
    danger: 'bg-[#DC2626] text-white hover:bg-[#B91C1C]',
  }
  return (
    <button
      className={`${base} ${sizes[size]} ${variants[variant]} ${fullWidth ? 'w-full' : ''} ${disabled || loading ? 'opacity-50 cursor-not-allowed' : ''} ${className}`}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : icon}
      {children}
      {iconRight && !loading && iconRight}
    </button>
  )
}

// ─── Badge ───────────────────────────────────────────────────────────────────
interface BadgeProps { variant?: 'orange' | 'green' | 'red' | 'blue' | 'gray' | 'purple'; children: React.ReactNode; size?: 'sm' | 'md' }
export const Badge: React.FC<BadgeProps> = ({ variant = 'orange', children, size = 'sm' }) => {
  const styles = {
    orange: 'bg-[#FFF1E8] text-[#C2410C] border-[#FDDCBE]',
    green: 'bg-[#DCFCE7] text-[#15803D] border-[#BBF7D0]',
    red: 'bg-[#FEE2E2] text-[#DC2626] border-[#FECACA]',
    blue: 'bg-[#DBEAFE] text-[#1D4ED8] border-[#BFDBFE]',
    gray: 'bg-[#F3F4F6] text-[#6B7280] border-[#E5E7EB]',
    purple: 'bg-[#F3E8FF] text-[#7C3AED] border-[#E9D5FF]',
  }
  const sz = size === 'sm' ? 'px-2.5 py-0.5 text-xs' : 'px-3 py-1 text-sm'
  return <span className={`inline-flex items-center gap-1 rounded-full border font-medium ${styles[variant]} ${sz}`}>{children}</span>
}

// ─── Input ───────────────────────────────────────────────────────────────────
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
  icon?: React.ReactNode
  iconRight?: React.ReactNode
  hint?: string
}
export const Input: React.FC<InputProps> = ({ label, error, icon, iconRight, hint, className = '', ...props }) => (
  <div className="flex flex-col gap-1.5">
    {label && <label className="text-sm font-medium text-[#374151]">{label}</label>}
    <div className="relative">
      {icon && <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#9CA3AF]">{icon}</span>}
      <input
        className={`w-full bg-white border ${error ? 'border-[#DC2626]' : 'border-[#F1E6DD]'} rounded-2xl px-4 py-3 text-sm text-[#111827] placeholder:text-[#9CA3AF] focus:outline-none focus:border-[#F97316] focus:ring-2 focus:ring-[#F97316]/10 transition-all ${icon ? 'pl-10' : ''} ${iconRight ? 'pr-10' : ''} ${className}`}
        {...props}
      />
      {iconRight && <span className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[#9CA3AF]">{iconRight}</span>}
    </div>
    {error && <p className="text-xs text-[#DC2626] flex items-center gap-1"><Icon.X />{error}</p>}
    {hint && !error && <p className="text-xs text-[#9CA3AF]">{hint}</p>}
  </div>
)

// ─── Card ────────────────────────────────────────────────────────────────────
interface CardProps { children: React.ReactNode; className?: string; onClick?: () => void; hover?: boolean }
export const Card: React.FC<CardProps> = ({ children, className = '', onClick, hover }) => (
  <div
    onClick={onClick}
    className={`bg-white rounded-3xl border border-[#F1E6DD] shadow-card p-5 ${hover ? 'hover:shadow-lg hover:border-[#FDDCBE] cursor-pointer' : ''} ${onClick ? 'cursor-pointer' : ''} ${className}`}
    style={{ boxShadow: '0 4px 16px rgba(0,0,0,0.06)' }}
  >
    {children}
  </div>
)

// ─── AI Card ─────────────────────────────────────────────────────────────────
export const AICard: React.FC<{ title: string; subtitle?: string; children: React.ReactNode; className?: string }> = ({ title, subtitle, children, className = '' }) => (
  <div className={`relative overflow-hidden rounded-3xl p-5 border border-[#FDDCBE] ${className}`}
    style={{ background: 'linear-gradient(135deg, #FFF1E8 0%, #FFFDFB 60%, #FFF7F0 100%)' }}>
    <div className="absolute top-0 right-0 w-32 h-32 rounded-full opacity-10" style={{ background: 'radial-gradient(circle, #F97316, transparent)', transform: 'translate(30%, -30%)' }} />
    <div className="flex items-center gap-2 mb-3">
      <div className="w-7 h-7 rounded-xl bg-[#F97316] flex items-center justify-center">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/></svg>
      </div>
      <div>
        <p className="text-sm font-semibold text-[#111827]">{title}</p>
        {subtitle && <p className="text-xs text-[#6B7280]">{subtitle}</p>}
      </div>
    </div>
    {children}
  </div>
)

// ─── Avatar ──────────────────────────────────────────────────────────────────
export const Avatar: React.FC<{ src?: string; name: string; size?: 'sm' | 'md' | 'lg' | 'xl'; verified?: boolean }> = ({ src, name, size = 'md', verified }) => {
  const sizes = { sm: 'w-8 h-8 text-xs', md: 'w-10 h-10 text-sm', lg: 'w-14 h-14 text-base', xl: 'w-20 h-20 text-xl' }
  const initials = name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase()
  return (
    <div className="relative inline-flex">
      {src ? (
        <img src={src} alt={name} className={`${sizes[size]} rounded-full object-cover border-2 border-[#F1E6DD]`} />
      ) : (
        <div className={`${sizes[size]} rounded-full bg-gradient-to-br from-[#F97316] to-[#EA580C] flex items-center justify-center text-white font-bold border-2 border-[#F1E6DD]`}>
          {initials}
        </div>
      )}
      {verified && <div className="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-[#F97316] rounded-full flex items-center justify-center border border-white"><svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3"><polyline points="20 6 9 17 4 12"/></svg></div>}
    </div>
  )
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────
export const ProgressBar: React.FC<{ value: number; max?: number; color?: string; label?: string; showValue?: boolean }> = ({ value, max = 100, color = '#F97316', label, showValue }) => (
  <div className="flex flex-col gap-1">
    {(label || showValue) && (
      <div className="flex justify-between">
        {label && <span className="text-xs font-medium text-[#374151]">{label}</span>}
        {showValue && <span className="text-xs font-semibold text-[#F97316]">{Math.round((value / max) * 100)}%</span>}
      </div>
    )}
    <div className="w-full h-2 bg-[#F3F4F6] rounded-full overflow-hidden">
      <div className="h-full rounded-full transition-all duration-500" style={{ width: `${Math.min((value / max) * 100, 100)}%`, background: color }} />
    </div>
  </div>
)

// ─── Chip ────────────────────────────────────────────────────────────────────
export const Chip: React.FC<{ label: string; active?: boolean; onRemove?: () => void; onClick?: () => void }> = ({ label, active, onRemove, onClick }) => (
  <button
    onClick={onClick}
    className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-all ${
      active ? 'bg-[#F97316] text-white border-[#F97316]' : 'bg-white text-[#6B7280] border-[#F1E6DD] hover:border-[#F97316] hover:text-[#F97316]'
    }`}
  >
    {label}
    {onRemove && <span onClick={e => { e.stopPropagation(); onRemove(); }} className="hover:opacity-70"><Icon.X /></span>}
  </button>
)

// ─── Stat Card ───────────────────────────────────────────────────────────────
export const StatCard: React.FC<{ label: string; value: string; change?: string; positive?: boolean; icon?: React.ReactNode; color?: string }> = ({ label, value, change, positive, icon, color = '#F97316' }) => (
  <Card className="flex flex-col gap-3">
    <div className="flex items-center justify-between">
      <p className="text-xs font-medium text-[#6B7280] uppercase tracking-wide">{label}</p>
      {icon && <div className="w-9 h-9 rounded-2xl flex items-center justify-center" style={{ background: color + '15', color }}>{icon}</div>}
    </div>
    <div>
      <p className="text-2xl font-bold text-[#111827]">{value}</p>
      {change && (
        <p className={`text-xs font-medium mt-0.5 flex items-center gap-1 ${positive ? 'text-[#16A34A]' : 'text-[#DC2626]'}`}>
          {positive ? '↑' : '↓'} {change}
        </p>
      )}
    </div>
  </Card>
)

// ─── Score Ring ───────────────────────────────────────────────────────────────
export const ScoreRing: React.FC<{ score: number; label?: string; size?: number }> = ({ score, label, size = 80 }) => {
  const r = (size / 2) - 8
  const circ = 2 * Math.PI * r
  const offset = circ - (score / 100) * circ
  return (
    <div className="flex flex-col items-center gap-1">
      <svg width={size} height={size} className="-rotate-90">
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="#F1E6DD" strokeWidth="6"/>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="#F97316" strokeWidth="6" strokeLinecap="round" strokeDasharray={circ} strokeDashoffset={offset} style={{ transition: 'stroke-dashoffset 1s ease' }}/>
      </svg>
      <div className="absolute flex flex-col items-center" style={{ marginTop: -size/2 - 12 }}>
        <span className="text-lg font-bold text-[#111827]">{score}</span>
      </div>
      {label && <p className="text-xs text-[#6B7280] font-medium">{label}</p>}
    </div>
  )
}

// ─── Search Bar ──────────────────────────────────────────────────────────────
export const SearchBar: React.FC<{ placeholder?: string; value?: string; onChange?: (v: string) => void; className?: string }> = ({ placeholder = 'Search...', value, onChange, className = '' }) => (
  <div className={`relative ${className}`}>
    <span className="absolute left-4 top-1/2 -translate-y-1/2 text-[#9CA3AF]"><Icon.Search /></span>
    <input
      value={value}
      onChange={e => onChange?.(e.target.value)}
      placeholder={placeholder}
      className="w-full bg-white border border-[#F1E6DD] rounded-2xl pl-11 pr-4 py-3 text-sm placeholder:text-[#9CA3AF] focus:outline-none focus:border-[#F97316] focus:ring-2 focus:ring-[#F97316]/10"
    />
  </div>
)

// ─── Toast ───────────────────────────────────────────────────────────────────
export const Toast: React.FC<{ message: string; type?: 'success' | 'error' | 'info'; onClose?: () => void }> = ({ message, type = 'success', onClose }) => {
  const styles = { success: 'bg-[#16A34A] text-white', error: 'bg-[#DC2626] text-white', info: 'bg-[#111827] text-white' }
  return (
    <div className={`fixed bottom-20 left-1/2 -translate-x-1/2 z-50 px-5 py-3 rounded-2xl shadow-lg flex items-center gap-3 animate-slide-up ${styles[type]}`}>
      {type === 'success' && <Icon.Check />}
      {type === 'error' && <Icon.X />}
      {type === 'info' && <Icon.Info />}
      <span className="text-sm font-medium">{message}</span>
      {onClose && <button onClick={onClose} className="opacity-70 hover:opacity-100"><Icon.X /></button>}
    </div>
  )
}

// ─── Empty State ─────────────────────────────────────────────────────────────
export const EmptyState: React.FC<{ title: string; description: string; action?: React.ReactNode; emoji?: string }> = ({ title, description, action, emoji = '📭' }) => (
  <div className="flex flex-col items-center justify-center py-16 px-6 text-center">
    <div className="text-5xl mb-4">{emoji}</div>
    <h3 className="text-base font-semibold text-[#111827] mb-1">{title}</h3>
    <p className="text-sm text-[#6B7280] max-w-xs mb-5">{description}</p>
    {action}
  </div>
)

// ─── Loading Skeleton ─────────────────────────────────────────────────────────
export const Skeleton: React.FC<{ className?: string }> = ({ className = '' }) => (
  <div className={`skeleton ${className}`} />
)

// ─── Section Header ──────────────────────────────────────────────────────────
export const SectionHeader: React.FC<{ title: string; subtitle?: string; action?: React.ReactNode }> = ({ title, subtitle, action }) => (
  <div className="flex items-center justify-between mb-4">
    <div>
      <h2 className="text-base font-bold text-[#111827]">{title}</h2>
      {subtitle && <p className="text-xs text-[#6B7280] mt-0.5">{subtitle}</p>}
    </div>
    {action}
  </div>
)

// ─── Select ───────────────────────────────────────────────────────────────────
interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> { label?: string; options: { value: string; label: string }[] }
export const Select: React.FC<SelectProps> = ({ label, options, className = '', ...props }) => (
  <div className="flex flex-col gap-1.5">
    {label && <label className="text-sm font-medium text-[#374151]">{label}</label>}
    <div className="relative">
      <select className={`w-full appearance-none bg-white border border-[#F1E6DD] rounded-2xl px-4 py-3 text-sm text-[#111827] focus:outline-none focus:border-[#F97316] pr-10 ${className}`} {...props}>
        {options.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
      <span className="absolute right-3.5 top-1/2 -translate-y-1/2 text-[#9CA3AF] pointer-events-none"><Icon.ChevronDown /></span>
    </div>
  </div>
)

// ─── Tab Bar ─────────────────────────────────────────────────────────────────
export const TabBar: React.FC<{ tabs: string[]; active: number; onChange: (i: number) => void; className?: string }> = ({ tabs, active, onChange, className = '' }) => (
  <div className={`flex items-center gap-1 bg-[#F3F4F6] rounded-2xl p-1 ${className}`}>
    {tabs.map((t, i) => (
      <button key={t} onClick={() => onChange(i)} className={`flex-1 py-2 px-3 rounded-xl text-sm font-medium transition-all ${active === i ? 'bg-white text-[#111827] shadow-sm' : 'text-[#6B7280] hover:text-[#374151]'}`}>
        {t}
      </button>
    ))}
  </div>
)

// ─── Divider ─────────────────────────────────────────────────────────────────
export const Divider: React.FC<{ label?: string }> = ({ label }) => (
  <div className="flex items-center gap-3 my-4">
    <div className="flex-1 h-px bg-[#F1E6DD]" />
    {label && <span className="text-xs text-[#9CA3AF] font-medium">{label}</span>}
    <div className="flex-1 h-px bg-[#F1E6DD]" />
  </div>
)

// ─── Toggle ──────────────────────────────────────────────────────────────────
export const Toggle: React.FC<{ checked: boolean; onChange: (v: boolean) => void; label?: string }> = ({ checked, onChange, label }) => (
  <div className="flex items-center gap-3">
    <div role="switch" aria-checked={checked} onClick={e => { e.stopPropagation(); onChange(!checked) }} className={`relative w-11 h-6 rounded-full transition-colors cursor-pointer flex-shrink-0 ${checked ? 'bg-[#F97316]' : 'bg-[#D1D5DB]'}`}>
      <span className={`absolute top-0.5 left-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform ${checked ? 'translate-x-5' : ''}`} />
    </div>
    {label && <span className="text-sm text-[#374151]">{label}</span>}
  </div>
)

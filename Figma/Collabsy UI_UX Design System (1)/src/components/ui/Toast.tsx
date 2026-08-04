import { useState, createContext, useContext, useCallback } from 'react'
import { Icon } from './index'

type ToastType = 'success' | 'error' | 'info' | 'warning'
interface ToastItem { id: number; message: string; type: ToastType }

const ToastContext = createContext<(msg: string, type?: ToastType) => void>(() => {})

export function useToast() { return useContext(ToastContext) }

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([])
  let counter = 0

  const show = useCallback((message: string, type: ToastType = 'success') => {
    const id = ++counter
    setToasts(t => [...t, { id, message, type }])
    setTimeout(() => setToasts(t => t.filter(x => x.id !== id)), 3000)
  }, [])

  const icons = { success: <Icon.Check />, error: <Icon.X />, info: <Icon.Info />, warning: <Icon.AlertTriangle /> }
  const styles = {
    success: 'bg-[#111827] text-white',
    error: 'bg-[#DC2626] text-white',
    info: 'bg-[#2563EB] text-white',
    warning: 'bg-[#D97706] text-white',
  }

  return (
    <ToastContext.Provider value={show}>
      {children}
      <div className="fixed bottom-24 left-1/2 -translate-x-1/2 z-[100] flex flex-col gap-2 items-center pointer-events-none">
        {toasts.map(t => (
          <div key={t.id} className={`flex items-center gap-2.5 px-4 py-3 rounded-2xl shadow-lg text-sm font-medium animate-slide-up pointer-events-auto ${styles[t.type]}`}
            style={{ minWidth: 220, maxWidth: 320 }}>
            <span className="flex-shrink-0">{icons[t.type]}</span>
            <span>{t.message}</span>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  )
}

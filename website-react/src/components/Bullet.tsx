import './Bullet.css'

export function Bullet({ children }: { children: React.ReactNode }) {
  return (
    <li className="bullet-item">
      <span className="bullet-check">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" aria-hidden="true">
          <path
            d="M5 13l4 4L19 7"
            stroke="currentColor"
            strokeWidth="3"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </span>
      <span>{children}</span>
    </li>
  )
}

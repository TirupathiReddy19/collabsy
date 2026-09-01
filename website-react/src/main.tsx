import { StrictMode, Suspense, lazy } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { Layout } from './components/Layout'
import { Home } from './pages/Home'
import './index.css'
import './styles/shared.css'

// Home ships eagerly (it's the overwhelmingly common landing page and
// carries the hero); every other route is its own chunk, fetched only when
// visited, so Home's first load never pays for Firebase, the campaign
// form, or the legal-text pages.
const Creators = lazy(() => import('./pages/Creators').then((m) => ({ default: m.Creators })))
const Brands = lazy(() => import('./pages/Brands').then((m) => ({ default: m.Brands })))
const About = lazy(() => import('./pages/About').then((m) => ({ default: m.About })))
const Contact = lazy(() => import('./pages/Contact').then((m) => ({ default: m.Contact })))
const Privacy = lazy(() => import('./pages/Privacy').then((m) => ({ default: m.Privacy })))
const Terms = lazy(() => import('./pages/Terms').then((m) => ({ default: m.Terms })))
const DeleteAccount = lazy(() =>
  import('./pages/DeleteAccount').then((m) => ({ default: m.DeleteAccount })),
)
const NotFound = lazy(() => import('./pages/NotFound').then((m) => ({ default: m.NotFound })))

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <Suspense fallback={<div style={{ minHeight: '60vh' }} />}>
        <Routes>
          <Route element={<Layout />}>
            <Route path="/" element={<Home />} />
            <Route path="/creators" element={<Creators />} />
            <Route path="/brands" element={<Brands />} />
            <Route path="/about" element={<About />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/privacy" element={<Privacy />} />
            <Route path="/terms" element={<Terms />} />
            <Route path="/delete-account" element={<DeleteAccount />} />
            <Route path="*" element={<NotFound />} />
          </Route>
        </Routes>
      </Suspense>
    </BrowserRouter>
  </StrictMode>,
)

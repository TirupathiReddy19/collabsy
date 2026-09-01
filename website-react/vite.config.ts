import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// Builds straight into the existing Firebase Hosting "website" target's
// public dir (see /firebase.json — target "website" → "build/web-website"),
// so no hosting config changes are needed to deploy this in place of the
// old Flutter-web-built site.
export default defineConfig({
  plugins: [react()],
  build: {
    outDir: '../build/web-website',
    emptyOutDir: true,
  },
})

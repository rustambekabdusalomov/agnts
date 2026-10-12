import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vitest/config'

// In development the API runs on :8080 (make dev-server). Vite proxies /api
// so the session cookie stays same-origin, as it is behind Caddy in production.
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:8080',
      // "Continue with Google" on the website posts here.
      '/auth': 'http://localhost:8080',
      // The website's "Request a connector" form posts here.
      '/site': 'http://localhost:8080',
      '/healthz': 'http://localhost:8080',
      // agnts-link connectors (private networks) reach the agnts-dev-gateway container.
      '/link': { target: 'http://localhost:3130', ws: true },
    },
  },
  test: {
    environment: 'jsdom',
  },
})

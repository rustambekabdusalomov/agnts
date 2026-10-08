import { lstatSync, rmSync } from 'node:fs'
import { join } from 'node:path'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: false },
  ssr: true,
  telemetry: false,

  modules: ['@nuxtjs/i18n'],

  hooks: {
    // `nuxi generate` leaves a `dist` symlink to .output/public next to the project. The repo must not
    // contain symlinks (and the build output lives in .output/public), so remove it again.
    close(nuxt) {
      const dist = join(nuxt.options.rootDir, 'dist')
      try {
        if (lstatSync(dist).isSymbolicLink()) rmSync(dist)
      } catch { /* not there */ }
    },
  },

  css: ['~/assets/css/tokens.css'],

  // Test files sit next to the code they cover; keep them out of the auto-import scan.
  ignore: ['**/*.test.ts'],

  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1, viewport-fit=cover',
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
      ],
    },
  },

  runtimeConfig: {
    // Overridable with NUXT_PUBLIC_<NAME> at build time (e.g. NUXT_PUBLIC_PRICE_USD).
    public: {
      // The hosted price list in dollars; keep in step with the server's AGNTS_PRICE_* (so'm, in
      // server/internal/config). priceUsd is a workspace a month.
      priceUsd: 25,
      priceSlotUsd: 15,
      priceMemberUsd: 5,
      includedMembers: 5,
      maxSlots: 5,
      creditMarkup: 1.4,
      // "Continue with Google": the OAuth web client id, and the agnts server (admin panel) the
      // sign-in posts to. Without a client id the dialog says sign-in is not set up.
      googleClientId: '',
      appUrl: 'http://localhost:5173',
    },
  },

  nitro: {
    prerender: {
      routes: ['/', '/ru', '/uz'],
      crawlLinks: false,
    },
  },

  i18n: {
    baseUrl: 'https://agnts.uz',
    strategy: 'prefix_except_default',
    defaultLocale: 'en',
    restructureDir: false,
    langDir: 'locales',
    locales: [
      { code: 'en', language: 'en-US', name: 'English', file: 'en.json' },
      { code: 'ru', language: 'ru-RU', name: 'Русский', file: 'ru.json' },
      { code: 'uz', language: 'uz-UZ', name: 'O’zbek', file: 'uz.json' },
    ],
    lazy: true,
    bundle: { optimizeTranslationDirective: false },
    experimental: {
      // Keep absolute build paths out of the generated runtime config.
      generatedLocaleFilePathFormat: 'relative',
    },
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'agnts-lang',
      redirectOn: 'root',
    },
  },

  typescript: {
    strict: true,
  },
})

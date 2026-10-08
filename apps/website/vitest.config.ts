import { defineConfig } from 'vitest/config'

// Unit tests for pure code (utils/, locales/). Nothing here needs the Nuxt runtime.
export default defineConfig({
  test: {
    environment: 'node',
    include: ['utils/**/*.test.ts', 'locales/**/*.test.ts'],
  },
})

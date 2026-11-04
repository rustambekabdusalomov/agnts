import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { setWorkspace } from '../../api/client'
import { i18n } from '../../i18n'
import type { ChatMessage } from './chat'
import ChatMessageItem from './ChatMessageItem.vue'

const msg = (m: Partial<ChatMessage>): ChatMessage => ({ id: 1, channelId: 1, author: 'bo', kind: 'text', body: 'hi', refs: [], createdAt: '2026-11-04T10:00:00Z', ...m })

async function render(m: ChatMessage) {
  const pinia = createPinia()
  setActivePinia(pinia)
  setWorkspace('acme')
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/', component: { template: '<div />' } }] })
  await router.push('/')
  return mount(ChatMessageItem, { props: { message: m }, global: { plugins: [pinia, router, i18n, [VueQueryPlugin, { queryClient: new QueryClient() }]] } })
}

describe('who wrote a message', () => {
  it("shows a person's picture, or their initials", async () => {
    const w = await render(msg({ authorId: 7, authorAvatar: '/users/7/avatar?v=2' }))
    expect(w.find('.cm-av img').attributes('src')).toBe('/api/users/7/avatar?v=2')
    const plain = await render(msg({ authorId: 8, author: 'rustam' }))
    expect(plain.find('.cm-av img').exists()).toBe(false)
    expect(plain.find('.cm-av').text()).toBe('RU')
  })

  it("shows agnts's logo on its messages", async () => {
    const w = await render(msg({ kind: 'agent_text', author: 'agnts', body: 'Merged ✅' }))
    expect(w.find('svg.brand-logo').exists()).toBe(true)
    expect(w.text()).not.toContain('✨ ')
  })
})

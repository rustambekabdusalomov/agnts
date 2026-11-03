import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { describe, expect, it } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { setWorkspace } from '../../api/client'
import { i18n } from '../../i18n'
import type { ChatMessage } from './chat'
import ChatMessageItem from './ChatMessageItem.vue'

const voice = (audio: NonNullable<ChatMessage['audio']>, body = ''): ChatMessage => ({
  id: 41, channelId: 1, authorId: 2, author: 'bo', kind: 'text', body, refs: [], createdAt: '2026-11-04T10:00:00Z', audio,
})

async function render(m: ChatMessage) {
  const pinia = createPinia()
  setActivePinia(pinia)
  setWorkspace('acme')
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/', component: { template: '<div />' } }] })
  await router.push('/')
  return mount(ChatMessageItem, { props: { message: m }, global: { plugins: [pinia, router, i18n, [VueQueryPlugin, { queryClient: new QueryClient() }]] } })
}

describe('a voice message', () => {
  it('plays its recording and says Muse is listening', async () => {
    const w = await render(voice({ contentType: 'audio/webm', durationMs: 65_400, transcript: 'pending' }))
    expect(w.find('audio').attributes('src')).toBe('/api/w/acme/chat/messages/41/audio')
    expect(w.text()).toContain('1:05')
    expect(w.text()).toContain('Muse is listening')
  })

  it('shows what was heard', async () => {
    const w = await render(voice({ contentType: 'audio/webm', durationMs: 4000, transcript: 'done' }, 'the export is slow again'))
    expect(w.text()).toContain('the export is slow again')
    expect(w.text()).not.toContain('listening')
  })

  it('says when no words were heard, or why it was not heard', async () => {
    expect((await render(voice({ contentType: 'audio/ogg', durationMs: 900, transcript: 'none' }))).text()).toContain('No words were heard')
    const failed = await render(voice({ contentType: 'audio/ogg', durationMs: 900, transcript: 'failed', error: 'Muse is not connected' }))
    expect(failed.text()).toContain('Could not transcribe it: Muse is not connected')
  })
})

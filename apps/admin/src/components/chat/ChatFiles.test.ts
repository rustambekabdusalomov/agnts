import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi } from 'vitest'
import { setWorkspace } from '../../api/client'
import { i18n } from '../../i18n'
import ChatFiles from '../files/ChatFiles.vue'
import ChatComposer from './ChatComposer.vue'

vi.mock('../../api/client', async (orig) => {
  const real = await orig<typeof import('../../api/client')>()
  let id = 40
  return {
    ...real,
    api: { DELETE: vi.fn() },
    uploadAttachment: vi.fn(async (f: File) => {
      id++
      return { id, name: f.name, contentType: f.type || 'text/plain', size: f.size, purpose: 'pending', image: f.type === 'image/png', url: `/attachments/${id}`, createdAt: '' }
    }),
  }
})

describe('files in a message', () => {
  it('shows pictures as thumbnails and other files as downloads', () => {
    setWorkspace('acme')
    const w = mount(ChatFiles, {
      props: {
        files: [
          { id: 7, name: 'shot.png', contentType: 'image/png', size: 2048, image: true, url: '/attachments/7' },
          { id: 8, name: 'payments.log', contentType: 'text/plain', size: 3 << 20, image: false, url: '/attachments/8' },
        ],
      },
      global: { plugins: [i18n] },
    })
    expect(w.find('img').attributes('src')).toBe('/api/w/acme/attachments/7')
    const a = w.find('a.cf-row')
    expect(a.attributes('href')).toBe('/api/w/acme/attachments/8')
    expect(a.attributes('download')).toBe('payments.log')
    expect(a.text()).toContain('3.0 MB')
  })
})

describe('the composer with files', () => {
  async function attach(w: ReturnType<typeof mount>, files: File[]) {
    const input = w.find('input[type=file]')
    Object.defineProperty(input.element, 'files', { value: files, configurable: true })
    await input.trigger('change')
    await flushPromises()
  }

  it('sends files without text, then clears them', async () => {
    const w = mount(ChatComposer, { props: { channelName: 'general' }, global: { plugins: [i18n] } })
    const send = w.find('button[type=submit]')
    expect(send.attributes('disabled')).toBeDefined()
    await attach(w, [new File(['ERROR'], 'payments.log', { type: 'text/plain' })])
    expect(send.attributes('disabled')).toBeUndefined()
    await w.find('form').trigger('submit')
    const sent = w.emitted('send')
    expect(sent).toHaveLength(1)
    const [body, files] = sent![0] as [string, { id: number; name: string }[]]
    expect(body).toBe('')
    expect(files.map((f) => f.name)).toEqual(['payments.log'])
    await flushPromises()
    expect(w.text()).not.toContain('payments.log')
  })

  it('sends text with files', async () => {
    const w = mount(ChatComposer, { props: { channelName: 'general' }, global: { plugins: [i18n] } })
    await attach(w, [new File(['png'], 'shot.png', { type: 'image/png' })])
    await w.find('textarea').setValue('the button does nothing')
    await w.find('form').trigger('submit')
    const [body, files] = w.emitted('send')![0] as [string, { image: boolean }[]]
    expect(body).toBe('the button does nothing')
    expect(files[0].image).toBe(true)
  })
})

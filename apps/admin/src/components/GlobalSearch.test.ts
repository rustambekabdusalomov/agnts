import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { describe, expect, it, vi } from 'vitest'
import { createMemoryHistory, createRouter } from 'vue-router'
import { i18n } from '../i18n'
import GlobalSearch from './GlobalSearch.vue'

function setup(component = GlobalSearch) {
  const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/', component: { template: '<div />' } }] })
  return mount(component, {
    props: { pages: [] },
    attachTo: document.body,
    global: { plugins: [i18n, createPinia(), router, [VueQueryPlugin, { queryClient: new QueryClient() }]] },
  })
}

const press = (init: KeyboardEventInit) => {
  const e = new KeyboardEvent('keydown', { key: '/', cancelable: true, ...init })
  window.dispatchEvent(e)
  return e
}

describe('GlobalSearch', () => {
  // The test browser is not a Mac: Ctrl+/ is the shortcut.
  it('focuses the search on Ctrl+/ from anywhere, and selects what is typed', async () => {
    const w = setup()
    const input = w.find('input').element as HTMLInputElement
    expect(w.find('.gs-key').text()).toBe('Ctrl /')
    expect(input.getAttribute('aria-keyshortcuts')).toBe('Control+/')

    expect(press({ metaKey: true }).defaultPrevented).toBe(false)
    expect(press({ key: 'k', ctrlKey: true }).defaultPrevented).toBe(false)
    expect(document.activeElement).not.toBe(input)

    await w.find('input').setValue('SHOP')
    input.blur()
    const e = press({ ctrlKey: true })
    expect(e.defaultPrevented).toBe(true)
    expect(document.activeElement).toBe(input)
    expect([input.selectionStart, input.selectionEnd]).toEqual([0, 4])
    expect(w.find('.gs-key').exists()).toBe(false) // hidden once something is typed
    w.unmount()
  })

  it('uses ⌘/ on a Mac, not Ctrl+/', async () => {
    vi.stubGlobal('navigator', { ...navigator, platform: 'MacIntel' })
    vi.resetModules()
    const mac = (await import('./GlobalSearch.vue')).default
    const w = setup(mac)
    const input = w.find('input').element as HTMLInputElement
    expect(w.find('.gs-key').text()).toBe('⌘ /')
    expect(press({ ctrlKey: true }).defaultPrevented).toBe(false)
    expect(press({ metaKey: true }).defaultPrevented).toBe(true)
    expect(document.activeElement).toBe(input)
    w.unmount()
    vi.unstubAllGlobals()
  })

  it('leaves the search on Esc, keeping what is typed', async () => {
    const w = setup()
    const input = w.find('input')
    ;(input.element as HTMLInputElement).focus()
    await input.setValue('SHOP')
    expect(document.activeElement).toBe(input.element)
    expect(w.find('#gs-list').exists()).toBe(true)
    await input.trigger('keydown', { key: 'Escape' })
    expect(document.activeElement).not.toBe(input.element)
    expect(w.find('#gs-list').exists()).toBe(false)
    expect((input.element as HTMLInputElement).value).toBe('SHOP')
    w.unmount()
  })

  it('stops listening once it is gone', () => {
    const w = setup()
    w.unmount()
    expect(press({ ctrlKey: true }).defaultPrevented).toBe(false)
  })
})

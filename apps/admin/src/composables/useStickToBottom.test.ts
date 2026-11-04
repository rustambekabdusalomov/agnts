import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { defineComponent, h, nextTick, ref } from 'vue'
import { i18n } from '../i18n'
import ScrollToBottom from '../components/chat/ScrollToBottom.vue'
import { useStickToBottom } from './useStickToBottom'

// jsdom does no layout: a scroller with set sizes stands in for one.
function fakeScroller(scrollHeight: number, clientHeight = 400) {
  const el = document.createElement('div')
  let top = scrollHeight - clientHeight
  Object.defineProperty(el, 'scrollHeight', { get: () => scrollHeight, configurable: true })
  Object.defineProperty(el, 'clientHeight', { get: () => clientHeight })
  Object.defineProperty(el, 'scrollTop', { get: () => top, set: (v: number) => (top = Math.max(0, Math.min(v, scrollHeight - clientHeight))) })
  return {
    el,
    grow(by: number) {
      scrollHeight += by
    },
    scrollTo(v: number) {
      el.scrollTop = v
      el.dispatchEvent(new Event('scroll'))
    },
  }
}

function setup(s: ReturnType<typeof fakeScroller>) {
  let api!: ReturnType<typeof useStickToBottom>
  const C = defineComponent({
    setup() {
      api = useStickToBottom(ref(s.el))
      return () => h(ScrollToBottom, { show: api.far.value, count: 2, onGo: () => api.toBottom() })
    },
  })
  const w = mount(C, { global: { plugins: [i18n] } })
  return { w, api: () => api }
}

describe('useStickToBottom', () => {
  it('shows the button when scrolled up and goes back down on click', async () => {
    const s = fakeScroller(3000)
    const { w } = setup(s)
    expect(w.find('button').exists()).toBe(false)
    s.scrollTo(100)
    await nextTick()
    const b = w.find('button')
    expect(b.exists()).toBe(true)
    expect(b.text()).toContain('2 new')
    await b.trigger('click')
    await nextTick()
    expect(s.el.scrollTop).toBe(2600)
    expect(w.find('button').exists()).toBe(false)
  })

  it('follows new content only when at the bottom, or when forced', async () => {
    const s = fakeScroller(3000)
    const { api } = setup(s)
    // At the bottom: new content is followed.
    api().follow()
    s.grow(500)
    await nextTick()
    expect(s.el.scrollTop).toBe(3100)
    // Scrolled up to read: streamed text does not pull the person down.
    s.scrollTo(200)
    api().follow()
    s.grow(500)
    await nextTick()
    expect(s.el.scrollTop).toBe(200)
    expect(api().far.value).toBe(true)
    // Sending goes down anyway.
    api().follow(true)
    s.grow(100)
    await nextTick()
    expect(s.el.scrollTop).toBe(3700)
    expect(api().far.value).toBe(false)
  })
})

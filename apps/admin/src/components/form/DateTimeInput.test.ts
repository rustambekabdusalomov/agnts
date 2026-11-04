import { mount } from '@vue/test-utils'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { nextTick } from 'vue'
import { i18n } from '../../i18n'
import DateTimeInput from './DateTimeInput.vue'

// Wed 4 Nov 2026, 14:37 local time.
const NOW = new Date(2026, 10, 4, 14, 37)

function setup(props: { modelValue?: string; max?: string; min?: string } = {}) {
  return mount(DateTimeInput, {
    props: { modelValue: '', label: 'When it was held', ...props },
    global: { plugins: [i18n] },
    attachTo: document.body,
  })
}
const hm = (h: number, m: number) => new Date(2026, 10, 4, h, m).toLocaleTimeString('en', { hour: '2-digit', minute: '2-digit' })
const day = (w: ReturnType<typeof setup>, d: Date) => w.find(`[data-day="${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}"]`)
const last = (w: ReturnType<typeof setup>) => new Date((w.emitted('update:modelValue')?.at(-1)?.[0] as string) ?? '')

describe('DateTimeInput', () => {
  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(NOW)
  })
  afterEach(() => vi.useRealTimers())

  it('shows the value, or asks for one', () => {
    expect(setup().find('.isel-value').text()).toBe('Choose a date and time')
    expect(setup({ modelValue: new Date(2026, 10, 4, 9, 5).toISOString() }).find('.isel-value').text()).toMatch(/4 Nov.*09:05|Nov 4.*09:05/)
  })

  it('keeps the time when another day is picked, and the day when a time is', async () => {
    const w = setup({ modelValue: new Date(2026, 10, 4, 9, 30).toISOString() })
    await w.find('.isel-trigger').trigger('click')
    await day(w, new Date(2026, 10, 2)).trigger('click')
    expect(last(w)).toEqual(new Date(2026, 10, 2, 9, 30))
    await w.setProps({ modelValue: last(w).toISOString() })
    const slot = w.findAll('.dti-time').find((o) => o.text() === hm(11, 15))!
    await slot.trigger('click')
    expect(last(w)).toEqual(new Date(2026, 10, 2, 11, 15))
    expect(w.find('.dti-pop').exists()).toBe(false) // a time closes it
  })

  it("can't go past max: later days and times are off, and a picked day is clamped", async () => {
    const w = setup({ modelValue: new Date(2026, 10, 3, 16, 0).toISOString(), max: NOW.toISOString() })
    await w.find('.isel-trigger').trigger('click')
    expect(day(w, new Date(2026, 10, 5)).attributes('aria-disabled')).toBe('true')
    await day(w, new Date(2026, 10, 5)).trigger('click')
    expect(w.emitted('update:modelValue')).toBeUndefined()
    // Today at 16:00 would be in the future: the latest step before now.
    await day(w, new Date(2026, 10, 4)).trigger('click')
    expect(last(w)).toEqual(new Date(2026, 10, 4, 14, 35))
    await w.setProps({ modelValue: last(w).toISOString() })
    const off = w.findAll('.dti-time').filter((o) => o.attributes('aria-disabled') === 'true')
    expect(off[0].text()).toBe(hm(14, 40))
    expect(w.find('[aria-label="Next month"]').attributes('disabled')).toBeDefined()
  })

  it('moves through days with the keyboard and picks with Enter', async () => {
    const w = setup({ modelValue: new Date(2026, 10, 4, 10, 0).toISOString() })
    await w.find('.isel-trigger').trigger('click')
    await nextTick()
    const grid = w.find('.dti-grid')
    expect(document.activeElement).toBe(day(w, new Date(2026, 10, 4)).element)
    await grid.trigger('keydown', { key: 'ArrowDown' })
    await grid.trigger('keydown', { key: 'ArrowRight' })
    await nextTick()
    expect(document.activeElement).toBe(day(w, new Date(2026, 10, 12)).element)
    await grid.trigger('keydown', { key: 'PageDown' })
    expect(w.find('.dti-month').text().toLowerCase()).toContain('december')
    await grid.trigger('keydown', { key: 'Enter' })
    expect(last(w)).toEqual(new Date(2026, 11, 12, 10, 0))
    await w.find('.dti').trigger('keydown', { key: 'Escape' })
    expect(w.find('.dti-pop').exists()).toBe(false)
  })

  it('sets now with the Now button', async () => {
    const w = setup({ max: NOW.toISOString() })
    await w.find('.isel-trigger').trigger('click')
    await w.findAll('.dti-foot .btn')[0].trigger('click')
    expect(last(w)).toEqual(new Date(2026, 10, 4, 14, 35))
  })
})

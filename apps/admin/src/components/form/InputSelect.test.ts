import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { nextTick } from 'vue'
import { i18n } from '../../i18n'
import InputSelect from './InputSelect.vue'

const opts = (n: number) => Array.from({ length: n }, (_, i) => ({ value: i + 1, label: `Repo ${i + 1}` }))

function setup(n: number, value?: number) {
  return mount(InputSelect, {
    props: { modelValue: value, options: opts(n), label: 'Repository', placeholder: 'Pick one' },
    global: { plugins: [i18n] },
    attachTo: document.body,
  })
}

describe('InputSelect', () => {
  it('shows the selected label or the placeholder', async () => {
    expect(setup(3).find('.isel-value').text()).toBe('Pick one')
    expect(setup(3, 2).find('.isel-value').text()).toBe('Repo 2')
  })

  it('has no search box with 10 options or fewer, and picks by click', async () => {
    const w = setup(10)
    await w.find('.isel-trigger').trigger('click')
    expect(w.find('.isel-search').exists()).toBe(false)
    expect(w.findAll('.isel-opt')).toHaveLength(10)
    await w.findAll('.isel-opt')[3].trigger('click')
    expect(w.emitted('update:modelValue')).toEqual([[4]])
    expect(w.find('.isel-pop').exists()).toBe(false)
  })

  it('searches with more than 10 options and picks with the keyboard', async () => {
    const w = setup(12, 1)
    await w.find('.isel-trigger').trigger('click')
    const search = w.find('.isel-search')
    expect(search.exists()).toBe(true)
    await search.setValue('repo 1')
    expect(w.findAll('.isel-opt').map((o) => o.text())).toEqual(['Repo 1', 'Repo 10', 'Repo 11', 'Repo 12'])
    await search.trigger('keydown', { key: 'ArrowDown' })
    await search.trigger('keydown', { key: 'Enter' })
    expect(w.emitted('update:modelValue')).toEqual([[10]])

    await w.find('.isel-trigger').trigger('click')
    await w.find('.isel-search').setValue('nothing')
    expect(w.find('.isel-empty').exists()).toBe(true)
    await w.find('.isel-search').trigger('keydown', { key: 'Escape' })
    await nextTick()
    expect(w.find('.isel-pop').exists()).toBe(false)
  })

  it('skips disabled options', async () => {
    const w = mount(InputSelect, {
      props: { modelValue: 1, options: [{ value: 1, label: 'A' }, { value: 2, label: 'B', disabled: true }, { value: 3, label: 'C' }], label: 'L' },
      global: { plugins: [i18n] },
      attachTo: document.body,
    })
    await w.find('.isel-trigger').trigger('click')
    await w.find('.isel-list').trigger('keydown', { key: 'ArrowDown' })
    await w.find('.isel-list').trigger('keydown', { key: 'Enter' })
    expect(w.emitted('update:modelValue')).toEqual([[3]])
  })
})

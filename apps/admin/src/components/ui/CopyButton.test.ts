import { flushPromises, mount } from '@vue/test-utils'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { i18n } from '../../i18n'
import CopyButton from './CopyButton.vue'

describe('CopyButton', () => {
  afterEach(() => vi.unstubAllGlobals())

  it('copies the whole error text and says so', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    vi.stubGlobal('navigator', { clipboard: { writeText } })
    const text = 'claude exited without a result (exit 1)\nError: claude native binary not installed.'
    const w = mount(CopyButton, { props: { text }, global: { plugins: [i18n] } })
    expect(w.text()).toBe('Copy')
    await w.trigger('click')
    await flushPromises()
    expect(writeText).toHaveBeenCalledWith(text)
    expect(w.text()).toBe('Copied')
  })

  it('does not follow a link it sits in', async () => {
    vi.stubGlobal('navigator', { clipboard: { writeText: vi.fn().mockResolvedValue(undefined) } })
    const onClick = vi.fn()
    const w = mount({ components: { CopyButton }, template: '<a href="#x" @click="onClick"><CopyButton text="x" /></a>', methods: { onClick } }, { global: { plugins: [i18n] } })
    await w.find('button').trigger('click')
    expect(onClick).not.toHaveBeenCalled()
  })
})

import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { i18n } from '../../i18n'
import CiLog from './CiLog.vue'

describe('CiLog', () => {
  it('highlights the first error and shows the log as text', () => {
    const sample = '=== first error ===\n<b>boom</b>\n\n=== end of the log ===\nexit 1'
    const w = mount(CiLog, { props: { sample }, global: { plugins: [i18n] } })
    expect(w.find('.ci-err').text()).toBe('<b>boom</b>')
    expect(w.find('b').exists()).toBe(false) // untrusted log text is never HTML
    expect(w.text()).toContain('First error')
    expect(w.text()).toContain('End of the log')
  })
})

import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import CheckBox from './CheckBox.vue'

describe('CheckBox', () => {
  it('toggles the model through the native input', async () => {
    const w = mount(CheckBox, { props: { modelValue: false, 'onUpdate:modelValue': (v: boolean) => w.setProps({ modelValue: v }) }, slots: { default: 'Compare' } })
    expect(w.text()).toBe('Compare')
    await w.find('input').setValue(true)
    expect(w.props('modelValue')).toBe(true)
    expect((w.find('input').element as HTMLInputElement).checked).toBe(true)
  })

  it('names itself with label when there is no visible text', () => {
    const w = mount(CheckBox, { props: { modelValue: true, label: 'Pick it' } })
    expect(w.find('input').attributes('aria-label')).toBe('Pick it')
    expect(w.find('.cbx-lbl').exists()).toBe(false)
  })

  it('is disabled', () => {
    const w = mount(CheckBox, { props: { modelValue: false, disabled: true } })
    expect(w.find('input').attributes('disabled')).toBeDefined()
    expect(w.classes()).toContain('dis')
  })
})

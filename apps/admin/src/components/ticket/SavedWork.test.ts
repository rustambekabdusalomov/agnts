import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { i18n } from '../../i18n'
import SavedWork from './SavedWork.vue'

describe('SavedWork', () => {
  it('lists the unfinished files and offers to discard them', async () => {
    const w = mount(SavedWork, {
      props: { files: ['refund.go', 'refund_test.go'], discard: false, 'onUpdate:discard': (v: boolean) => w.setProps({ discard: v }) },
      global: { plugins: [i18n] },
    })
    expect(w.text()).toContain('left 2 changed files unfinished')
    expect(w.findAll('li').map((li) => li.text())).toEqual(['refund.go', 'refund_test.go'])
    await w.find('input[type=checkbox]').setValue(true)
    expect(w.props('discard')).toBe(true)
  })
})

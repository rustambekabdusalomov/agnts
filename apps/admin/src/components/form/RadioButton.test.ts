import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { defineComponent, ref } from 'vue'
import RadioButton from './RadioButton.vue'

describe('RadioButton', () => {
  it('sets the group model to its value', async () => {
    const pick = ref('a')
    const w = mount(defineComponent({
      components: { RadioButton },
      setup: () => ({ pick }),
      template: '<RadioButton v-model="pick" name="g" value="a">A</RadioButton><RadioButton v-model="pick" name="g" value="b">B</RadioButton>',
    }))
    const [a, b] = w.findAll('input')
    expect((a.element as HTMLInputElement).checked).toBe(true)
    await b.setValue(true)
    expect(pick.value).toBe('b')
    expect(w.text()).toBe('AB')
  })

  it('takes a tone, a label and disabled', () => {
    const w = mount(RadioButton, { props: { modelValue: 1, value: 1, name: 'g', label: 'One', disabled: true, tone: 'bad' } })
    expect(w.classes()).toEqual(expect.arrayContaining(['dis', 'tone-bad']))
    expect(w.find('input').attributes('aria-label')).toBe('One')
    expect(w.find('input').attributes('disabled')).toBeDefined()
  })
})

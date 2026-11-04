import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import { i18n } from '../../i18n'
import FileDrop from './FileDrop.vue'

function setup(props: Record<string, unknown> = {}) {
  return mount(FileDrop, {
    props: {
      modelValue: null,
      accept: 'video/*,audio/*,.mkv',
      maxBytes: 1000,
      tooBig: 'Too big',
      badType: (n: string) => `${n} is not a recording`,
      hint: 'Video or audio',
      id: 'up',
      ...props,
    },
    global: { plugins: [i18n] },
  })
}
const file = (name: string, type: string, size = 10) => new File([new Uint8Array(size)], name, { type })
async function drop(w: ReturnType<typeof setup>, f: File) {
  await w.find('.fd').trigger('drop', { dataTransfer: { files: [f] } })
}

describe('FileDrop', () => {
  it('takes a dropped file that fits', async () => {
    const w = setup()
    const f = file('standup.mkv', '')
    await drop(w, f)
    expect(w.emitted('update:modelValue')).toEqual([[f]])
  })

  it('refuses the wrong kind of file and one over the limit', async () => {
    const w = setup()
    await drop(w, file('notes.pdf', 'application/pdf'))
    expect(w.find('[role="alert"]').text()).toBe('notes.pdf is not a recording')
    await drop(w, file('call.mp4', 'video/mp4', 2000))
    expect(w.find('[role="alert"]').text()).toBe('Too big')
    expect(w.emitted('update:modelValue')).toBeUndefined()
  })

  it('shows the picked file, removes it, and fills while uploading', async () => {
    const f = file('call.m4a', 'audio/mp4', 2048)
    const w = setup({ modelValue: f })
    expect(w.find('.fd-name').text()).toBe('call.m4a')
    expect(w.find('.fd-meta').text()).toBe('2 KB')
    await w.find('.fd-x').trigger('click')
    expect(w.emitted('update:modelValue')).toEqual([[null]])
    const up = setup({ modelValue: f, progress: 0.42 })
    expect(up.find('.fd-meta').text()).toBe('2 KB · 42%')
    expect(up.find('.fd-fill').attributes('style')).toContain('42%')
    expect(up.find('.fd-x').exists()).toBe(false)
  })
})

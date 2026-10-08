import { flushPromises, mount } from '@vue/test-utils'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { i18n } from '../../i18n'
import FileAttach from './FileAttach.vue'

const del = vi.fn()
vi.mock('../../api/client', async (orig) => {
  const real = await orig<typeof import('../../api/client')>()
  let id = 0
  return {
    ...real,
    api: { DELETE: (...a: unknown[]) => del(...a) },
    uploadAttachment: vi.fn(async (f: File) => {
      if (f.name === 'broken.txt') throw new real.HttpError(500, { message: 'x' })
      return { id: ++id, name: f.name, contentType: 'text/plain', size: f.size, purpose: 'pending', url: `/attachments/${id}`, createdAt: '' }
    }),
  }
})

function setup() {
  return mount(FileAttach, { props: { modelValue: [], busy: false }, global: { plugins: [i18n] } })
}

async function pick(w: ReturnType<typeof setup>, files: File[]) {
  const input = w.find('input[type=file]')
  Object.defineProperty(input.element, 'files', { value: files, configurable: true })
  await input.trigger('change')
  await flushPromises()
}

afterEach(() => del.mockReset())

describe('FileAttach', () => {
  it('uploads picked files and reports their ids', async () => {
    const w = setup()
    await pick(w, [new File(['a'], 'a.txt'), new File(['b'], 'b.log')])
    const ids = w.emitted('update:modelValue')
    expect(ids?.[ids.length - 1]).toEqual([[1, 2]])
    expect(w.findAll('.fa-item')).toHaveLength(2)
  })

  it('refuses large files and shows failed uploads, without ids', async () => {
    const w = setup()
    const big = new File(['x'], 'big.bin')
    Object.defineProperty(big, 'size', { value: 11 << 20 })
    await pick(w, [big, new File(['x'], 'broken.txt')])
    expect(w.text()).toContain('big.bin is larger than 10 MB')
    expect(w.text()).toContain('Could not upload broken.txt')
    expect(w.emitted('update:modelValue')).toBeUndefined()
  })

  it('previews pictures before they are sent', async () => {
    URL.createObjectURL = vi.fn(() => 'blob:shot')
    URL.revokeObjectURL = vi.fn()
    const w = setup()
    await pick(w, [new File(['p'], 'shot.png', { type: 'image/png' }), new File(['a'], 'notes.txt')])
    expect(w.find('.fa-pic img').attributes('src')).toBe('blob:shot')
    expect(w.findAll('.fa-pic')).toHaveLength(1)
    expect(w.findAll('.fa-item')).toHaveLength(1)
    // A picture the browser cannot draw falls back to a row.
    await w.find('.fa-pic img').trigger('error')
    expect(w.findAll('.fa-pic')).toHaveLength(0)
    expect(w.findAll('.fa-item')).toHaveLength(2)
  })

  it('deletes an upload when it is removed', async () => {
    const w = setup()
    await pick(w, [new File(['a'], 'c.txt')])
    await w.find('.fa-x').trigger('click')
    expect(del).toHaveBeenCalledWith('/attachments/{id}', { params: { path: { id: 5 } } })
    const ids = w.emitted('update:modelValue')
    expect(ids?.[ids.length - 1]).toEqual([[]])
  })
})

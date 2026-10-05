import { describe, expect, it } from 'vitest'
import { answerConfirm, askConfirm, confirmState } from './useConfirm'

const opts = { title: 'Delete', confirmLabel: 'Delete' }

describe('askConfirm', () => {
  it('resolves true when confirmed and closes', async () => {
    const p = askConfirm(opts)
    expect(confirmState.open).toBe(true)
    answerConfirm(true)
    await expect(p).resolves.toBe(true)
    expect(confirmState.open).toBe(false)
  })

  it('resolves false when dismissed', async () => {
    const p = askConfirm(opts)
    answerConfirm(false)
    await expect(p).resolves.toBe(false)
  })

  it('answers no to an unanswered question when a new one arrives', async () => {
    const first = askConfirm(opts)
    const second = askConfirm({ ...opts, title: 'Archive' })
    await expect(first).resolves.toBe(false)
    expect(confirmState.opts?.title).toBe('Archive')
    answerConfirm(true)
    await expect(second).resolves.toBe(true)
  })
})

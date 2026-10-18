import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import type { FileChange } from '../../api/types'
import { i18n } from '../../i18n'
import RepoDiffs from './RepoDiffs.vue'

const file = (repo: string | undefined, path: string, add: number, del: number): FileChange =>
  ({ path, repo, add, del, status: 'modified', diff: '@@ -1 +1 @@\n-a\n+b' }) as FileChange

const files = [file('gateway', 'api/a.go', 3, 1), file('gateway', 'api/b.go', 2, 0), file('protos', 'content.proto', 10, 4)]
const setup = (fs: FileChange[], repo = '') =>
  mount(RepoDiffs, { props: { files: fs, repo, 'onUpdate:repo': () => {} }, global: { plugins: [i18n], stubs: { DiffView: { props: ['file'], template: '<div class="dv">{{ file.path }}</div>' } } } })

describe('RepoDiffs', () => {
  it('gives each repository a tab with its files and lines, and shows the first', () => {
    const w = setup(files)
    const tabs = w.findAll('.tab')
    expect(tabs.map((x) => x.text())).toEqual(['gateway2+5 −1', 'protos1+10 −4'])
    expect(tabs[0].attributes('aria-pressed')).toBe('true')
    expect(w.findAll('.dv').map((x) => x.text())).toEqual(['api/a.go', 'api/b.go'])
  })

  it('shows the picked repository only, and asks the page to remember it', async () => {
    const w = setup(files)
    await w.findAll('.tab')[1].trigger('click')
    expect(w.emitted('update:repo')?.[0]).toEqual(['protos'])
    await w.setProps({ repo: 'protos' })
    expect(w.findAll('.dv').map((x) => x.text())).toEqual(['content.proto'])
    expect(w.findAll('.tab')[1].attributes('aria-pressed')).toBe('true')
  })

  it('has no tabs for one repository', () => {
    const w = setup([file(undefined, 'a.go', 1, 0), file(undefined, 'b.go', 1, 1)])
    expect(w.find('.tabs').exists()).toBe(false)
    expect(w.findAll('.dv')).toHaveLength(2)
  })
})

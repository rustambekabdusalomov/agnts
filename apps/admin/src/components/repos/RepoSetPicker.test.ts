import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import type { RepoGroup, Repository } from '../../api/types'
import { i18n } from '../../i18n'
import RepoSetPicker from './RepoSetPicker.vue'
import { selectionBody, type RepoSelection } from './repoSet'

const repo = (id: number, name: string, archivedAt?: string) => ({ id, name, archivedAt }) as Repository
const repos = [repo(1, 'api'), repo(2, 'web'), repo(3, 'docs'), repo(4, 'old', '2026-01-01')]
const groups = [{
  id: 7, name: 'Shop', description: '', instructions: '', taskPrefix: '', warnings: [], createdAt: '', updatedAt: '',
  members: [{ repoId: 1, repoName: 'api', role: 'backend', archived: false }, { repoId: 2, repoName: 'web', role: 'web', archived: false }],
}] satisfies RepoGroup[]

function setup(sel: RepoSelection) {
  const w = mount(RepoSetPicker, {
    props: { repos, groups, label: 'Repository', noneLabel: 'No repository', modelValue: sel, 'onUpdate:modelValue': (v: RepoSelection) => w.setProps({ modelValue: v }) },
    global: { plugins: [i18n] },
  })
  return w
}
const model = (w: ReturnType<typeof setup>) => w.props('modelValue') as RepoSelection

describe('RepoSetPicker', () => {
  it('lists groups above repositories, leaving out archived ones', () => {
    const w = setup({ groupId: null, repoIds: [] })
    expect(w.findAll('.tab').map((b) => b.text())).toEqual(['No repository', 'Shop 2'])
    expect(w.findAll('.cbx').map((c) => c.text())).toEqual(['api', 'web', 'docs'])
    expect(w.find('.rsp-chips').exists()).toBe(false)
  })

  it('picks a group as chips; removing one sends repoIds', async () => {
    const w = setup({ groupId: null, repoIds: [] })
    await w.findAll('.tab')[1].trigger('click')
    expect(selectionBody(model(w))).toEqual({ groupId: 7 })
    const chips = w.findAll('.chip')
    expect(chips[0].findAll('span').map((x) => x.text())).toEqual(['api', 'backend', 'primary'])
    expect(chips[1].find('.rsp-prim').text()).toBe('web')
    expect(chips[1].find('.rsp-role').text()).toBe('web')
    expect(w.find('.rsp-chips').text()).toContain('From group Shop')
    await chips[1].find('button[aria-label="Remove web"]').trigger('click')
    expect(selectionBody(model(w))).toEqual({ repoId: 1 })
  })

  it('checks repositories one by one, and back to none', async () => {
    const w = setup({ groupId: null, repoIds: [1] })
    await w.findAll('.cbx input')[2].setValue(true)
    expect(selectionBody(model(w))).toEqual({ repoIds: [1, 3] })
    await w.find('.chip .rsp-prim').trigger('click')
    expect(model(w).repoIds).toEqual([3, 1])
    await w.findAll('.tab')[0].trigger('click')
    expect(selectionBody(model(w))).toEqual({})
  })
})

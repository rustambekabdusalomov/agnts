import { describe, expect, it } from 'vitest'
import type { RepoGroup, Ticket } from '../../api/types'
import { filePath, filesByRepo, hasRepo, makePrimary, pickGroup, repoChip, selectionBody, ticketRepos, ticketSelection, toggleRepo } from './repoSet'

const group: RepoGroup = {
  id: 7, name: 'Shop', description: '', instructions: '', taskPrefix: 'SHOP', branchTemplate: '', commitTemplate: '', warnings: [], createdAt: '', updatedAt: '',
  members: [
    { repoId: 1, repoName: 'api', role: 'backend', archived: false },
    { repoId: 2, repoName: 'web', role: 'web', archived: false },
    { repoId: 3, repoName: 'old', role: '', archived: true },
  ],
}
const state = (repoId: number, repoName: string) => ({
  repoId, repoName, role: '', folder: repoName, branch: 'agnts/X-1', headSha: '', prUrl: '', ciFixes: 0, state: 'pending' as const, files: 0,
})
const multi = { repoId: 1, repoName: 'api', repos: [state(1, 'api'), state(2, 'web'), state(4, 'docs')], group: { id: 7, name: 'Shop' } } satisfies Partial<Ticket>

describe('repository selection', () => {
  it('sends groupId for a group as picked, without archived members', () => {
    const s = pickGroup(group)
    expect(s).toEqual({ groupId: 7, repoIds: [1, 2] })
    expect(selectionBody(s)).toEqual({ groupId: 7 })
  })

  it('sends repoIds once the group is edited, and repoId for one repository', () => {
    const edited = toggleRepo(pickGroup(group), 4, true)
    expect(selectionBody(edited)).toEqual({ repoIds: [1, 2, 4] })
    const one = toggleRepo(toggleRepo(edited, 2, false), 4, false)
    expect(selectionBody(one)).toEqual({ repoId: 1 })
    expect(selectionBody(toggleRepo(one, 1, false))).toEqual({})
  })

  it('moves a repository to the front as the primary', () => {
    expect(makePrimary({ groupId: null, repoIds: [1, 2, 4] }, 4)).toEqual({ groupId: null, repoIds: [4, 1, 2] })
    const g = pickGroup(group)
    expect(makePrimary(g, 1)).toBe(g)
  })
})

describe('ticket repositories', () => {
  it('reads repos, or the primary scalars of an older answer', () => {
    expect(ticketRepos(multi).map((r) => r.repoName)).toEqual(['api', 'web', 'docs'])
    expect(ticketRepos({ repoId: 5, repoName: 'cli' })).toEqual([{ repoId: 5, repoName: 'cli' }])
    expect(ticketRepos({})).toEqual([])
    expect(ticketSelection(multi)).toEqual({ groupId: 7, repoIds: [1, 2, 4] })
  })

  it('labels and filters by any of them', () => {
    expect(repoChip(multi)).toEqual({ name: 'api', more: 2, all: 'api, web, docs' })
    expect(repoChip({ repoId: 5, repoName: 'cli' })).toEqual({ name: 'cli', more: 0, all: 'cli' })
    expect(repoChip({})).toBeNull()
    expect(hasRepo(multi, 4)).toBe(true)
    expect(hasRepo(multi, 9)).toBe(false)
  })

  it('prefixes and groups changed files by repository folder', () => {
    const files = [{ repo: 'api', path: 'a.go' }, { repo: 'web', path: 'b.ts' }, { repo: 'api', path: 'c.go' }]
    expect(files.map(filePath)).toEqual(['api/a.go', 'web/b.ts', 'api/c.go'])
    expect(filePath({ path: 'x.go' })).toBe('x.go')
    expect(filesByRepo(files).map((g) => [g.repo, g.files.length])).toEqual([['api', 2], ['web', 1]])
  })
})

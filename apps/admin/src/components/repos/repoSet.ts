import type { FileChange, RepoGroup, Ticket, TicketRepoState } from '../../api/types'

/**
 * Which repositories a new ticket works in: a group as picked (its members
 * copied into repoIds), or repositories picked one by one. The first id is
 * the primary repository. Editing a group's members drops the group, so
 * the server gets the edited list.
 */
export interface RepoSelection {
  groupId: number | null
  repoIds: number[]
}

export const emptySelection = (): RepoSelection => ({ groupId: null, repoIds: [] })

/** A group's members that can take new work (archived ones are left out), in order. */
export const groupRepoIds = (g: Pick<RepoGroup, 'members'>) => g.members.filter((m) => !m.archived).map((m) => m.repoId)

/** Picks a group: its active members, in the group's order. */
export const pickGroup = (g: RepoGroup): RepoSelection => ({ groupId: g.id, repoIds: groupRepoIds(g) })

/** Checks or unchecks one repository; any edit makes it a plain list. */
export function toggleRepo(sel: RepoSelection, id: number, on: boolean): RepoSelection {
  const ids = sel.repoIds.filter((x) => x !== id)
  return { groupId: null, repoIds: on ? [...ids, id] : ids }
}

/** Makes a repository the primary one (first). */
export function makePrimary(sel: RepoSelection, id: number): RepoSelection {
  if (sel.repoIds[0] === id) return sel
  return { groupId: null, repoIds: [id, ...sel.repoIds.filter((x) => x !== id)] }
}

/**
 * The request fields for a selection: groupId for a group as picked,
 * repoId for one repository (as before groups), repoIds for several, and
 * nothing for none.
 */
export function selectionBody(sel: RepoSelection): { repoId?: number; repoIds?: number[]; groupId?: number } {
  if (sel.groupId) return { groupId: sel.groupId }
  if (sel.repoIds.length === 1) return { repoId: sel.repoIds[0] }
  if (sel.repoIds.length > 1) return { repoIds: [...sel.repoIds] }
  return {}
}

/** A ticket's repositories, primary first; older answers carry only the primary as scalars. */
export function ticketRepos(t: Pick<Ticket, 'repos' | 'repoId' | 'repoName'>): Pick<TicketRepoState, 'repoId' | 'repoName'>[] {
  if (t.repos?.length) return t.repos
  return t.repoId != null ? [{ repoId: t.repoId, repoName: t.repoName ?? `#${t.repoId}` }] : []
}

export const isMultiRepo = (t: Pick<Ticket, 'repos'>) => (t.repos?.length ?? 0) > 1

/** The selection a ticket stands for now: its group if it has one, else its repositories. */
export function ticketSelection(t: Pick<Ticket, 'repos' | 'repoId' | 'repoName' | 'group'>): RepoSelection {
  return { groupId: t.group?.id ?? null, repoIds: ticketRepos(t).map((r) => r.repoId) }
}

/** Compact label for lists: "api", or "api +2" for a ticket in three repositories. */
export function repoChip(t: Pick<Ticket, 'repos' | 'repoId' | 'repoName'>): { name: string; more: number; all: string } | null {
  const rs = ticketRepos(t)
  if (!rs.length) return null
  return { name: rs[0].repoName, more: rs.length - 1, all: rs.map((r) => r.repoName).join(', ') }
}

/** The ticket works in repository id (any of its repositories). */
export const hasRepo = (t: Pick<Ticket, 'repos' | 'repoId' | 'repoName'>, id: number) => ticketRepos(t).some((r) => r.repoId === id)

/** A changed file's path as shown: "<folder>/<path>" for a ticket in several repositories. */
export const filePath = (f: Pick<FileChange, 'repo' | 'path'>) => (f.repo ? `${f.repo}/${f.path}` : f.path)

/** Changed files grouped by repository folder, in the order they come. */
export function filesByRepo<F extends Pick<FileChange, 'repo'>>(files: F[]): { repo: string; files: F[] }[] {
  const out: { repo: string; files: F[] }[] = []
  for (const f of files) {
    const r = f.repo ?? ''
    let g = out.find((x) => x.repo === r)
    if (!g) out.push((g = { repo: r, files: [] }))
    g.files.push(f)
  }
  return out
}

/** Badge tone per repository state of a ticket. */
export const REPO_STATE_TONE: Record<TicketRepoState['state'], 'gray' | 'info' | 'ok' | 'warn' | 'bad'> = {
  pending: 'gray',
  unchanged: 'gray',
  pushed: 'info',
  merged: 'ok',
  dropped: 'warn',
}

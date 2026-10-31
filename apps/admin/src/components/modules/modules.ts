import type { components } from '../../api/schema.gen'

export type Module = components['schemas']['Module']
/** A module with an account to connect: Codex runs on the workspace's OpenAI integration. */
export type AccountModule = Exclude<Module, 'codex'>

/** Why an ordered list cannot be someone's modules, or '' when it can: it
 * names at least one, and Codex is never the default (the first). */
export function listProblem(list: readonly Module[]): '' | 'empty' | 'codexFirst' {
  if (!list.length) return 'empty'
  return list[0] === 'codex' ? 'codexFirst' : ''
}

/** The list with `m` moved one place up (-1) or down (+1). */
export function moved(list: readonly Module[], m: Module, by: -1 | 1): Module[] {
  const out = list.filter((x) => x !== m)
  const i = list.indexOf(m)
  if (i < 0 || i + by < 0 || i + by >= list.length) return [...list]
  out.splice(i + by, 0, m)
  return out
}

/** The modules of a list that have an account (Muse, Claude), in its order. */
export const accountModules = (list: readonly Module[]) => list.filter((m): m is AccountModule => m !== 'codex')

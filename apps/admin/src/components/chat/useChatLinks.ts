import type { RouteLocationRaw } from 'vue-router'
import { useRepos } from '../repos/useRepos'
import type { ChatRef } from './chat'
import { splitPr } from './citations'

/** Where a link under a message, or a citation in an answer, leads: a page here or a URL on the git host. */
export type Target = { route: RouteLocationRaw } | { url: string } | null

export function useChatLinks() {
  const repos = useRepos()
  const repoId = (name: string) => repos.data.value?.find((r) => r.name === name || r.name.toLowerCase() === name.toLowerCase())?.id

  function target(type: ChatRef['type'], id: string, refs: ChatRef[] = []): Target {
    switch (type) {
      case 'ticket':
        return { route: { name: 'ticket', params: { key: id } } }
      case 'finding':
        return /^\d+$/.test(id) ? { route: { name: 'logFinding', params: { id } } } : null
      case 'repo': {
        const r = repoId(id)
        return r ? { route: { name: 'repo', params: { id: r } } } : null
      }
      case 'pr': {
        const url = refs.find((x) => x.type === 'pr' && x.id === id)?.url
        if (url) return { url }
        const p = splitPr(id)
        const r = p && repoId(p.repo)
        return p && r ? { route: { name: 'pull', params: { id: r, number: p.number } } } : null
      }
    }
    return null
  }

  return { target, repoId, repos }
}

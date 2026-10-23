import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, onScopeDispose, ref, watch, type Ref } from 'vue'
import { api, unwrap } from '../../api/client'
import type { DocumentComment, DocumentCommentInput, DocumentPresence, DocumentViewer } from '../../api/types'

/**
 * Where comments and presence go: a member's document (/documents/{id}) or
 * a guest's public link (/public/documents/{token}, with the guest's
 * token). The panel and the highlights do not care which.
 */
export interface CommentsTarget {
  queryKey: [string, string]
  list(): Promise<DocumentComment[]>
  add(body: DocumentCommentInput): Promise<DocumentComment>
  patch(id: number, body: { body?: string; resolved?: boolean }): Promise<DocumentComment>
  remove(id: number): Promise<void>
  presence(leaving?: boolean): Promise<DocumentPresence>
}

/** A signed-in member's document. */
export function memberTarget(id: number): CommentsTarget {
  const path = { id }
  return {
    queryKey: ['document-comments', String(id)],
    list: () => unwrap(api.GET('/documents/{id}/comments', { params: { path } })),
    add: (body) => unwrap(api.POST('/documents/{id}/comments', { params: { path }, body })),
    patch: (commentId, body) => unwrap(api.PATCH('/documents/{id}/comments/{commentId}', { params: { path: { id, commentId } }, body })),
    remove: async (commentId) => {
      await unwrap(api.DELETE('/documents/{id}/comments/{commentId}', { params: { path: { id, commentId } } }))
    },
    presence: (leaving) => unwrap(api.POST('/documents/{id}/presence', { params: { path }, body: { leaving }, keepalive: !!leaving })),
  }
}

/** A guest on a public link. */
export function guestTarget(token: string, guest: string): CommentsTarget {
  const header = { 'X-Guest-Token': guest }
  return {
    queryKey: ['public-comments', token],
    list: () => unwrap(api.GET('/public/documents/{token}/comments', { params: { path: { token }, header } })),
    add: (body) => unwrap(api.POST('/public/documents/{token}/comments', { params: { path: { token }, header }, body })),
    patch: (commentId, body) =>
      unwrap(api.PATCH('/public/documents/{token}/comments/{commentId}', { params: { path: { token, commentId }, header }, body })),
    remove: async (commentId) => {
      await unwrap(api.DELETE('/public/documents/{token}/comments/{commentId}', { params: { path: { token, commentId }, header } }))
    },
    presence: (leaving) =>
      unwrap(api.POST('/public/documents/{token}/presence', { params: { path: { token }, header }, body: { leaving }, keepalive: !!leaving })),
  }
}

/** A thread: its first comment, on a selection, and the replies. */
export interface Thread {
  root: DocumentComment
  replies: DocumentComment[]
}

/** The comments of a target, as threads in the order they were started. */
export function useComments(target: Ref<CommentsTarget | null>) {
  const qc = useQueryClient()
  const list = useQuery({
    queryKey: computed(() => target.value?.queryKey ?? ['document-comments', '']),
    queryFn: () => target.value!.list(),
    enabled: computed(() => !!target.value),
  })
  const threads = computed<Thread[]>(() => {
    const all = list.data.value ?? []
    const byRoot = new Map<number, Thread>()
    for (const c of all) if (c.parentId == null) byRoot.set(c.id, { root: c, replies: [] })
    for (const c of all) if (c.parentId != null) byRoot.get(c.parentId)?.replies.push(c)
    return [...byRoot.values()]
  })
  const refresh = () => {
    if (target.value) void qc.invalidateQueries({ queryKey: target.value.queryKey })
  }
  const add = useMutation({ mutationFn: (b: DocumentCommentInput) => target.value!.add(b), onSuccess: refresh })
  const patch = useMutation({
    mutationFn: (v: { id: number; body?: string; resolved?: boolean }) => target.value!.patch(v.id, { body: v.body, resolved: v.resolved }),
    onSuccess: refresh,
  })
  const remove = useMutation({ mutationFn: (id: number) => target.value!.remove(id), onSuccess: refresh })
  return { list, threads, add, patch, remove, refresh }
}

/** How often a page says it is still open (the server forgets after 30 s). */
const BEAT = 10_000

/**
 * Who has the document open now. The page says it is here every 10 seconds
 * and that it leaves when it goes; when the comments' stamp moves, they are
 * fetched again (guests have no event stream).
 */
export function usePresence(target: Ref<CommentsTarget | null>, onStale: () => void) {
  const viewers = ref<DocumentViewer[]>([])
  let stamp = ''
  let timer: ReturnType<typeof setInterval> | undefined
  let current: CommentsTarget | null = null

  async function beat() {
    if (!current || document.visibilityState === 'hidden') return
    try {
      const p = await current.presence()
      viewers.value = p.viewers
      if (stamp && p.commentsStamp !== stamp) onStale()
      stamp = p.commentsStamp
    } catch {
      // A missed beat is fine; the next one tries again.
    }
  }
  function leave() {
    if (current) void current.presence(true).catch(() => undefined)
  }
  function stop() {
    if (timer) clearInterval(timer)
    timer = undefined
    leave()
    current = null
    stamp = ''
    viewers.value = []
  }
  const onVisible = () => {
    if (document.visibilityState === 'visible') void beat()
  }
  watch(
    target,
    (t) => {
      stop()
      if (!t) return
      current = t
      void beat()
      timer = setInterval(beat, BEAT)
    },
    { immediate: true },
  )
  document.addEventListener('visibilitychange', onVisible)
  window.addEventListener('pagehide', leave)
  onScopeDispose(() => {
    stop()
    document.removeEventListener('visibilitychange', onVisible)
    window.removeEventListener('pagehide', leave)
  })
  return { viewers }
}

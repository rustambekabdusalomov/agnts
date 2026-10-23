import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, ref, type Ref } from 'vue'
import { api, apiPath, HttpError, unwrap } from '../../api/client'
import type { Document, DocumentKind, DocumentSource, DocumentSummary } from '../../api/types'

export type DocScope = 'all' | 'mine' | 'shared' | 'deleted'

/** The documents the person can open, by scope, kind ('' for both) and title words. */
export function useDocumentList(scope: Ref<DocScope>, q: Ref<string>, kind: Ref<DocumentKind | ''> = ref('')) {
  return useQuery({
    queryKey: computed(() => ['documents', scope.value, q.value, kind.value]),
    queryFn: () =>
      unwrap(api.GET('/documents', { params: { query: { scope: scope.value, q: q.value || undefined, kind: kind.value || undefined } } })),
    // A generation in progress: look again until it is written.
    refetchInterval: (query) => (busy(query.state.data) ? 4000 : false),
  })
}

/** One document; polls while agnts writes it. */
export function useDocument(id: Ref<number>) {
  return useQuery({
    queryKey: computed(() => ['document', String(id.value)]),
    queryFn: () => unwrap(api.GET('/documents/{id}', { params: { path: { id: id.value } } })),
    enabled: computed(() => id.value > 0),
    refetchInterval: (query) => (writing(query.state.data) ? 3000 : false),
  })
}

/** Whether agnts is writing the document now. */
export function writing(d?: DocumentSummary | Document): boolean {
  const s = d?.generation?.status
  return s === 'queued' || s === 'writing'
}

function busy(ds?: DocumentSummary[]): boolean {
  return !!ds?.some((d) => writing(d))
}

/** Refetches every document query after a change. */
export function useDocumentsRefresh() {
  const qc = useQueryClient()
  return (id?: number) => {
    void qc.invalidateQueries({ queryKey: ['documents'] })
    void qc.invalidateQueries({ queryKey: ['ticket-documents'] })
    if (id) {
      void qc.invalidateQueries({ queryKey: ['document', String(id)] })
      void qc.invalidateQueries({ queryKey: ['document-versions', String(id)] })
      void qc.invalidateQueries({ queryKey: ['document-sharing', String(id)] })
      void qc.invalidateQueries({ queryKey: ['document-tickets', String(id)] })
    }
  }
}

/** The templates each source offers, the default first. */
export const TEMPLATES: Record<DocumentSource['kind'], NonNullable<DocumentSource['template']>[]> = {
  report: ['ticket_summary', 'status', 'blank'],
  tickets: ['status', 'ticket_summary', 'release_notes', 'blank'],
  commits: ['release_notes', 'status', 'blank'],
  pulls: ['pr_review', 'release_notes', 'blank'],
  repo: ['repo_review', 'blank'],
  document: ['presentation', 'blank'],
}

/** The slide decks made from a page that the person can open. */
export function useDerivedDecks(id: Ref<number>, enabled: Ref<boolean>) {
  return useQuery({
    queryKey: computed(() => ['documents', 'derived', id.value]),
    queryFn: () => unwrap(api.GET('/documents', { params: { query: { derivedFrom: id.value } } })),
    enabled: computed(() => enabled.value && id.value > 0),
    refetchInterval: (query) => (busy(query.state.data) ? 4000 : false),
  })
}

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms))

/** The file name from Content-Disposition, or fallback. */
function fileName(h: string | null, fallback: string): string {
  const star = h?.match(/filename\*=UTF-8''([^;]+)/i)
  if (star) return decodeURIComponent(star[1])
  return h?.match(/filename="([^"]+)"/i)?.[1] ?? fallback
}

/**
 * Downloads a file from an API path. A PDF being made answers 202: it asks
 * again after Retry-After, up to about a minute, calling onWait meanwhile.
 */
export async function downloadFile(path: string, fallback: string, onWait?: () => void, headers?: Record<string, string>): Promise<void> {
  const deadline = Date.now() + 75_000
  for (;;) {
    const res = await fetch(path, { credentials: 'same-origin', headers })
    if (res.status === 202 && Date.now() < deadline) {
      onWait?.()
      const ra = Number(res.headers.get('Retry-After'))
      await sleep((Number.isFinite(ra) && ra > 0 ? ra : 3) * 1000)
      continue
    }
    if (!res.ok || res.status === 202) {
      const body = await res.json().catch(() => undefined)
      throw new HttpError(res.status, body)
    }
    const blob = await res.blob()
    const url = URL.createObjectURL(blob)
    const a = window.document.createElement('a')
    a.href = url
    a.download = fileName(res.headers.get('Content-Disposition'), fallback)
    window.document.body.appendChild(a)
    a.click()
    a.remove()
    setTimeout(() => URL.revokeObjectURL(url), 10_000)
    return
  }
}

/** The download URL of a version (0: the current one) of a document. */
export function downloadPath(id: number, format: 'md' | 'pdf', version = 0): string {
  const q = new URLSearchParams({ format })
  if (version) q.set('version', String(version))
  return `${apiPath(`/documents/${id}/download`)}?${q}`
}

/** The download URL of a public document. */
export function publicDownloadPath(token: string, format: 'md' | 'pdf'): string {
  return `/api/public/documents/${encodeURIComponent(token)}/download?format=${format}`
}

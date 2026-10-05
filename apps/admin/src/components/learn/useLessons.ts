import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { computed, type Ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Lesson } from '../../api/types'
import { useUi } from '../../stores/ui'

export type LessonStatus = 'new' | 'learned' | 'all'

/** Lessons for the Learn page and the ticket page (query key ['lessons', ...]). */
export function useLessons(filter: Ref<{ status?: LessonStatus; repo?: number; ticket?: string }>) {
  return useQuery({
    queryKey: computed(() => ['lessons', 'list', filter.value]),
    queryFn: () => unwrap(api.GET('/lessons', { params: { query: filter.value } })),
  })
}

/** One lesson. */
export function useLesson(id: Ref<number>) {
  return useQuery({
    queryKey: computed(() => ['lessons', id.value]),
    queryFn: () => unwrap(api.GET('/lessons/{id}', { params: { path: { id: id.value } } })),
  })
}

/** Marks a lesson learned or not, and refreshes every lesson query. */
export function useSetLearned() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  return useMutation({
    mutationFn: ({ id, learned }: { id: number; learned: boolean }) => {
      const path = { params: { path: { id } } }
      return unwrap(learned ? api.PUT('/lessons/{id}/learned', path) : api.DELETE('/lessons/{id}/learned', path))
    },
    onSuccess: (l: Lesson) => {
      qc.setQueryData(['lessons', l.id], l)
      void qc.invalidateQueries({ queryKey: ['lessons'] })
      if (l.learnedAt) ui.notify(t('learn.markedLearned'))
    },
    onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  })
}

/**
 * Splits a lesson's plain-text explanation into paragraphs and code blocks.
 * Text from Claude is never rendered as HTML.
 */
export function blocks(text: string): { code: boolean; text: string }[] {
  const out: { code: boolean; text: string }[] = []
  const fence = /```[^\n]*\n([\s\S]*?)```/g
  let last = 0
  const prose = (s: string) => {
    for (const p of s.split(/\n\s*\n/)) {
      if (!p.trim()) continue
      // Paragraphs indented as a whole are code too.
      const code = p.split('\n').every((l) => !l.trim() || /^( {4}|\t)/.test(l))
      out.push({ code, text: code ? p.replace(/^( {4}|\t)/gm, '') : p.trim() })
    }
  }
  for (const m of text.matchAll(fence)) {
    prose(text.slice(last, m.index))
    out.push({ code: true, text: m[1].replace(/\n$/, '') })
    last = (m.index ?? 0) + m[0].length
  }
  prose(text.slice(last))
  return out
}

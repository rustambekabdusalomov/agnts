import { useMutation, useQuery, useQueryClient } from '@tanstack/vue-query'
import { useI18n } from 'vue-i18n'
import { api, HttpError, unwrap } from '../../api/client'
import type { Rule, RuleStatus } from '../../api/types'
import { livePoll } from '../../composables/useLive'
import { useUi } from '../../stores/ui'

/** Tone per review status, for badges (b-<tone>). */
export const RULE_TONE: Record<RuleStatus, 'gray' | 'info' | 'warn' | 'ok' | 'bad'> = {
  pending: 'info',
  analyzing: 'info',
  questions: 'warn',
  ready: 'ok',
  failed: 'bad',
  suggested: 'info',
}

type Translate = (key: string, values?: Record<string, unknown>) => string

/** Starter pack names, for "Starter: Go" (pack:go). */
const PACK_NAME: Record<string, string> = {
  go: 'Go', typescript: 'TypeScript', python: 'Python', java: 'Java', kotlin: 'Kotlin', rust: 'Rust',
  ruby: 'Ruby', php: 'PHP', csharp: 'C#', swift: 'Swift', dart: 'Dart',
}

/**
 * The harness badges of a rule: how it is enforced and delivered, its kind
 * when a tip, where it came from, and what a learned one has earned.
 */
export function ruleBadges(r: Rule, t: Translate): { label: string; tone: 'gray' | 'info' | 'warn' | 'ok' | 'bad' }[] {
  const out: { label: string; tone: 'gray' | 'info' | 'warn' | 'ok' | 'bad' }[] = []
  if (r.enforce) out.push(r.enforce.action === 'block' ? { label: t('harnessRules.badgeBlock'), tone: 'bad' } : { label: t('harnessRules.badgeWarn'), tone: 'warn' })
  if (r.delivery === 'skill') out.push({ label: t('harnessRules.badgeSkill'), tone: 'info' })
  if (r.kind === 'tip') out.push({ label: t('harnessRules.badgeTip'), tone: 'gray' })
  const src = r.source ?? ''
  if (src.startsWith('pack:')) {
    const id = src.slice(5)
    out.push({ label: t('harnessRules.sourceStarter', { name: PACK_NAME[id] ?? id }), tone: 'gray' })
  } else if (src === 'reflect' || src === 'run' || src === 'promoted') {
    out.push({ label: t(`harnessRules.source_${src}`), tone: 'gray' })
  }
  if (r.status === 'suggested' && r.confidence) out.push({ label: t('harnessRules.confidence', { n: Math.round(r.confidence * 100) }), tone: 'info' })
  if (r.status === 'suggested' && (r.evidence ?? 0) > 1) out.push({ label: t('harnessRules.seen', { n: r.evidence }), tone: 'gray' })
  return out
}

/**
 * Every rule (query key ['rules']). While a review is queued or running the
 * list refreshes on its own; rule_changed events refresh it too.
 */
export function useRules() {
  return useQuery({
    queryKey: ['rules'],
    queryFn: () => unwrap(api.GET('/rules')),
    refetchInterval: (q) => ((q.state.data ?? []).some((r) => r.status === 'pending' || r.status === 'analyzing') ? 5_000 : livePoll(60_000)),
  })
}

type Action =
  | { kind: 'answers'; id: number; answers: { index: number; answer: string; note?: string }[] }
  | { kind: 'accept' | 'review' | 'delete' | 'dismiss'; id: number }
  | { kind: 'enabled'; rule: Rule; enabled: boolean }

/** Answers, accept as written, review again, delete, and on/off. */
export function useRuleAction() {
  const { t } = useI18n()
  const qc = useQueryClient()
  const ui = useUi()
  return useMutation({
    mutationFn: async (a: Action): Promise<Rule | null> => {
      if (a.kind === 'enabled') {
        const r = a.rule
        return unwrap(
          api.PUT('/rules/{id}', {
            params: { path: { id: r.id } },
            body: { title: r.title, body: r.body, repoId: r.repoId, enabled: a.enabled, kind: r.kind },
          }),
        )
      }
      const path = { params: { path: { id: a.id } } }
      switch (a.kind) {
        case 'answers':
          return unwrap(api.PUT('/rules/{id}/answers', { ...path, body: { answers: a.answers } }))
        case 'accept':
          return unwrap(api.POST('/rules/{id}/accept', path))
        case 'review':
          return unwrap(api.POST('/rules/{id}/review', path))
        case 'delete':
        case 'dismiss':
          await unwrap(api.DELETE('/rules/{id}', path))
          return null
      }
    },
    onSuccess: (_r, a) => {
      void qc.invalidateQueries({ queryKey: ['rules'] })
      const msg: Record<Action['kind'], string> = {
        answers: t('rules.answered'),
        accept: t('rules.accepted'),
        review: t('rules.queued'),
        delete: t('rules.deleted'),
        dismiss: t('rules.dismissed'),
        enabled: a.kind === 'enabled' && a.enabled ? t('rules.turnedOn') : t('rules.turnedOff'),
      }
      ui.notify(msg[a.kind])
    },
    onError: (e) => ui.notify(e instanceof HttpError ? e.message : t('common.error')),
  })
}
